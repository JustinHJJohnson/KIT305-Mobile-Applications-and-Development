package au.edu.utas.kit305.assignment2

import android.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.text.InputType
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.*
import androidx.core.view.updatePadding
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.ActivityStudentDetailsBinding
import au.edu.utas.kit305.assignment2.databinding.StudentListItemBinding
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import kotlin.math.roundToInt


class StudentDetails : AppCompatActivity()
{
    private lateinit var ui : ActivityStudentDetailsBinding

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
        val studentObject = items[studentIndex]
        ui.txtStudentName.text = "${studentObject.firstName} ${studentObject.lastName}";
        ui.txtStudentID.text = studentObject.studentID;

        ui.btnDeleteStudent.setOnClickListener {
            //Made this AlertDialog with help from https://www.journaldev.com/309/android-alert-dialog-using-kotlin
            val builder = AlertDialog.Builder(this)
            builder.setTitle("Delete student")
            builder.setMessage("Are you sure you want to delete ${studentObject.firstName} ${studentObject.lastName}?")

            builder.setPositiveButton("yes") { dialog, which ->
                db.collection("students").document(studentObject.studentID.toString())
                        .delete()
                        .addOnSuccessListener {
                            for(i in 0..items.size)
                            {
                                if(items[i].studentID == studentObject.studentID)
                                {
                                    items.removeAt(i)
                                    break
                                }
                            }
                            db.collection("grades").document(studentObject.studentID.toString())
                                    .delete()
                                    .addOnSuccessListener {  }
                                    .addOnFailureListener {  }
                            Toast.makeText(this@StudentDetails, "deleted ${studentObject.firstName} ${studentObject.lastName}", Toast.LENGTH_SHORT).show()
                            finish()
                        }
                        .addOnFailureListener { Toast.makeText(this@StudentDetails, "Error deleting student, try again later", Toast.LENGTH_SHORT).show() }
            }

            builder.setNegativeButton("no") {_,_ ->}
            builder.show()
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
            db.collection("grades").document(ui.txtStudentID.text.toString())
                    .update("week${position + 1}", newGrade)
                    .addOnSuccessListener {
                        Log.d(FIREBASE_TAG, "successfully updated grade for week ${position + 1} from $currentGrade to $newGrade")
                    }
                    .addOnFailureListener {
                        Log.e(FIREBASE_TAG, "Error writing document", it)
                    }
            Toast.makeText(this@StudentDetails, "updated grade for week ${position + 1} from $currentGrade to $newGrade", Toast.LENGTH_SHORT).show()
            //this@StudentDetails.grades["week$position"] = newGrade
            holder.ui.txtID.text = "$newGrade/100"
        }

        override fun onBindViewHolder(holder: StudentDetails.GradeHolder, position: Int)
        {
            val weekNum = position + 1
            val gradeType = weekConfig["week$weekNum"]
            val grade = grades["week$weekNum"].toString().toInt()

            if(!gradeAverageSet)
            {
                for((key, value) in grades)  gradeTotal += value.toString().toInt()
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