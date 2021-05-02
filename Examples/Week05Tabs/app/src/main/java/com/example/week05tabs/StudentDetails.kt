package com.example.week05tabs

import android.annotation.SuppressLint
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import android.widget.CheckBox
import android.widget.TextView
import androidx.core.view.updatePadding
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.week05tabs.databinding.ActivityStudentDetailsBinding
import com.example.week05tabs.databinding.MyListItemBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase


class StudentDetails : AppCompatActivity()
{
    private lateinit var ui : ActivityStudentDetailsBinding

    private val grades = mutableMapOf<String, Any>()
    private val gradeSet = Array(12) { _ -> false}

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
                    //Log.d(FIREBASE_TAG, "--- all grades ---")
                    //Log.d(FIREBASE_TAG, grades.toString())
                    (ui.gradeList.adapter as GradeAdapter).notifyDataSetChanged()
                }

        //get student object using id from intent
        var studentObject = items[studentIndex]
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
            val db = Firebase.firestore

            ui.txtGrade.text = "Grades"
            ui.txtGrade.updatePadding()
            holder.ui.txtName.text = "Week $weekNum";
            holder.ui.txtID.text = "${grades["week$weekNum"].toString()}/100";

            if(!gradeSet[position])
            {
                when (gradeType)
                {
                    "checkBox" -> {
                        var numCheckBoxes = weekConfig["week${weekNum}CheckBoxNum"].toString().toInt()
                        var numCheckBoxesTicked: Int = grade / (100/numCheckBoxes)

                        for(i in 1..numCheckBoxes)
                        {
                            var gradeCheckBox = CheckBox(this@StudentDetails)
                            gradeCheckBox.text = i.toString()
                            when(i)
                            {
                                in 0 until numCheckBoxesTicked -> {
                                    gradeCheckBox.isChecked = true
                                    gradeCheckBox.isEnabled = false
                                }
                                numCheckBoxesTicked -> gradeCheckBox.isChecked = true
                                in (numCheckBoxesTicked + 2)..20 -> gradeCheckBox.isEnabled = false
                            }

                            holder.ui.gradeLayout.addView(gradeCheckBox)
                        }

                        gradeSet[position] = true
                    }
                    "attendance" -> {
                        var gradeCheckBox = CheckBox(this@StudentDetails)
                        gradeCheckBox.text = "attendance"
                        if(grade == 100) gradeCheckBox.isChecked = true
                        gradeCheckBox.setOnClickListener{

                        }
                        holder.ui.gradeLayout.addView(gradeCheckBox)
                        gradeSet[position] = true
                    }
                    "gradeNN-HD" -> {
                        var testText = TextView(this@StudentDetails)
                        when(grade) {
                            100 -> testText.text = "HD+"
                            in 99 downTo 80 -> testText.text = "HD"
                            in 79 downTo 70 -> testText.text = "DN"
                            in 69 downTo 60 -> testText.text = "CR"
                            in 59 downTo 50 -> testText.text = "PP"
                            else -> testText.text = "NN"
                        }
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                    "gradeA-F" -> {
                        var testText = TextView(this@StudentDetails)
                        when(grade)
                        {
                            100 ->  testText.text = "A"
                            in 99 downTo 80 ->  testText.text = "B"
                            in 79 downTo 70 ->  testText.text = "C"
                            in 69 downTo 60 ->  testText.text = "D"
                            else -> testText.text = "F"
                        }
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                    "score" -> {
                        val maxScore = weekConfig["week${weekNum}MaxScore"].toString().toInt()
                        var testText = TextView(this@StudentDetails)
                        testText.text = "${(grade/100.0)*maxScore}/$maxScore"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                    else -> {
                        var testText = TextView(this@StudentDetails)
                        testText.text = "Unsupported grade type"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                }
            }

            /*holder.ui.root.setOnClickListener {
                var i = Intent(holder.ui.root.context, StudentDetails::class.java)
                i.putExtra(STUDENT_INDEX, position)
                startActivity(i)
            }*/

            /*holder.ui.gradeLayout.setOnClickListener {
                Log.d(FIREBASE_TAG, it.toString())
                when (gradeType)
                {
                    "checkBox" -> {
                        var numCheckBoxes = weekConfig["week${weekNum}CheckBoxNum"].toString().toInt()

                        for(i in 1..numCheckBoxes)
                        {
                            var gradeCheckBox = CheckBox(this@StudentDetails)
                            gradeCheckBox.text = i.toString()
                            gradeCheckBox.isEnabled = false
                            //gradeCheckBox.id = "week${weekNum}CheckBox$i"
                            holder.ui.gradeLayout.addView(gradeCheckBox)
                        }

                        gradeSet[position] = true
                    }
                    "attendance" -> {
                        var gradeCheckBox = CheckBox(this@StudentDetails)
                        gradeCheckBox.text = "attendance"
                        holder.ui.gradeLayout.addView(gradeCheckBox)
                        gradeSet[position] = true
                    }
                    "gradeNN-HD" -> {
                        var testText = TextView(this@StudentDetails)
                        testText.text = "NN-HD"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                    "gradeA-F" -> {
                        var testText = TextView(this@StudentDetails)
                        testText.text = "A-F"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                    "percentage" -> {
                        var testText = TextView(this@StudentDetails)
                        testText.text = "%"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                    else -> {
                        var testText = TextView(this@StudentDetails)
                        testText.text = "No grade"
                        holder.ui.gradeLayout.addView(testText)
                        gradeSet[position] = true
                    }
                }
            }*/
        }
    }
}