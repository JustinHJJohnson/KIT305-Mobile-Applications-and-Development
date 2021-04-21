package au.edu.utas.kit305.assignment2

import android.os.Bundle
import com.google.android.material.tabs.TabLayout
import androidx.viewpager.widget.ViewPager
import androidx.appcompat.app.AppCompatActivity
//import au.edu.utas.kit305.assignment2.databinding.ActivityMainBinding
//import com.google.firebase.FirebaseApp

const val FIREBASE_TAG = "FirebaseLogging"
const val STUDENT_INDEX = "Student_Index"

val items = mutableListOf<Student>()
val weekConfig = mutableMapOf<String, Any>()


class MainActivity : AppCompatActivity()
{
    override fun onCreate(savedInstanceState: Bundle?)
    {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val sectionsPagerAdapter = SectionsPagerAdapter(this, supportFragmentManager)
        val viewPager: ViewPager = findViewById(R.id.view_pager)
        viewPager.adapter = sectionsPagerAdapter
        val tabs: TabLayout = findViewById(R.id.tabs)
        tabs.setupWithViewPager(viewPager)
    }
}