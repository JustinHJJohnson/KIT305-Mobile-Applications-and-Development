package au.edu.utas.kit305.assignment2

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import android.widget.*
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.ActivityStudentDetailsBinding
import au.edu.utas.kit305.assignment2.databinding.MyListItemBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase


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
    }

    inner class GradeHolder(var ui: MyListItemBinding) : RecyclerView.ViewHolder(ui.root) {}

    inner class GradeAdapter(private val grades: Map<String, Any>) : RecyclerView.Adapter<GradeHolder>()
    {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StudentDetails.GradeHolder
        {
            val ui = MyListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
            return GradeHolder(ui)                                                            //wrap it in a ViewHolder
        }

        override fun getItemCount(): Int
        {
            return grades.size
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

                            holder.ui.gradeLayout.addView(gradeCheckBox)
                        }

                        gradeSet[position] = true
                    }
                    "attendance" -> {
                        val gradeCheckBox = CheckBox(this@StudentDetails)
                        gradeCheckBox.text = "attendance"

                        if(grade == 100) gradeCheckBox.isChecked = true

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

                        when(grade) {
                            100 -> spinner.setSelection(0)
                            in 99 downTo 80 -> spinner.setSelection(1)
                            in 79 downTo 70 -> spinner.setSelection(2)
                            in 69 downTo 60 -> spinner.setSelection(3)
                            in 59 downTo 50 -> spinner.setSelection(4)
                            else -> spinner.setSelection(5)
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
                            100 ->  spinner.setSelection(0)
                            in 99 downTo 80 ->  spinner.setSelection(1)
                            in 79 downTo 70 ->  spinner.setSelection(2)
                            in 69 downTo 60 ->  spinner.setSelection(3)
                            else -> spinner.setSelection(4)
                        }

                        holder.ui.gradeLayout.addView(spinner)
                        gradeSet[position] = true
                    }
                    "score" -> {
                        val maxScore = weekConfig["week${weekNum}MaxScore"].toString().toInt()
                        val testText = TextView(this@StudentDetails)
                        val score = EditText(this@StudentDetails)

                        score.setText("${(grade/100.0)*maxScore}")
                        testText.text = "/$maxScore"
                        holder.ui.gradeLayout.addView(score)
                        holder.ui.gradeLayout.addView(testText)
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