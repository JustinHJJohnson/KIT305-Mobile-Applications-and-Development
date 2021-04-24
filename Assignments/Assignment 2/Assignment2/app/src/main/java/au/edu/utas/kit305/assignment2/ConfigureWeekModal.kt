package au.edu.utas.kit305.assignment2

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.View.INVISIBLE
import android.view.View.VISIBLE
import android.view.ViewGroup
import android.widget.AdapterView
import androidx.fragment.app.DialogFragment
import au.edu.utas.kit305.assignment2.databinding.ModalConfigureWeekBinding
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase


//Code for this modal was based on the code from this article https://blog.mindorks.com/implementing-dialog-fragment-in-android
//Code to pass data to this modal and back to WeekDetails from here https://code.luasoftware.com/tutorials/android/android-pass-argument-to-dialogfragment/
class ConfigureWeekModal: DialogFragment()
{
     companion object
    {
        private const val WEEK_TYPE = "weekType"
        private const val WEEK_NUM = "weekNum"

        fun newInstance(weekType: String?, weekNum: Int?): ConfigureWeekModal
        {
            val dialog = ConfigureWeekModal()
            val args = Bundle().apply {
                weekType?.let { putString(WEEK_TYPE, it) }
                weekNum?.let { putInt(WEEK_NUM, it) }
            }
            dialog.arguments = args
            return dialog
        }

    }

    var onResult: ((weekType: String, number: Int) -> Unit)? = null

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View?
    {
        val inflatedView = ModalConfigureWeekBinding.inflate(layoutInflater, container, false)
        dialog?.window?.setBackgroundDrawableResource(R.drawable.round_corners); //These rounded corners came from this post https://medium.com/swlh/alertdialog-and-customdialog-in-android-with-kotlin-f42a168c1936

        val gradeConfigs = resources.getStringArray(R.array.GradeConfigs)
        val weekType = arguments!!.getString("weekType")
        val db = Firebase.firestore

        inflatedView.spnGradeConfig.setSelection(gradeConfigs.indexOf(weekType), false)

        if(weekType == "checkBox" || weekType == "score")
        {
            inflatedView.editNumber.visibility = VISIBLE
            if(weekType == "checkBox")
            {
                inflatedView.editNumber.hint = "Number of checkboxes"
            }
            else
            {
                inflatedView.editNumber.hint = "Maximum score"
            }
        }
        else
        {
            inflatedView.editNumber.visibility = INVISIBLE
        }

        inflatedView.spnGradeConfig.onItemSelectedListener = object : AdapterView.OnItemSelectedListener
        {
            override fun onNothingSelected(parent: AdapterView<*>?) {}

            override fun onItemSelected(parent: AdapterView<*>, view: View, position: Int, id: Long)
            {
                if(position == gradeConfigs.indexOf("checkBox") || position == gradeConfigs.indexOf("score"))
                {
                    inflatedView.editNumber.visibility = VISIBLE
                    if(position == gradeConfigs.indexOf("checkBox"))
                    {
                        inflatedView.editNumber.hint = "Number of checkboxes"
                    }
                    else
                    {
                        inflatedView.editNumber.hint = "Maximum score"
                    }
                }
                else
                {
                    inflatedView.editNumber.visibility = INVISIBLE
                }
            }
        }

        inflatedView.btnConfigWeek.setOnClickListener{
            val db = Firebase.firestore

            val newWeekType = inflatedView.spnGradeConfig.selectedItem
            if(newWeekType == "checkBox" || newWeekType == "score")
            {
                onResult?.invoke(newWeekType.toString(), inflatedView.editNumber.text.toString().toInt())
            }
            else
            {
                onResult?.invoke(newWeekType.toString(), -1)
            }

            //val gradeConfigs = resources.getStringArray(R.array.GradeConfigs);

            /**/

            dismiss()
        }

        return inflatedView.root
    }

    override fun onStart()
    {
        super.onStart()
        val width = (resources.displayMetrics.widthPixels * 0.85).toInt()
        val height = (resources.displayMetrics.heightPixels * 0.40).toInt()
        dialog!!.window?.setLayout(width, ViewGroup.LayoutParams.WRAP_CONTENT)
    }
}