package au.edu.utas.justinj0.kit305recyclerviewapp

import android.app.AlertDialog
import android.os.Bundle
import android.view.ViewGroup
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import au.edu.utas.justinj0.kit305recyclerviewapp.databinding.ActivityMainBinding
import au.edu.utas.justinj0.kit305recyclerviewapp.databinding.MyListItemBinding

class MainActivity : AppCompatActivity()
{
    private lateinit var ui : ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?)
    {
        super.onCreate(savedInstanceState)
        ui = ActivityMainBinding.inflate(layoutInflater)
        setContentView(ui.root)

        val items = mutableListOf<Person>(
                Person(name = "Rick", studentID = 9001, smort = true),
                Person(name = "Morty", studentID = 9, smort = true),
                Person(name = "Beth", studentID = 42, smort = true),
                Person(name = "Summer", studentID = 43, smort = true),
                Person(name = "Jerry", studentID = -1, smort = false)
        )

        ui.myList.adapter = PersonAdapter(people = items)

        //vertical list
        //ui.myList.layoutManager = LinearLayoutManager(this)
        //or if you want horizontal:
        //ui.myList.layoutManager = LinearLayoutManager(this).apply { orientation = LinearLayoutManager.HORIZONTAL }
        //or a grid layout
        ui.myList.layoutManager = GridLayoutManager(this, 3)
    }

    inner class PersonHolder(var ui: MyListItemBinding) : RecyclerView.ViewHolder(ui.root) {}
    inner class PersonAdapter(private val people: MutableList<Person>) : RecyclerView.Adapter<PersonHolder>()
    {
        override fun getItemCount(): Int
        {
            return people.size
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MainActivity.PersonHolder
        {
            val ui = MyListItemBinding.inflate(layoutInflater, parent, false)   //inflate a new row from the my_list_item.xml
            return PersonHolder(ui)                                             //wrap it in a ViewHolder
        }

        override fun onBindViewHolder(holder: MainActivity.PersonHolder, position: Int) {

            val person = people[position]   //get the data at the requested position
            holder.ui.txtName.text = person.name //set the TextView in the row we are recycling
            holder.ui.txtStudentID.text = person.studentID.toString()

            holder.itemView.setOnClickListener{
                //Code taken from https://www.journaldev.com/309/android-alert-dialog-using-kotlin#simple-alert-dialog-kotlin-code
                val alert = AlertDialog.Builder(this@MainActivity)

                with(alert)
                {
                    setTitle("Are they smort?")

                    if(people[position].smort) setMessage(people[position].name + " is smort" )
                    else setMessage(people[position].name + " is NOT smort" )

                    show()
                }
            }
        }
    }
}