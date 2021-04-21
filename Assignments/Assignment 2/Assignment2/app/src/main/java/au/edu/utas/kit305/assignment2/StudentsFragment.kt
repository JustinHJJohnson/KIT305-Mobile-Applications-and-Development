package au.edu.utas.kit305.assignment2

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.FragmentStudentBinding
import au.edu.utas.kit305.assignment2.databinding.MyListItemBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.firestore.ktx.toObject
import com.google.firebase.ktx.Firebase


class StudentsFragment : Fragment()
{
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        var inflatedView = FragmentStudentBinding.inflate(layoutInflater, container, false)

        //super.onCreate(savedInstanceState)
        //setContentView(inflatedView.root)

        inflatedView.myList.adapter = StudentAdapter(students = items)

        //vertical list
        inflatedView.myList.layoutManager = LinearLayoutManager(requireContext())

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
        //inflatedView.lblStudentCount.text = "Loading..."
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
                    (inflatedView.myList.adapter as StudentAdapter).notifyDataSetChanged()
                }
            }

        db.collection("gradesConfig").document("UK71QI0qFPiP2zcmsclx")
            .get()
            .addOnSuccessListener { result ->
                weekConfig.putAll(result.data!!)
                //Log.d(FIREBASE_TAG, "--- all grade config ---")
                //Log.d(FIREBASE_TAG, weekConfig.toString())
            }

        inflatedView.addStudentFab.setOnClickListener{
            AddStudentModal.newInstance().show(fragmentManager!!, AddStudentModal.TAG)
        }

        return inflatedView.root
    }

    inner class StudentHolder(var ui: MyListItemBinding) : RecyclerView.ViewHolder(ui.root) {}

    inner class StudentAdapter(private val students: MutableList<Student>) : RecyclerView.Adapter<StudentHolder>()
    {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StudentHolder
        {
            val ui = MyListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
            return StudentHolder(ui)                                                            //wrap it in a ViewHolder
        }

        override fun getItemCount(): Int
        {
            return students.size
        }

        override fun onBindViewHolder(holder: StudentHolder, position: Int)
        {
            val student = students[position]   //get the data at the requested position
            holder.ui.txtName.text = student.firstName + " " + student.lastName;
            holder.ui.txtID.text = student.studentID;
            //holder.lblStudentCount.text = "${students.size} Students(s)";

            holder.ui.root.setOnClickListener {
                var i = Intent(holder.ui.root.context, StudentDetails::class.java)
                i.putExtra(STUDENT_INDEX, position)
                startActivity(i)
            }
        }
    }
}