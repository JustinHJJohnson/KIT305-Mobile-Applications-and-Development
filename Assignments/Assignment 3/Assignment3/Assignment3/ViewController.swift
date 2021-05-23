//
//  ViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/6/21.
//

import UIKit
import FirebaseFirestore

var students = [Student]()
var weeks:[String] = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10", "Week 11", "Week 12"]
var weekConfigs: [String: Any] = [:]

class ViewController: UIViewController
{
    var currentWeek = 1
    
    @IBOutlet var currentWeekLabel: UILabel!
    @IBOutlet var currentWeekButton: UIButton!
    
    @IBAction func unwindToMainScreen(sender: UIStoryboardSegue)
    {
        if sender.source is CurrentWeekConfigViewController
        {
            let newDateString = weekConfigs["startDate"] as! String
            
            let numWeeks = getNumWeeks(since: newDateString)
            
            currentWeekLabel.text = "It is currently week \(numWeeks)"
            currentWeek = numWeeks
        }
    }
    
    func getNumWeeks(since start: String) -> Int
    {
        // Convert the passed in date string to a date object
        let newFormatter = DateFormatter()
        newFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
        let newDate = newFormatter.date(from: start)

        // https://stackoverflow.com/questions/42294864/difference-between-2-dates-in-weeks-and-days-using-swift-3-and-xcode-8
        // Get the number of week been the current date and the passed in date
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.weekOfMonth]
        formatter.unitsStyle = .full
        let firstInterval = formatter.string(from: newDate!, to: Date())!
        var firstIntervalString = "\(firstInterval)"
        firstIntervalString.removeLast(6)
        
        var numWeeks = Int(firstIntervalString)!
        // Make sure to not go pass week 12 so it doesn't throw arrayOutOfBounds errors
        if(numWeeks > 12)
        {
            numWeeks = 12
        }
        
        return numWeeks
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        currentWeekButton.isEnabled = false
        
        students.removeAll()
        let db = Firestore.firestore()
        let studentCollection = db.collection("students")
        
        studentCollection.getDocuments() { (result, err) in
            //check for server error
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                //loop through the results
                for document in result!.documents
                {
                    //attempt to convert to Student object
                    let conversionResult = Result
                    {
                        try document.data(as: Student.self)
                    }
                    
                    //check if conversionResult is a success or failure (i.e was an exception/error thrown?)
                    switch conversionResult
                    {
                        //success, but could still be nil
                        case .success(let convertedDoc):
                            if let student = convertedDoc
                            {
                                //A Student was successfully initialized from the DocumentSnapshot
                                //print("Student: \(student)")
                                students.append(student)
                            }
                            else
                            {
                                //a nil value was successful converted to a Student, or there were no documents
                                print("Document doesn not exist")
                            }
                        
                        case .failure(let error):
                            //a Student could not be initialized from the DocumentSnapshot
                            print("Error decoding student: \(error)")
                    }
                }
            }
        }
        
        let weekConfigCollection = db.collection("gradesConfig")
        
        weekConfigCollection.getDocuments() { (result, err) in
            //check for server error
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                //loop through the results
                for document in result!.documents
                {
                    for (key, value) in document.data()
                    {
                        weekConfigs.updateValue(value, forKey: key)
                    }
                }
                
                // Set the current week label based on the date in the database
                let newDateString = weekConfigs["startDate"] as! String
                let weekNum = self.getNumWeeks(since: newDateString)
                self.currentWeek = weekNum
                self.currentWeekLabel.text = "It is currently week \(weekNum)"
                self.currentWeekButton.isEnabled = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showWeekDetailsSegue"
        {
            //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
            guard let detailViewController = segue.destination as? WeekDetailsViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            //send it to the details screen
            detailViewController.week = currentWeek
        }
    }
}

