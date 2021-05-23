//
//  AddStudentViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 21/5/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class AddStudentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet var studentImageView: UIImageView!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var studentIDField: UITextField!
    @IBOutlet var addStudentButton: UIButton!
    
    var studentImage = ""
    
    @IBAction func imageButtonClicked(_ sender: Any)
    {
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary))
        {
            print("Photo Library available")
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            print("No Photo Library available")
        }
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
            let student = Student(studentID: studentID, firstName: firstName, lastName: lastName, image: studentImage)
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
    
    // this fix thanks to Yan Gong in the Discord
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        addStudentButton.isEnabled = false
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            // Code to get and format date from https://stackoverflow.com/questions/46376823/ios-swift-get-the-current-local-time-and-date-timestamp
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let filename = "\(formatter.string(from: date)).jpg"
            
            let storage = Storage.storage()
            let imageRef = storage.reference().child("images/\(filename)")
            
            let data = image.jpegData(compressionQuality: 0.4)
            
            imageRef.putData(data!, metadata: nil) { (metadata, error) in
                if let error = error
                {
                    print("Failed to upload image: \(error)")
                    self.addStudentButton.isEnabled = true
                }
                else
                {
                    print("Uploaded image")
                    self.studentImage = "\(filename)"
                    self.addStudentButton.isEnabled = true
                }
              
            }
            
            studentImageView.image = image
            studentImageView.contentMode = .scaleAspectFill
            dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

}
