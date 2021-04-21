package com.example.week05tabs

import android.os.Bundle
import com.google.android.material.tabs.TabLayout
import androidx.viewpager.widget.ViewPager
import androidx.appcompat.app.AppCompatActivity

const val FIREBASE_TAG = "FirebaseLogging"
const val STUDENT_INDEX = "Student_Index"

val items = mutableListOf<Student>(
        //Student("444671", "Justin", "Johnson"),
        //Student("123456", "Bob", "Frank")
)
val weekConfig = mutableMapOf<String, Any>()

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val sectionsPagerAdapter = SectionsPagerAdapter(this, supportFragmentManager)
        val viewPager: ViewPager = findViewById(R.id.view_pager)
        viewPager.adapter = sectionsPagerAdapter
        val tabs: TabLayout = findViewById(R.id.tabs)
        tabs.setupWithViewPager(viewPager)

    }
}