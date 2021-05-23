//
//  CurrentWeekConfigViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 23/5/21.
//

import UIKit
import FirebaseFirestore

class CurrentWeekConfigViewController: UIViewController
{
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBAction func updateButtonPressed(_ sender: Any)
    {
        let selectedDate = datePicker.date
        
        let db = Firestore.firestore()
        let gradeCollection = db.collection("gradesConfig")

        gradeCollection.document("UK71QI0qFPiP2zcmsclx").updateData([
            "startDate": "\(selectedDate)"
        ]) { (err) in
            if let err = err
            {
                print("Error updating start date: \(err)")
            }
            else
            {
                weekConfigs["startDate"] = "\(selectedDate)"
                self.performSegue(withIdentifier: "unwindToMainScreenSegue", sender: sender)
                print("Success")
            }
        }
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        datePicker.maximumDate = Date()
    }
}
