package au.edu.utas.kit305.assignment2

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import au.edu.utas.kit305.assignment2.databinding.ActivityAddStudentBinding
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase

class AddStudent : AppCompatActivity() {

    private lateinit var ui : ActivityAddStudentBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ui = ActivityAddStudentBinding.inflate(layoutInflater)
        setContentView(ui.root)

        val db = Firebase.firestore
        var studentsCollection = db.collection("students")
        var gradesCollection = db.collection("grades")

        ui.btnAddStudent.setOnClickListener {
            val studentNumber = ui.editStudentNumber.text.toString()

            val student = Student(
                firstName = ui.editFirstName.text.toString(),
                lastName = ui.editLastName.text.toString(),
                studentID = studentNumber
            )

            studentsCollection.document(studentNumber)
                .set(student)
                .addOnSuccessListener {
                    Log.d(FIREBASE_TAG, "Student created with id $studentNumber")
                }
                .addOnFailureListener {
                    Log.e(FIREBASE_TAG, "Error writing document", it)
                }

            //create a Grade object to set all the students grades to 0
            gradesCollection.document(studentNumber)
                .set(Grades())
                .addOnSuccessListener {
                    Log.d(FIREBASE_TAG, "Grades created with id $studentNumber")
                }
                .addOnFailureListener {
                    Log.e(FIREBASE_TAG, "Error writing document", it)
                }

            items.add(student)

            finish()
        }
    }
}