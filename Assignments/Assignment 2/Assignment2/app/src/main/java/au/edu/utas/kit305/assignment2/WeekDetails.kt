package au.edu.utas.kit305.assignment2

import android.os.Bundle
import android.text.InputType
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.ActivityWeekDetailsBinding
import au.edu.utas.kit305.assignment2.databinding.WeekListItemBinding
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import kotlin.math.roundToInt


class WeekDetails : AppCompatActivity()
{
    private lateinit var ui: ActivityWeekDetailsBinding

    private var grades = mutableListOf<Pair<String, String>>()
    private val gradeSet = Array(12) { _ -> false}
    private var weekType = ""
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
        weekType = weekConfig["week$weekIndex"].toString()
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

        ui.btnConfigureWeek.setOnClickListener {
            val dialog = ConfigureWeekModal.newInstance(weekType, weekNum)
            dialog.onResult = {newWeekType, number ->
                when(newWeekType)
                {
                    "checkBox" -> {
                        db.collection("gradesConfig").document("UK71QI0qFPiP2zcmsclx")
                                .update(mapOf("week$weekNum" to newWeekType, "week${weekNum}CheckBoxNum" to number, "week${weekNum}MaxScore" to FieldValue.delete()))
                        weekConfig.remove("week${weekNum}MaxScore")
                        weekConfig["week$weekNum"] = newWeekType
                        weekConfig["week${weekNum}CheckBoxNum"] = number
                    }
                    "score" -> {
                        db.collection("gradesConfig").document("UK71QI0qFPiP2zcmsclx")
                                .update(mapOf("week$weekNum" to newWeekType, "week${weekNum}MaxScore" to number, "week${weekNum}CheckBoxNum" to FieldValue.delete()))
                        weekConfig.remove("week${weekNum}CheckBoxNum")
                        weekConfig["week$weekNum"] = newWeekType
                        weekConfig["week${weekNum}MaxScore"] = number
                    }
                    else -> {
                        db.collection("gradesConfig").document("UK71QI0qFPiP2zcmsclx")
                                .update(mapOf("week$weekNum" to newWeekType, "week${weekNum}CheckBoxNum" to FieldValue.delete(), "week${weekNum}MaxScore" to FieldValue.delete()))
                        weekConfig.remove("week${weekNum}MaxScore")
                        weekConfig.remove("week${weekNum}CheckBoxNum")
                        weekConfig["week$weekNum"] = newWeekType
                    }
                }

                weekType = newWeekType

                for(i in gradeSet.indices) { gradeSet[i] = false }
                ui.gradeList.adapter!!.notifyDataSetChanged()
            }
            dialog.show(supportFragmentManager, "WeekConfigModal")
        }
    }

    inner class WeekHolder(var ui: WeekListItemBinding) : RecyclerView.ViewHolder(ui.root) {}

    inner class WeekAdapter(private val grades: List<Pair<String, String>>) : RecyclerView.Adapter<WeekHolder>()
    {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): WeekDetails.WeekHolder
        {
            val ui = WeekListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
            return WeekHolder(ui)   //wrap it in a ViewHolder
        }

        override fun getItemCount(): Int
        {
            return grades.size
        }

        private fun changeGrade(newGrade: Int, holder: WeekDetails.WeekHolder, position: Int, db: FirebaseFirestore)
        {
            val currentGrade = holder.ui.txtRawGrade.text.toString().substringBefore('/').toInt()
            gradeTotal = gradeTotal - currentGrade + newGrade
            ui.txtWeekAverage.text = "Average grade is ${"%.2f".format(gradeTotal/items.size)}%"
            db.collection("grades").document(holder.ui.txtID.text.toString())
                    .update("week$weekNum", newGrade)
                    .addOnSuccessListener {
                        Log.d(FIREBASE_TAG, "successfully updated grade for week $weekNum from $currentGrade to $newGrade")
                    }
                    .addOnFailureListener {
                        Log.e(FIREBASE_TAG, "Error writing document", it)
                    }
            Toast.makeText(this@WeekDetails, "updated grade for week $weekNum from $currentGrade to $newGrade", Toast.LENGTH_SHORT).show()
            //this@StudentDetails.grades["week$position"] = newGrade
            holder.ui.txtRawGrade.text = "$newGrade/100"
        }

        override fun onBindViewHolder(holder: WeekDetails.WeekHolder, position: Int)
        {
            val grade = grades[position].second.toInt()

            holder.ui.gradeLayout.removeAllViews()

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

            holder.ui.txtRawGrade.text = "$grade/100"

            if(!gradeSet[position])
            {
                when (weekType)
                {
                    "checkBox" -> {
                        val numCheckBoxes = weekConfig["week${weekNum}CheckBoxNum"].toString().toInt()
                        val numCheckBoxesTicked: Int = grade / (100/numCheckBoxes)

                        for(i in 1..numCheckBoxes)
                        {
                            val gradeCheckBox = CheckBox(this@WeekDetails)
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
                        val gradeCheckBox = CheckBox(this@WeekDetails)
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
                        val spinner = Spinner(this@WeekDetails)

                        val adapter = ArrayAdapter(
                            this@WeekDetails,
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
                        val spinner = Spinner(this@WeekDetails)

                        val adapter = ArrayAdapter(
                            this@WeekDetails,
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
                        val scoreText = TextView(this@WeekDetails)
                        val scoreEdit = EditText(this@WeekDetails)

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