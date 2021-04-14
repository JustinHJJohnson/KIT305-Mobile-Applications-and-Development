package au.edu.utas.kit305.assignment2

import android.annotation.SuppressLint
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
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
        val gradesCollection = db.collection("grades").document(items[studentIndex].studentID!!)

        gradesCollection
                .get()
                .addOnSuccessListener { result ->
                    grades.putAll(result.getData()!!)
                    Log.d(FIREBASE_TAG, "--- all grades ---")
                    Log.d(FIREBASE_TAG, grades.toString())
                    (ui.gradeList.adapter as GradeAdapter).notifyDataSetChanged()
                }

        //get student object using id from intent
        var studentObject = items[studentIndex]
        ui.txtStudentName.text = "${studentObject.firstName} ${studentObject.lastName}";
        ui.txtStudentID.text = studentObject.studentID;

        /*ui.btnSave.setOnClickListener {
            //get the user input
            var name = ui.txtStudentName.text.toString().split(" ")
            studentObject.firstName = name[0]
            studentObject.lastName = name[1]
            studentObject.studentID = ui.txtStudentID.text.toString() //good code would check this is really an int

            //get db connection
            val db = Firebase.firestore
            var studentCollection = db.collection("students")

            //update the database
            studentCollection.document(studentObject.studentID!!)
                .set(studentObject)
                .addOnSuccessListener {
                    Log.d(FIREBASE_TAG, "Successfully updated movie ${studentObject?.studentID}")
                    //return to the list
                    finish()
                }
        }*/
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
            holder.ui.txtName.text = "Week ${position + 1}";
            holder.ui.txtID.text = "${grades["week${position + 1}"].toString()}/100";
            ui.txtGrade.text = "Grades"

            /*holder.ui.root.setOnClickListener {
                var i = Intent(holder.ui.root.context, StudentDetails::class.java)
                i.putExtra(STUDENT_INDEX, position)
                startActivity(i)
            }*/
        }
    }
}