package au.edu.utas.kit305.assignment2

import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.os.Environment
import android.text.InputType
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.*
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.ActivityStudentDetailsBinding
import au.edu.utas.kit305.assignment2.databinding.StudentListItemBinding
import com.google.android.material.internal.ViewUtils.getContentView
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.ktx.storage
import java.io.File
import java.lang.Exception
import kotlin.math.roundToInt


class StudentDetails : AppCompatActivity()
{
    private lateinit var ui : ActivityStudentDetailsBinding
    private lateinit var student: Student

    private val grades = mutableMapOf<String, Any>()
    private val gradeSet = Array(12) { _ -> false}
    private var gradeTotal = 0.0
    private var gradeAverageSet = false

    override fun onCreate(savedInstanceState: Bundle?)
    {
        super.onCreate(savedInstanceState)
        ui = ActivityStudentDetailsBinding.inflate(layoutInflater)
        setContentView(ui.root)

        ui.gradeList.adapter = GradeAdapter(grades = grades)

        //vertical list
        ui.gradeList.layoutManager = LinearLayoutManager(this)

        val studentIndex = intent.getIntExtra(STUDENT_INDEX, -1)
        student = items[studentIndex]
        //Log.d(FIREBASE_TAG, "val is $student, in onCreate is $studentIndex")

        //get db connection
        val db = Firebase.firestore

        ui.txtGrade.text = "Loading grades..."
        db.collection("grades").document(items[studentIndex].studentID!!)
                .get()
                .addOnSuccessListener { result ->
                    grades.putAll(result.data!!)
                    (ui.gradeList.adapter as GradeAdapter).notifyDataSetChanged()
                }

        //get student object using id from intent
        //val student = items[studentIndex]
        ui.txtStudentName.text = "${student.firstName} ${student.lastName}";
        ui.txtStudentID.text = student.studentID;

        if(student.image != null)
        {
            setPic(ui.imgStudent)
        }

        ui.btnDeleteStudent.setOnClickListener {
            //Made this AlertDialog with help from https://www.journaldev.com/309/android-alert-dialog-using-kotlin
            val builder = AlertDialog.Builder(this)
            builder.setTitle("Delete student")
            builder.setMessage("Are you sure you want to delete ${student.firstName} ${student.lastName}?")

            builder.setPositiveButton("yes") { _, _ ->
                db.collection("students").document(student.studentID.toString())
                        .delete()
                        .addOnSuccessListener {
                            for(i in 0..items.size)
                            {
                                if(items[i].studentID == student.studentID)
                                {
                                    items.removeAt(i)
                                    break
                                }
                            }
                            db.collection("grades").document(student.studentID.toString())
                                    .delete()
                                    .addOnSuccessListener {  }
                                    .addOnFailureListener {  }
                            Toast.makeText(this@StudentDetails, "deleted ${student.firstName} ${student.lastName}", Toast.LENGTH_SHORT).show()
                            finish()
                        }
                        .addOnFailureListener { Toast.makeText(this@StudentDetails, "Error deleting student, try again later", Toast.LENGTH_SHORT).show() }
            }

            builder.setNegativeButton("no") {_,_ ->}
            builder.show()
        }

        ui.btnShare.setOnClickListener {
            var shareString = "First name,Last name,Student ID,Average Grade,Week 1,Week 2,Week 3,Week 4,Week 5,Week 6,Week 7,Week 8,Week 9,Week 10,Week 11,Week 12\n"
            shareString += "${student.firstName},${student.lastName},${student.studentID},${"%.2f".format(gradeTotal / 12)}"
            for((_, v) in grades)
            {
                shareString += ",$v"
            }

            Log.d(FIREBASE_TAG, shareString)
            val sendIntent = Intent().apply{
                action = Intent.ACTION_SEND
                putExtra(Intent.EXTRA_TEXT, shareString)
                type = "text/plain"
            }
            startActivity(Intent.createChooser(sendIntent, "Share via..."))
        }
    }

    private fun setPic(imageView: ImageView)
    {
        //Toast.makeText(this@StudentDetails, "${student.image}", Toast.LENGTH_SHORT).show()
        if(!student.image!!.contains("/"))
        {
            //Hardcoded as the dynamic version was getting 0 as the result and crashing
            val targetW: Int = 400
            val targetH: Int = 400

            val storage = Firebase.storage
            val storageRef = storage.reference
            val pathReference = storageRef.child("images/${student.image}")
            val storageDir: File = getExternalFilesDir(Environment.DIRECTORY_PICTURES)!!
            val localFile = File.createTempFile(
                    student.image!!, /* prefix */
                    ".jpg", /* suffix */
                    storageDir /* directory */
            )
            pathReference.getFile(localFile)
                    .addOnSuccessListener {
                        Log.d(FIREBASE_TAG, "Successfully downloaded image")
                        val bmOptions = BitmapFactory.Options().apply {
                            // Get the dimensions of the bitmap
                            inJustDecodeBounds = true

                            BitmapFactory.decodeFile(localFile.path, this)

                            val photoW: Int = outWidth
                            val photoH: Int = outHeight
                            Log.d(FIREBASE_TAG, "outW: $photoW outH: $photoH")

                            // Determine how much to scale down the image
                            val scaleFactor: Int = Math.max(1, Math.min(photoW / targetW, photoH / targetH))
                            Log.d(FIREBASE_TAG, "scaleFactor $scaleFactor")

                            // Decode the image file into a Bitmap sized to fill the View
                            inJustDecodeBounds = false
                            inSampleSize = scaleFactor
                        }
                        BitmapFactory.decodeFile(localFile.path, bmOptions)?.also { bitmap -> imageView.setImageBitmap(bitmap)}
                        for(i in 0..items.size)
                        {
                            if(items[i].studentID == student.studentID)
                            {
                                items[i].image = localFile.path
                                break
                            }
                        }
                    }
                    .addOnFailureListener { Log.d(FIREBASE_TAG, "Failed to download image") }
        }
        else
        {
            // Get the dimensions of the View
            val targetW: Int = 400
            val targetH: Int = 400

            val bmOptions = BitmapFactory.Options().apply {
                // Get the dimensions of the bitmap
                inJustDecodeBounds = true

                BitmapFactory.decodeFile(student.image, this)

                val photoW: Int = outWidth
                val photoH: Int = outHeight
                Log.d(FIREBASE_TAG, "outW: $photoW outH: $photoH")

                // Determine how much to scale down the image
                val scaleFactor: Int = Math.max(1, Math.min(photoW / targetW, photoH / targetH))
                Log.d(FIREBASE_TAG, "scaleFactor $scaleFactor")

                // Decode the image file into a Bitmap sized to fill the View
                inJustDecodeBounds = false
                inSampleSize = scaleFactor
            }
            BitmapFactory.decodeFile(student.image, bmOptions)?.also { bitmap -> imageView.setImageBitmap(bitmap)}
        }
    }

    inner class GradeHolder(var ui: StudentListItemBinding) : RecyclerView.ViewHolder(ui.root) {}

    inner class GradeAdapter(private val grades: Map<String, Any>) : RecyclerView.Adapter<GradeHolder>()
    {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StudentDetails.GradeHolder
        {
            val ui = StudentListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
            return GradeHolder(ui)                                                            //wrap it in a ViewHolder
        }

        override fun getItemCount(): Int
        {
            return grades.size
        }

        private fun changeGrade(newGrade: Int, holder: StudentDetails.GradeHolder, position: Int, db: FirebaseFirestore)
        {
            val currentGrade = holder.ui.txtID.text.toString().substringBefore('/').toInt()
            gradeTotal = gradeTotal - currentGrade + newGrade
            ui.txtGradeAverage.text = "Average grade is ${"%.2f".format(gradeTotal/12)}%"
            db.collection("grades").document(student.studentID.toString())
                    .update("week${position + 1}", newGrade)
                    .addOnSuccessListener {
                        Log.d(FIREBASE_TAG, "successfully updated grade for week ${position + 1} from $currentGrade to $newGrade")
                    }
                    .addOnFailureListener {
                        Log.e(FIREBASE_TAG, "Error writing document", it)
                    }
            Toast.makeText(this@StudentDetails, "updated grade for week ${position + 1} from $currentGrade to $newGrade", Toast.LENGTH_SHORT).show()
            holder.ui.txtID.text = "$newGrade/100"
        }

        override fun onBindViewHolder(holder: StudentDetails.GradeHolder, position: Int)
        {
            val weekNum = position + 1
            val gradeType = weekConfig["week$weekNum"]
            var grade = 0
            try{
                grade = grades["week$weekNum"].toString().toInt()
            }catch(e: Exception){}

            if(!gradeAverageSet)
            {
                for((_, value) in grades)  gradeTotal += value.toString().toInt()
                ui.txtGradeAverage.text = "Average grade is ${"%.2f".format(gradeTotal/12)}%"
                gradeAverageSet = true
            }

            val db = Firebase.firestore

            ui.txtGrade.text = "Grades"
            holder.ui.txtName.text = "Week $weekNum";
            holder.ui.txtID.text = "${grades["week$weekNum"].toString()}/100";

            if(!gradeSet[position])
            {
                when (gradeType)
                {
                    "checkBox" -> {
                        val numCheckBoxes = weekConfig["week${weekNum}CheckBoxNum"].toString().toInt()
                        val numCheckBoxesTicked: Int = grade / (100/numCheckBoxes)

                        for(i in 1..numCheckBoxes)
                        {
                            val gradeCheckBox = CheckBox(this@StudentDetails)
                            gradeCheckBox.text = i.toString()

                            if(i <= numCheckBoxesTicked) gradeCheckBox.isChecked = true

                            gradeCheckBox.setOnCheckedChangeListener { _, isChecked ->
                                if(isChecked) changeGrade(i*100/numCheckBoxes, holder, position, db)
                                else changeGrade((i - 1)*100/numCheckBoxes, holder, position, db)
                            }

                            holder.ui.gradeLayout.addView(gradeCheckBox)
                        }

                        gradeSet[position] = true
                    }
                    "attendance" -> {
                        val gradeCheckBox = CheckBox(this@StudentDetails)
                        gradeCheckBox.text = "attendance"

                        if(grade == 100) gradeCheckBox.isChecked = true

                        gradeCheckBox.setOnCheckedChangeListener { _, isChecked ->
                            if(isChecked) changeGrade(100, holder, position, db)
                            else changeGrade(0, holder, position, db)
                        }

                        holder.ui.gradeLayout.addView(gradeCheckBox)
                        gradeSet[position] = true
                    }
                    "gradeNN-HD" -> {
                        val spinner = Spinner(this@StudentDetails)

                        val adapter = ArrayAdapter(
                            this@StudentDetails,
                            android.R.layout.simple_spinner_item,
                            resources.getStringArray(R.array.GradesNNHD)
                        )

                        spinner.adapter = adapter

                        when(grade)
                        {
                            100 -> spinner.setSelection(0, false)
                            in 99 downTo 80 -> spinner.setSelection(1, false)
                            in 79 downTo 70 -> spinner.setSelection(2, false)
                            in 69 downTo 60 -> spinner.setSelection(3, false)
                            in 59 downTo 50 -> spinner.setSelection(4, false)
                            else -> spinner.setSelection(5, false)
                        }

                        spinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener
                        {
                            val positionInList = position

                            override fun onNothingSelected(parent: AdapterView<*>?) {}

                            override fun onItemSelected(parent: AdapterView<*>, view: View, position: Int, id: Long)
                            {
                                when(position)
                                {
                                    0 -> changeGrade(100, holder, positionInList, db)
                                    1 -> changeGrade(80, holder, positionInList, db)
                                    2 -> changeGrade(70, holder, positionInList, db)
                                    3 -> changeGrade(60, holder, positionInList, db)
                                    4 -> changeGrade(50, holder, positionInList, db)
                                    5 -> changeGrade(0, holder, positionInList, db)
                                }
                            }
                        }

                        holder.ui.gradeLayout.addView(spinner)
                        gradeSet[position] = true
                    }
                    "gradeA-F" -> {
                        val spinner = Spinner(this@StudentDetails)

                        val adapter = ArrayAdapter(
                            this@StudentDetails,
                            android.R.layout.simple_spinner_item,
                            resources.getStringArray(R.array.GradesAF)
                        )

                        spinner.adapter = adapter

                        when(grade)
                        {
                            100 ->  spinner.setSelection(0, false)
                            in 99 downTo 80 ->  spinner.setSelection(1, false)
                            in 79 downTo 70 ->  spinner.setSelection(2, false)
                            in 69 downTo 60 ->  spinner.setSelection(3, false)
                            else -> spinner.setSelection(4, false)
                        }

                        //Got this from https://stackoverflow.com/questions/46447296/android-kotlin-onitemselectedlistener-for-spinner-not-working
                        spinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener
                        {
                            val positionInList = position

                            override fun onNothingSelected(parent: AdapterView<*>?) {}

                            override fun onItemSelected(parent: AdapterView<*>, view: View, position: Int, id: Long)
                            {
                                when(position)
                                {
                                    0 -> changeGrade(100, holder, positionInList, db)
                                    1 -> changeGrade(80, holder, positionInList, db)
                                    2 -> changeGrade(70, holder, positionInList, db)
                                    3 -> changeGrade(60, holder, positionInList, db)
                                    4 -> changeGrade(0, holder, positionInList, db)
                                }
                            }
                        }

                        holder.ui.gradeLayout.addView(spinner)
                        gradeSet[position] = true
                    }
                    "score" -> {
                        val maxScore = weekConfig["week${weekNum}MaxScore"].toString().toInt()
                        val scoreText = TextView(this@StudentDetails)
                        val scoreEdit = EditText(this@StudentDetails)

                        scoreEdit.setText("${((grade/100.0)*maxScore).roundToInt()}")
                        scoreText.text = "/$maxScore"
                        scoreEdit.inputType = InputType.TYPE_CLASS_NUMBER
                        scoreEdit.imeOptions = EditorInfo.IME_ACTION_DONE

                        scoreEdit.setOnEditorActionListener { _, actionId, _ ->
                            return@setOnEditorActionListener when (actionId) {
                                EditorInfo.IME_ACTION_DONE -> {
                                    if(scoreEdit.text.toString().toInt() > maxScore) scoreEdit.setText("$maxScore")
                                    //Log.d(FIREBASE_TAG, "user entered ${scoreEdit.text}")
                                    changeGrade((scoreEdit.text.toString().toInt()*100)/maxScore, holder, position, db)
                                    true
                                }
                                else -> false
                            }
                        }

                        holder.ui.gradeLayout.addView(scoreEdit)
                        holder.ui.gradeLayout.addView(scoreText)
                        gradeSet[position] = true
                    }
                    else -> {
                        val testText = TextView(this@StudentDetails)
                        testText.text = "Unsupported grade type"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                }
            }
        }
    }
}