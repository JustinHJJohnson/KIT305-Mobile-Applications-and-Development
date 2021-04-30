package au.edu.utas.kit305.assignment2

import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Environment
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.FragmentStudentBinding
import au.edu.utas.kit305.assignment2.databinding.StudentListItemBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.firestore.ktx.toObject
import com.google.firebase.ktx.Firebase
import com.google.firebase.storage.ktx.storage
import java.io.File


class StudentsFragment : Fragment()
{
    private lateinit var ui : FragmentStudentBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        ui = FragmentStudentBinding.inflate(layoutInflater, container, false)

        ui.myList.adapter = StudentAdapter(students = items)

        //vertical list
        ui.myList.layoutManager = LinearLayoutManager(requireContext())

        //get db connection
        val db = Firebase.firestore

        var studentsCollection = db.collection("students")

        //get all students
        //inflatedView.lblStudentCount.text = "Loading..."
        studentsCollection
            .get()
            .addOnSuccessListener { result ->
                //Log.d(FIREBASE_TAG, "--- all students ---")
                for (document in result)
                {
                    //Log.d(FIREBASE_TAG, document.toString())
                    val student = document.toObject<Student>()
                    //Log.d(FIREBASE_TAG, student.toString())
                    items.add(student)
                    (ui.myList.adapter as StudentAdapter).notifyDataSetChanged()
                }
            }

        db.collection("gradesConfig").document("UK71QI0qFPiP2zcmsclx")
            .get()
            .addOnSuccessListener { result ->
                weekConfig.putAll(result.data!!)
            }

        ui.addStudentFab.setOnClickListener{
            AddStudentModal.newInstance("").show(fragmentManager!!, AddStudentModal.TAG)
        }

        return ui.root
    }

    override fun onResume()
    {
        super.onResume()

        ui.myList.adapter!!.notifyDataSetChanged()
    }

    inner class StudentHolder(var ui: StudentListItemBinding) : RecyclerView.ViewHolder(ui.root) {}

    inner class StudentAdapter(private val students: MutableList<Student>) : RecyclerView.Adapter<StudentHolder>()
    {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StudentHolder
        {
            val ui = StudentListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
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

            holder.ui.root.setOnClickListener {
                var i = Intent(holder.ui.root.context, StudentDetails::class.java)
                i.putExtra(STUDENT_INDEX, position)
                startActivity(i)
            }
        }
    }
}