package au.edu.utas.kit305.assignment2

import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.ActivityWeekDetailsBinding
import au.edu.utas.kit305.assignment2.databinding.MyListItemBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase

class WeekDetails : AppCompatActivity()
{
    private lateinit var ui: ActivityWeekDetailsBinding

    private val grades = mutableListOf<Pair<String, String>>()
    private val gradeSet = Array(12) { _ -> false}
    private var gradeType = ""
    private var weekNum = 0
    private var gradeTotal = 0.0
    private var gradeAverageSet = false

    override fun onCreate(savedInstanceState: Bundle?)
    {
        super.onCreate(savedInstanceState)
        ui = ActivityWeekDetailsBinding.inflate(layoutInflater)
        setContentView(ui.root)

        ui.gradeList.adapter = WeekAdapter(grades = grades)

        //vertical list
        ui.gradeList.layoutManager = LinearLayoutManager(this)

        val weekIndex = intent.getIntExtra(WEEK_INDEX, -1)
        ui.txtWeek.text = "Week $weekIndex";
        gradeType = weekConfig["week$weekIndex"].toString()
        weekNum = weekIndex

        //get db connection
        val db = Firebase.firestore

        ui.txtGrade.text = "Loading grades..."
        db.collection("grades")
            .get()
            .addOnSuccessListener { result ->
                for(i in 0 until result.size())
                {
                    val studentID = result.documents[i].id
                    var grade = result.documents[i].data!!["week$weekIndex"].toString()
                    if(grade == "null") grade = "0"
                    grades.add(i, Pair(studentID, grade))
                }

                (ui.gradeList.adapter as WeekAdapter).notifyDataSetChanged()
            }
    }

    inner class WeekHolder(var ui: MyListItemBinding) : RecyclerView.ViewHolder(ui.root) {}

    inner class WeekAdapter(private val grades: List<Pair<String, String>>) : RecyclerView.Adapter<WeekHolder>()
    {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): WeekDetails.WeekHolder
        {
            val ui = MyListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
            return WeekHolder(ui)                                                            //wrap it in a ViewHolder
        }

        override fun getItemCount(): Int
        {
            return grades.size
        }

        override fun onBindViewHolder(holder: WeekDetails.WeekHolder, position: Int)
        {
            val grade = grades[position].second.toInt()

            if(!gradeAverageSet)
            {
                for(i in 0 until items.size) gradeTotal += grades[i].second.toInt()
                ui.txtWeekAverage.text = "Grade average this week is ${"%.2f".format(gradeTotal/items.size)}%"
                gradeAverageSet = true
            }

            val db = Firebase.firestore

            ui.txtGrade.text = "Grades"
            val student = items.find{it.studentID == grades[position].first}

            holder.ui.txtName.text = "${student!!.firstName} ${student.lastName}"
            holder.ui.txtID.text = "${student.studentID}";

            val rawGradeField = TextView(this@WeekDetails)
            rawGradeField.text = "$grade/100"
            holder.ui.linearLayout.addView(rawGradeField)

            if(!gradeSet[position])
            {
                when (gradeType)
                {
                    "checkBox" -> {
                        val numCheckBoxes = weekConfig["week${weekNum}CheckBoxNum"].toString().toInt()
                        val numCheckBoxesTicked: Int = grade / (100/numCheckBoxes)

                        for(i in 1..numCheckBoxes)
                        {
                            val gradeCheckBox = CheckBox(this@WeekDetails)
                            gradeCheckBox.text = i.toString()

                            if(i <= numCheckBoxesTicked) gradeCheckBox.isChecked = true

                            holder.ui.gradeLayout.addView(gradeCheckBox)
                        }

                        gradeSet[position] = true
                    }
                    "attendance" -> {
                        val gradeCheckBox = CheckBox(this@WeekDetails)
                        gradeCheckBox.text = "attendance"

                        if(grade == 100) gradeCheckBox.isChecked = true

                        holder.ui.gradeLayout.addView(gradeCheckBox)
                        gradeSet[position] = true
                    }
                    "gradeNN-HD" -> {
                        val spinner = Spinner(this@WeekDetails)

                        val adapter = ArrayAdapter(
                            this@WeekDetails,
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
                        val spinner = Spinner(this@WeekDetails)

                        val adapter = ArrayAdapter(
                            this@WeekDetails,
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
                        val testText = TextView(this@WeekDetails)
                        val score = EditText(this@WeekDetails)

                        score.setText("${(grade/100.0)*maxScore}")
                        testText.text = "/$maxScore"
                        holder.ui.gradeLayout.addView(score)
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                    else -> {
                        val testText = TextView(this@WeekDetails)
                        testText.text = "Unsupported grade type"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                }
            }
        }
    }
}