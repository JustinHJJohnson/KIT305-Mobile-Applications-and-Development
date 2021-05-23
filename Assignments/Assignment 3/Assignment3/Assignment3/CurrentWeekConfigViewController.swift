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
        /*let currentDate = Date()
        // https://stackoverflow.com/questions/42294864/difference-between-2-dates-in-weeks-and-days-using-swift-3-and-xcode-8
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.weekOfMonth]
        formatter.unitsStyle = .full
        var firstInterval = formatter.string(from: selectedDate, to: currentDate)!
        var firstIntervalString = "\(firstInterval)"
        firstIntervalString.removeLast(6)
        
        print("First interval: \(firstIntervalString)")
        print("Date looks like this: \(selectedDate)")
        
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let newDate = newFormatter.date(from: "2021-04-18 06:43:00 +0000")
        var secondInterval = formatter.string(from: newDate!, to: currentDate)
        print("Second interval: \(secondInterval!.removeLast(3))")*/
        
        let db = Firestore.firestore()
        
        let gradeCollection = db.collection("gradesConfig")
        gradeCollection.document("UK71QI0qFPiP2zcmsclx").updateData([
            "startDate": "\(selectedDate)"
        ]) { (err) in
            if let err = err {
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

        // Do any additional setup after loading the view.
    }

}
