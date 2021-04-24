package au.edu.utas.kit305.assignment2

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.kit305.assignment2.databinding.FragmentWeeksBinding
import au.edu.utas.kit305.assignment2.databinding.StudentListItemBinding

val weeks = mutableListOf<String>(
    "Week 1",
    "Week 2",
    "Week 3",
    "Week 4",
    "Week 5",
    "Week 6",
    "Week 7",
    "Week 8",
    "Week 9",
    "Week 10",
    "Week 11",
    "Week 12"
)

class WeeksFragment : Fragment()
{
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        var inflatedView = FragmentWeeksBinding.inflate(layoutInflater, container, false)

        inflatedView.myList.adapter = WeekAdapter(weeks = weeks)

        //vertical list
        inflatedView.myList.layoutManager = LinearLayoutManager(requireContext())

        return inflatedView.root
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
            //val student = weeks[position]   //get the data at the requested position
            holder.ui.txtName.text = weeks[position];

            holder.ui.root.setOnClickListener {
                var i = Intent(holder.ui.root.context, WeekDetails::class.java)
                i.putExtra(WEEK_INDEX, position+1)
                startActivity(i)
            }
        }
    }
}