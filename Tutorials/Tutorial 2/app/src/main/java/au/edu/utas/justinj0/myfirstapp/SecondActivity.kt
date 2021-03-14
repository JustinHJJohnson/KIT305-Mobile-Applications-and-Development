package au.edu.utas.justinj0.myfirstapp

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import au.edu.utas.justinj0.myfirstapp.databinding.ActivitySecondBinding

class SecondActivity : AppCompatActivity()
{
    private lateinit var ui : ActivitySecondBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ui = ActivitySecondBinding.inflate(layoutInflater)
        setContentView(ui.root)
        val name = intent.getStringExtra(USERNAME_KEY)
        ui.lblEnteredText.text = name
    }
}