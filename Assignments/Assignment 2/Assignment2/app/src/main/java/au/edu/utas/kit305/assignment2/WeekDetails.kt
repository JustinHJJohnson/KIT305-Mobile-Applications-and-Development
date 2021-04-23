package au.edu.utas.kit305.assignment2

import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.updatePadding
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.ActivityWeekDetailsBinding
import au.edu.utas.kit305.assignment2.databinding.MyListItemBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.firestore.ktx.getField
import com.google.firebase.ktx.Firebase

class WeekDetails : AppCompatActivity()
{
    private lateinit var ui: ActivityWeekDetailsBinding

    private val grades = mutableListOf<Pair<String, String>>()
    private val gradeSet = Array(12) { _ -> false}
    private var gradeType = ""
    private var weekNum = 0

    override fun onCreate(savedInstanceState: Bundle?)
    {
        super.onCreate(savedInstanceState)
        ui = ActivityWeekDetailsBinding.inflate(layoutInflater)
        setContentView(ui.root)

        ui.gradeList.adapter = WeekAdapter(grades = grades)

        //vertical list
        ui.gradeList.layoutManager = LinearLayoutManager(this)

        val weekIndex = intent.getIntExtra(WEEK_INDEX, -1)
        gradeType = weekConfig["week$weekIndex"].toString()
        weekNum = weekIndex
        //Log.d(FIREBASE_TAG, "week clicked is $weekIndex")

        //get db connection
        val db = Firebase.firestore

        ui.txtGrade.text = "Loading grades..."
        db.collection("grades")
            .get()
            .addOnSuccessListener { result ->
                Log.d(FIREBASE_TAG, "number of documents in result is ${result.size()}")
                for(i in 0 until result.size())
                {
                    //Log.d(FIREBASE_TAG, "Initial grade for $i ${result.documents[i].id} is ${result.documents[i].data!!["week$weekIndex"]}")
                    grades.add(i, Pair(result.documents[i].id, result.documents[i].data!!["week$weekIndex"].toString()))
                }

                //Log.d(FIREBASE_TAG, "--- all grades ---")
                //Log.d(FIREBASE_TAG, grades.toString())
                (ui.gradeList.adapter as WeekAdapter).notifyDataSetChanged()
            }

        //get student object using id from intent
        //var studentObject = items[studentIndex]
        ui.txtWeek.text = "Week $weekIndex";
        //ui.txtStudentID.text = studentObject.studentID;
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
            //val gradeType = weekConfig["week$week"]
            val grade = grades[position].second.toInt()
            val db = Firebase.firestore

            ui.txtGrade.text = "Grades"
            //ui.txtGrade.updatePadding()
            val studentID = items.find{it.studentID == grades[position].first}!!.studentID
            holder.ui.txtName.text = "$studentID";
            holder.ui.txtID.text = "$grade/100";

            if(!gradeSet[position])
            {
                when (gradeType)
                {
                    "checkBox" -> {
                        var numCheckBoxes = weekConfig["week${weekNum}CheckBoxNum"].toString().toInt()
                        var numCheckBoxesTicked: Int = grade / (100/numCheckBoxes)

                        for(i in 1..numCheckBoxes)
                        {
                            var gradeCheckBox = CheckBox(this@WeekDetails)
                            gradeCheckBox.text = i.toString()

                            if(i <= numCheckBoxesTicked) gradeCheckBox.isChecked = true

                            holder.ui.gradeLayout.addView(gradeCheckBox)
                        }

                        gradeSet[position] = true
                    }
                    "attendance" -> {
                        var gradeCheckBox = CheckBox(this@WeekDetails)
                        gradeCheckBox.text = "attendance"

                        if(grade == 100) gradeCheckBox.isChecked = true

                        holder.ui.gradeLayout.addView(gradeCheckBox)
                        gradeSet[position] = true
                    }
                    "gradeNN-HD" -> {
                        var spinner = Spinner(this@WeekDetails)

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
                        var spinner = Spinner(this@WeekDetails)

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
                        var testText = TextView(this@WeekDetails)
                        var score = EditText(this@WeekDetails)

                        score.setText("${(grade/100.0)*maxScore}")
                        testText.text = "/$maxScore"
                        holder.ui.gradeLayout.addView(score)
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                    else -> {
                        var testText = TextView(this@WeekDetails)
                        testText.text = "Unsupported grade type"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                }
            }
        }
    }
}