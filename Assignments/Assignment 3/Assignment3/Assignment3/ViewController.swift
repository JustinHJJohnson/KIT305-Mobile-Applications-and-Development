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
//var grades: [(studentID:String, grades:Grades)] = []

class ViewController: UIViewController
{
    var currentWeek = 11
    
    @IBOutlet var currentWeekLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        currentWeekLabel.text = "It is currently week \(currentWeek)"
        
        students.removeAll()
        let db = Firestore.firestore()
        
        let studentCollection = db.collection("students")
        print("\nGot the collection")
        
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
                
                /*print("\nStudents in the list:")
                for student in students
                {
                    print("\t\(student.firstName) \(student.lastName)")
                }*/
            }
        }
        
        let weekConfigCollection = db.collection("gradesConfig")
        print("\nGot the collection")
        
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
                
                /*print("\nWeek configs:")
                for config in weekConfigs
                {
                    print("\t\(config.key): \(config.value)")
                }*/
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

