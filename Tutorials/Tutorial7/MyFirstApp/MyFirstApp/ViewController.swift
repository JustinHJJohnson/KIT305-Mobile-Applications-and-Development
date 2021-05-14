//
//  ViewController.swift
//  MyFirstApp
//
//  Created by Justin Johnson on 14/5/21.
//

import UIKit

class ViewController: UIViewController
{

    @IBOutlet var nameField: UITextField!
    
    @IBAction func nameEntered(_ sender: Any)
    {
        print("User typed \(nameField.text!)")
        
        self.performSegue(withIdentifier: "goToSecondScreen", sender: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "goToSecondScreen"
        {
            if let secondScreen = segue.destination as? SecondViewController
            {
                secondScreen.nameFromPreviousView = nameField.text!
            }
        }
    }
}

