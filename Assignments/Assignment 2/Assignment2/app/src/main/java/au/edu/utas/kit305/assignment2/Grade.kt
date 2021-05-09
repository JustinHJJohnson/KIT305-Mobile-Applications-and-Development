package au.edu.utas.kit305.assignment2

import android.text.InputType
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.*
import kotlin.math.roundToInt

class Grade {
    val ATTENDANCE = 0
    val SCORE = 1
    val GRADENNHD = 2
    val GRADEFA = 3
    val CHECKBOX = 10

    var week: Int = -1
    var grade: Int = -1
    var viewType: Int = -1

    constructor(week: Int, grade: Int, viewType: String) {
        this.grade = grade
        this.week = week

        when(viewType)
        {
            "attendance" -> this.viewType = ATTENDANCE
            "gradeNN-HD" -> this.viewType = GRADENNHD
            "gradeA-F" -> this.viewType = GRADEFA
            "score" -> this.viewType = SCORE
            else -> this.viewType = CHECKBOX + viewType.toInt()
        }
    }
}