package au.edu.utas.kit305.assignment2

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.DialogFragment
import au.edu.utas.kit305.assignment2.databinding.ModalAddStudentBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase

//Code for this modal was based on the code from this article https://blog.mindorks.com/implementing-dialog-fragment-in-android

class AddStudentModal: DialogFragment()
{
    companion object {

        const val TAG = "AddStudentModal"

        fun newInstance(): AddStudentModal {return AddStudentModal()}

    }

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View?
    {
        val inflatedView = ModalAddStudentBinding.inflate(layoutInflater, container, false)
        dialog?.window?.setBackgroundDrawableResource(R.drawable.round_corners); //These rounded corners came from this post https://medium.com/swlh/alertdialog-and-customdialog-in-android-with-kotlin-f42a168c1936
        val db = Firebase.firestore
        val studentsCollection = db.collection("students")
        val gradesCollection = db.collection("grades")

        inflatedView.btnAddStudent.setOnClickListener {
            val studentNumber = inflatedView.editStudentNumber.text.toString()

            val student = Student(
                    firstName = inflatedView.editFirstName.text.toString(),
                    lastName = inflatedView.editLastName.text.toString(),
                    studentID = studentNumber
            )

            studentsCollection.document(studentNumber)
                    .set(student)
                    .addOnSuccessListener {
                        Log.d(FIREBASE_TAG, "Student created with id $studentNumber")
                    }
                    .addOnFailureListener {
                        Log.e(FIREBASE_TAG, "Error writing document", it)
                    }

            //create a Grade object to set all the students grades to 0
            gradesCollection.document(studentNumber)
                    .set(Grades())
                    .addOnSuccessListener {
                        Log.d(FIREBASE_TAG, "Grades created with id $studentNumber")
                    }
                    .addOnFailureListener {
                        Log.e(FIREBASE_TAG, "Error writing document", it)
                    }

            items.add(student)
            dismiss()
        }

        return inflatedView.root
    }

    override fun onStart() {
        super.onStart()
        val width = (resources.displayMetrics.widthPixels * 0.85).toInt()
        val height = (resources.displayMetrics.heightPixels * 0.40).toInt()
        dialog!!.window?.setLayout(width, ViewGroup.LayoutParams.WRAP_CONTENT)
    }
}