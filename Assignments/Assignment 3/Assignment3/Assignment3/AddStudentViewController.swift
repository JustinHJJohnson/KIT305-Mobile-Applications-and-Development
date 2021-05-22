//
//  AddStudentViewController.swift
//  Assignment3
//
//  Created by Joseph Holloway on 21/5/21.
//

import UIKit
import FirebaseFirestore

class AddStudentViewController: UIViewController
{
    @IBOutlet var studentImageView: UIImageView!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var studentIDField: UITextField!
    
    @IBAction func imageButtonClicked(_ sender: Any)
    {
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any)
    {
        let firstName = firstNameField.text!
        let lastName = lastNameField.text!
        let studentID = studentIDField.text!
        
        if(firstName == "")
        {
            displayAlert(withMessage: "Please enter a first name")
        }
        else if(lastName == "")
        {
            displayAlert(withMessage: "Please enter a last name")
        }
        else if(studentID == "")
        {
            displayAlert(withMessage: "Please enter a student ID")
        }
        else if(Int(studentID) == nil || studentID.count != 6)
        {
            displayAlert(withMessage: "Please enter a 6 digit number for the student ID")
        }
        // this check for a student with the entered student ID came from here https://stackoverflow.com/questions/26073331/find-object-with-property-in-array
        else if(students.contains(where: {$0.studentID == studentID}))
        {
            displayAlert(withMessage: "A student with that ID already exists")
        }
        else
        {
            let student = Student(studentID: studentID, firstName: firstName, lastName: lastName, image: "")
            let grades = Grades(week1: 0, week2: 0, week3: 0, week4: 0, week5: 0, week6: 0, week7: 0, week8: 0, week9: 0, week10: 0, week11: 0, week12: 0)
            
            let db = Firestore.firestore()
            
            let studentCollection = db.collection("students")
            let gradesCollection = db.collection("grades")
            
            do
            {
                try studentCollection.document(studentID).setData(from: student) {err in
                    if let err = err
                    {
                        print("Failed to add student: \(err)")
                    }
                    else
                    {
                        print("student added successfully")
                    }
                }
                try gradesCollection.document(studentID).setData(from: grades) {err in
                    if let err = err
                    {
                        print("Failed to add grades: \(err)")
                    }
                    else
                    {
                        print("grades added successfully")
                    }
                }
                
                students.append(student)
                // sort by object property came from here https://stackoverflow.com/questions/24130026/swift-how-to-sort-array-of-custom-objects-by-property-value
                //Need to sort this array to ascending order so the order stays the same as the database so the right grades are given to the right student
                students.sort(by: {$0.studentID! < $1.studentID!})
                print("Sorted students: \(students)")
                self.performSegue(withIdentifier: "addStudentUnwindSegue", sender: sender)
            }
            catch let error
            {
                print("Error writing student/grades to Firestore: \(error)")
            }
        }
    }
    
    func displayAlert(withMessage message: String)
    {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

}
