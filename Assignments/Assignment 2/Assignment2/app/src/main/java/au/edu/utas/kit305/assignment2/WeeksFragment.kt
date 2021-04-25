package au.edu.utas.kit305.assignment2

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.FragmentStudentBinding
import au.edu.utas.kit305.assignment2.databinding.FragmentWeeksBinding
import au.edu.utas.kit305.assignment2.databinding.StudentListItemBinding

class WeeksFragment : Fragment()
{
    private lateinit var ui : FragmentWeeksBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        ui = FragmentWeeksBinding.inflate(layoutInflater, container, false)

        ui.myList.adapter = WeekAdapter(weeks = weeks)

        //vertical list
        ui.myList.layoutManager = LinearLayoutManager(requireContext())

        return ui.root
    }

    inner class WeekHolder(var ui: StudentListItemBinding) : RecyclerView.ViewHolder(ui.root) {}

    inner class WeekAdapter(private val weeks: MutableList<String>) : RecyclerView.Adapter<WeekHolder>()
    {
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): WeekHolder
        {
            val ui = StudentListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
            ui.linearLayout.removeView(ui.txtID)
            return WeekHolder(ui)                                                            //wrap it in a ViewHolder
        }

        override fun getItemCount(): Int
        {
            return weeks.size
        }

        override fun onBindViewHolder(holder: WeekHolder, position: Int)
        {
            holder.ui.txtName.text = weeks[position];

            holder.ui.root.setOnClickListener {
                var i = Intent(holder.ui.root.context, WeekDetails::class.java)
                i.putExtra(WEEK_INDEX, position+1)
                startActivity(i)
            }
        }
    }
}