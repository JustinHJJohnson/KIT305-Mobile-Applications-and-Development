package au.edu.utas.kit305.assignment2

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.FileProvider
import androidx.fragment.app.DialogFragment
import au.edu.utas.kit305.assignment2.databinding.ModalAddStudentBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.ktx.storage
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

//Code for this modal was based on the code from this article https://blog.mindorks.com/implementing-dialog-fragment-in-android

class AddStudentModal: DialogFragment() {

    private lateinit var ui: ModalAddStudentBinding

    var photoSet = false
    var fileName = ""

    companion object {

        const val TAG = "AddStudentModal"

        fun newInstance(filePath: String?): AddStudentModal { return AddStudentModal() }

    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {
        ui = ModalAddStudentBinding.inflate(layoutInflater, container, false)
        val db = Firebase.firestore
        val studentsCollection = db.collection("students")
        val gradesCollection = db.collection("grades")

        ui.btnAddStudent.setOnClickListener {

            //Make sure the user has enter data in all the fields
            if(ui.editFirstName.text.toString() == "")
            {
                Toast.makeText(context, "Please enter a first name", Toast.LENGTH_SHORT).show()
            }
            else if(ui.editLastName.text.toString() == "")
            {
                Toast.makeText(context, "Please enter a last name", Toast.LENGTH_SHORT).show()
            }
            else if(ui.editStudentNumber.text.toString() == "" || ui.editStudentNumber.text.toString().length < 6)
            {
                Toast.makeText(context, "Please enter a 6-digit student number", Toast.LENGTH_SHORT).show()
            }
            else
            {
                val studentNumber = ui.editStudentNumber.text.toString()
                val student: Student

                //If the user uploaded an image, add that to the object, else add null
                if (photoSet)
                {
                    student = Student(
                        firstName = ui.editFirstName.text.toString(),
                        lastName = ui.editLastName.text.toString(),
                        studentID = studentNumber,
                        image = fileName
                    )
                }
                else
                {
                    student = Student(
                        firstName = ui.editFirstName.text.toString(),
                        lastName = ui.editLastName.text.toString(),
                        studentID = studentNumber,
                        image = null
                    )
                }

                //Add the student to the database
                studentsCollection.document(studentNumber)
                    .set(student)
                    .addOnSuccessListener {
                        Log.d(FIREBASE_TAG, "Student created with id $studentNumber")
                    }
                    .addOnFailureListener {
                        Log.e(FIREBASE_TAG, "Error writing document", it)
                    }

                //Create a Grade object to set all the students grades to 0
                gradesCollection.document(studentNumber)
                    .set(Grades())
                    .addOnSuccessListener {
                        Log.d(FIREBASE_TAG, "Grades created with id $studentNumber")
                    }
                    .addOnFailureListener {
                        Log.e(FIREBASE_TAG, "Error writing document", it)
                    }

                //Change this so newly added students don't have to redownload their image
                student.image = currentPhotoPath
                items.add(student)
                dismiss()
            }
        }

        ui.imgStudentPhoto.setOnClickListener {
            requestToTakeAPicture()
        }

        return ui.root
    }

    override fun onStart()
    {
        super.onStart()
        val width = (resources.displayMetrics.widthPixels * 0.85).toInt()
        val height = (resources.displayMetrics.heightPixels * 0.40).toInt()
        dialog!!.window?.setLayout(width, ViewGroup.LayoutParams.WRAP_CONTENT)
    }

    //Get permission from the user to use the camera
    @RequiresApi(Build.VERSION_CODES.M)
    private fun requestToTakeAPicture()
    {
        requestPermissions(
                arrayOf(Manifest.permission.CAMERA),
                REQUEST_IMAGE_CAPTURE
        )
    }

    //If permission is given, run next function
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray)
    {
        when(requestCode)
        {
            REQUEST_IMAGE_CAPTURE -> {
                if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED))
                {
                    // Permission is granted.
                    takeAPicture()
                }
                else
                {
                    Toast.makeText(context, "Cannot access camera, permission denied", Toast.LENGTH_LONG).show()
                }
            }
        }
    }

    //Create a temporary file to store the photo, then launch the camera
    private fun takeAPicture()
    {
        val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)

        val photoFile: File = createImageFile()!!
        fileName = Uri.fromFile(photoFile).lastPathSegment.toString()
        val photoURI: Uri = FileProvider.getUriForFile(
                context!!,
                "au.edu.utas.kit305.assignment2",
                photoFile
        )
        takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
        startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE)
    }

    //Store the path to the photo
    lateinit var currentPhotoPath: String

    //Create a temporary file
    @Throws(IOException::class)
    private fun createImageFile(): File
    {
        // Create an image file name
        val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val storageDir: File = context!!.getExternalFilesDir(Environment.DIRECTORY_PICTURES)!!
        return File.createTempFile(
                "JPEG_${timeStamp}_", /* prefix */
                ".jpg", /* suffix */
                storageDir /* directory */
        ).apply {
            // Save a file: path for use with ACTION_VIEW intents
            currentPhotoPath = absolutePath
        }
    }

    //Upload the photo to the database
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?)
    {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == AppCompatActivity.RESULT_OK)
        {
            //Warn the user the image is uploading and disable the Add student button
            Toast.makeText(context, "Please wait for image to upload", Toast.LENGTH_SHORT).show()
            ui.btnAddStudent.isEnabled = false
            ui.btnAddStudent.isClickable = false

            val storage = Firebase.storage
            val storageRef = storage.reference
            val file = Uri.fromFile(File(currentPhotoPath))
            val imageRef = storageRef.child("images/${file.lastPathSegment}")
            val uploadTask = imageRef.putFile(file)
            // Register observers to listen for when the download is done or if it fails
            uploadTask.addOnFailureListener {
                // Handle unsuccessful uploads
            }.addOnSuccessListener {
                Log.d(FIREBASE_TAG, "Successfully uploaded image")
                Toast.makeText(context, "Image has uploaded", Toast.LENGTH_SHORT).show()
                ui.btnAddStudent.isEnabled = true
                ui.btnAddStudent.isClickable = true
                photoSet = true
            }

            setPic(ui.imgStudentPhoto)
        }
    }

    //Display the picture in the AddStudentModal
    private fun setPic(imageView: ImageView)
    {
        // Get the dimensions of the View
        val targetW: Int = imageView.measuredWidth
        val targetH: Int = imageView.measuredHeight

        val bmOptions = BitmapFactory.Options().apply {
            // Get the dimensions of the bitmap
            inJustDecodeBounds = true

            BitmapFactory.decodeFile(currentPhotoPath, this)

            val photoW: Int = outWidth
            val photoH: Int = outHeight

            // Determine how much to scale down the image
            val scaleFactor: Int = Math.max(1, Math.min(photoW / targetW, photoH / targetH))

            // Decode the image file into a Bitmap sized to fill the View
            inJustDecodeBounds = false
            inSampleSize = scaleFactor
        }
        BitmapFactory.decodeFile(currentPhotoPath, bmOptions)?.also { bitmap ->
            imageView.setImageBitmap(bitmap)
        }
    }
}