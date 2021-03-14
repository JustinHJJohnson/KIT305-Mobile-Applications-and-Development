package au.edu.utas.justinj0.myfirstapp

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import au.edu.utas.justinj0.myfirstapp.databinding.ActivityMainBinding

const val USERNAME_KEY : String = "USERNAME"

class MainActivity : AppCompatActivity()
{
    private lateinit var ui : ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ui = ActivityMainBinding.inflate(layoutInflater)
        setContentView(ui.root)

        ui.btnEnter.setOnClickListener {
            val enteredText = ui.txtName.text.toString()
            val i = Intent(this, SecondActivity::class.java)
            i.putExtra(USERNAME_KEY , enteredText)
            startActivity(i)
        }
    }
}