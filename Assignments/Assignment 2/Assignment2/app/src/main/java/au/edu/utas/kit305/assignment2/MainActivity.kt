package au.edu.utas.kit305.assignment2

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.ViewGroup
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.ActivityMainBinding
import au.edu.utas.kit305.assignment2.databinding.MyListItemBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.firestore.ktx.toObject
import com.google.firebase.ktx.Firebase

const val FIREBASE_TAG = "FirebaseLogging"
const val STUDENT_INDEX = "Student_Index"

val items = mutableListOf<Student>()
val weekConfig = mutableMapOf<String, Any>()

class MainActivity : AppCompatActivity()
{
    private lateinit var ui : ActivityMainBinding

    override fun onResume() {
        super.onResume()

        ui.myList.adapter?.notifyDataSetChanged()
    }

    override fun onCreate(savedInstanceState: Bundle?)
    {
        super.onCreate(savedInstanceState)
        ui = ActivityMainBinding.inflate(layoutInflater)
        setContentView(ui.root)

        ui.myList.adapter = StudentAdapter(students = items)

        //vertical list
        ui.myList.layoutManager = LinearLayoutManager(this)

        //get db connection
        val db = Firebase.firestore

        var studentsCollection = db.collection("students")
        /*studentsCollection.document(me.studentID!!)
            .set(me)
            .addOnSuccessListener {
                Log.d(FIREBASE_TAG, "Document created with id ${me.studentID!!}")
            }
            .addOnFailureListener {
                Log.e(FIREBASE_TAG, "Error writing document", it)
            }*/

        //get all students
        ui.lblStudentCount.text = "Loading..."
        studentsCollection
            .get()
            .addOnSuccessListener { result ->
                Log.d(FIREBASE_TAG, "--- all students ---")
                for (document in result)
                {
                    //Log.d(FIREBASE_TAG, document.toString())
                    val student = document.toObject<Student>()
                    //Log.d(FIREBASE_TAG, student.toString())
                    items.add(student)
                    (ui.myList.adapter as StudentAdapter).notifyDataSetChanged()
                }
            }

        ui.addStudentFab.setOnClickListener{
            //var i = Intent(ui.root.context, AddStudent::class.java)
            startActivity(Intent(ui.root.context, AddStudent::class.java))
        }

        db.collection("gradesConfig").document("UK71QI0qFPiP2zcmsclx")
                .get()
                .addOnSuccessListener { result ->
                    weekConfig.putAll(result.data!!)
                    //Log.d(FIREBASE_TAG, "--- all grade config ---")
                    //Log.d(FIREBASE_TAG, weekConfig.toString())
                }
    }

    inner class StudentHolder(var ui: MyListItemBinding) : RecyclerView.ViewHolder(ui.root) {}

    inner class StudentAdapter(private val students: MutableList<Student>) : RecyclerView.Adapter<StudentHolder>()
    {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MainActivity.StudentHolder
        {
            val ui = MyListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
            return StudentHolder(ui)                                                            //wrap it in a ViewHolder
        }

        override fun getItemCount(): Int
        {
            return students.size
        }

        override fun onBindViewHolder(holder: MainActivity.StudentHolder, position: Int)
        {
            val student = students[position]   //get the data at the requested position
            holder.ui.txtName.text = student.firstName + " " + student.lastName;
            holder.ui.txtID.text = student.studentID;
            ui.lblStudentCount.text = "${students.size} Students(s)";

            holder.ui.root.setOnClickListener {
                var i = Intent(holder.ui.root.context, StudentDetails::class.java)
                i.putExtra(STUDENT_INDEX, position)
                startActivity(i)
            }
        }
    }
}

