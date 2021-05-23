//
//  StudentDetailsViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 21/5/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class StudentDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GradeUpdateDelegate
{
    var studentIndex: Int?
    var studentID = ""
    var grades: Grades?
    var gradesFetched = false
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var studentIDTextField: UITextField!
    @IBOutlet var studentImage: UIImageView!
    @IBOutlet var gradeAverageLabel: UILabel!
    @IBOutlet var gradesTableView: UITableView!
    
    @IBAction func shareButtonClicked(_ sender: UIBarButtonItem)
    {
        if(gradesFetched)
        {
            let shareString =
                "Firstname, Lastname, StudentID, Week 1, Week 2, Week 3, Week 4, Week 5, Week 6, Week 7, Week 8, Week 9, Week 10, Week 11, Week 12\n\(students[studentIndex!].firstName), \(students[studentIndex!].lastName), \(students[studentIndex!].studentID!), \(grades!.week1), \(grades!.week2), \(grades!.week3), \(grades!.week4), \(grades!.week5), \(grades!.week6), \(grades!.week7), \(grades!.week8), \(grades!.week9), \(grades!.week10), \(grades!.week11), \(grades!.week12)"
            
            let shareViewController = UIActivityViewController(activityItems: [shareString], applicationActivities:[])
            present(shareViewController, animated: true, completion: nil)
        }
        else
        {
            print("Wait")
        }
    }
    
    @IBAction func updateDetailsClicked(_ sender: Any)
    {
        let oldFirstName = students[studentIndex!].firstName
        let oldLastName = students[studentIndex!].lastName
        let studentImage = students[studentIndex!].image
        let oldStudentID = studentID
        let newFirstName = firstNameTextField.text!
        let newLastName = lastNameTextField.text!
        let newStudentID = studentIDTextField.text!
        let changingStudentID = newStudentID != oldStudentID
        
        if(newFirstName == oldFirstName && newLastName == oldLastName && newStudentID == oldStudentID)
        {
            displayAlert(withMessage: "Student details are the same, make sure to change the details before trying again")
        }
        else if(newFirstName == "")
        {
            displayAlert(withMessage: "Please enter a first name")
        }
        else if(newLastName == "")
        {
            displayAlert(withMessage: "Please enter a last name")
        }
        else if(newStudentID == "")
        {
            displayAlert(withMessage: "Please enter a student ID")
        }
        else if(Int(newStudentID) == nil || newStudentID.count != 6)
        {
            displayAlert(withMessage: "Please enter a 6 digit number for the student ID")
        }
        // this check for a student with the entered student ID came from here https://stackoverflow.com/questions/26073331/find-object-with-property-in-array
        else if(students.contains(where: {$0.studentID == newStudentID}) && changingStudentID)
        {
            displayAlert(withMessage: "Another student with that ID already exists")
        }
        else
        {
            let student = Student(studentID: newStudentID, firstName: newFirstName, lastName: newLastName, image: studentImage)
            
            let db = Firestore.firestore()
            let studentCollection = db.collection("students")
            let gradesCollection = db.collection("grades")
            
            do
            {
                try studentCollection.document(newStudentID).setData(from: student) {err in
                    if let err = err
                    {
                        print("Failed to add student: \(err)")
                    }
                    else
                    {
                        print("student added successfully")
                    }
                }
                try gradesCollection.document(newStudentID).setData(from: grades) {err in
                    if let err = err
                    {
                        print("Failed to add grades: \(err)")
                    }
                    else
                    {
                        print("grades added successfully")
                    }
                }
                
                students[studentIndex!] = student
                // Sort by object property came from here https://stackoverflow.com/questions/24130026/swift-how-to-sort-array-of-custom-objects-by-property-value
                // Need to sort this array to ascending order so the order stays the same as the database so the right grades are given to the right student
                students.sort(by: {$0.studentID! < $1.studentID!})
                
                if(changingStudentID)
                {
                    studentCollection.document(oldStudentID).delete() {err in
                        if let err = err
                        {
                            print("Failed to remove student: \(err)")
                        }
                        else
                        {
                            db.collection("grades").document(oldStudentID).delete() {err in
                                if let err = err
                                {
                                    print("Failed to remove student: \(err)")
                                }
                                else
                                {
                                    print("student and grades deleted successfully")
                                    self.displayAlert(withMessage: "Successfully updated student details")
                                    self.studentID = newStudentID
                                }
                            }
                        }
                    }
                }
                else
                {
                    self.displayAlert(withMessage: "Successfully updated student details")
                }
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
    
    public func updateGrade(for studentID: String, inWeek week: Int, to newGrade: Int)
    {
        let student = students[studentIndex!]
        let db = Firestore.firestore()
        
        print("Updating grade for \(student.firstName) \(student.lastName) for week \(week) to \(newGrade)")
        
        let gradeCollection = db.collection("grades")
        gradeCollection.document(studentID).updateData([
            "week\(week)": newGrade
        ]) { (err) in
            if let err = err
            {
                print("Error updating document: \(err)")
            }
            else
            {
                switch week
                {
                    case 1: self.grades!.week1 = newGrade
                    case 2: self.grades!.week2 = newGrade
                    case 3: self.grades!.week3 = newGrade
                    case 4: self.grades!.week4 = newGrade
                    case 5: self.grades!.week5 = newGrade
                    case 6: self.grades!.week6 = newGrade
                    case 7: self.grades!.week7 = newGrade
                    case 8: self.grades!.week8 = newGrade
                    case 9: self.grades!.week9 = newGrade
                    case 10: self.grades!.week10 = newGrade
                    case 11: self.grades!.week11 = newGrade
                    case 12: self.grades!.week12 = newGrade
                    default: print()
                }
                self.calculateGradeAverage()
                print("Grade successfully updated to \(newGrade)")
            }
        }
    }
    
    func calculateGradeAverage()
    {
        // Was getting an error about the complier not being able to type check in time when adding all these in one go, I assume this is due to 
        // the machine I was working on being a dual-core
        let gradeSum1 = self.grades!.week1 + self.grades!.week2 + self.grades!.week3
        let gradeSum2 = self.grades!.week4 + self.grades!.week5 + self.grades!.week6
        let gradeSum3 = self.grades!.week7 + self.grades!.week8 + self.grades!.week9
        let gradeSum4 = self.grades!.week10 + self.grades!.week11 + self.grades!.week12
        let gradeSum = gradeSum1 + gradeSum2 + gradeSum3 + gradeSum4
        let gradeAverage = gradeSum / 12
        self.gradeAverageLabel.text = "This students average grade is \(gradeAverage)%"
    }
    
    // Load function came from here https://stackoverflow.com/questions/37574689/how-to-load-image-from-local-path-ios-swift-by-path
    private func load(fileURL: URL) -> UIImage?
    {
        print("Loading image")
        do
        {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        }
        catch
        {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Student Details"
        
        studentID = students[studentIndex!].studentID!
        gradesTableView.delegate = self
        gradesTableView.dataSource = self
        
        let studentImageURL = students[studentIndex!].image
        if (studentImageURL != "")
        {
            let storage = Storage.storage()
            let imageFirestorePath = "images/\(studentImageURL)"
            let imageRef = storage.reference(withPath: imageFirestorePath)
            imageRef.getData(maxSize: 10 * 1024 * 1024, completion: {data, error in
                if let error = error
                {
                    print("Failed to download image: \(error)")
                }
                else
                {
                    print("Loaded image")
                    self.studentImage.image = UIImage(data: data!)
                }
            })
        }

        let db = Firestore.firestore()
        let gradeCollection = db.collection("grades").document(studentID)
        
        gradeCollection.getDocument() { (result, err) in
            //check for server error
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                //attempt to convert to Grades object
                let conversionResult = Result
                {
                    try result!.data(as: Grades.self)
                }
                    
                //check if conversionResult is a success or failure (i.e was an exception/error thrown?)
                switch conversionResult
                {
                    //success, but could still be nil
                    case .success(let convertedDoc):
                        if let grades = convertedDoc
                        {
                            //A Grades object was successfully initialized from the DocumentSnapshot
                            //print("Grades: \(grades)")
                            self.grades = grades
                        }
                        else
                        {
                            //a nil value was successful converted to a Grades object, or there were no documents
                            print("Document doesn not exist")
                        }
                        
                    case .failure(let error):
                        //a Grades object could not be initialized from the DocumentSnapshot
                        print("Error decoding grades: \(error)")
                }
                
                self.calculateGradeAverage()
                self.gradesFetched = true
                self.gradesTableView.reloadData()
            }
        }
        
        firstNameTextField.text = students[studentIndex!].firstName
        lastNameTextField.text = students[studentIndex!].lastName
        studentIDTextField.text = students[studentIndex!].studentID
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(gradesFetched)
        {
            return weeks.count
        }
        else
        {
            return 0
        } 
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let week = indexPath.row + 1
        var rawGrade = 0

        switch indexPath.row
        {
            case 0: rawGrade = grades!.week1
            case 1: rawGrade = grades!.week2
            case 2: rawGrade = grades!.week3
            case 3: rawGrade = grades!.week4
            case 4: rawGrade = grades!.week5
            case 5: rawGrade = grades!.week6
            case 6: rawGrade = grades!.week7
            case 7: rawGrade = grades!.week8
            case 8: rawGrade = grades!.week9
            case 9: rawGrade = grades!.week10
            case 10: rawGrade = grades!.week11
            case 11: rawGrade = grades!.week12
            default: rawGrade = 0
        }
        
        let weekType = weekConfigs["week\(week)"] as! String
        
        switch weekType
        {
            case "attendance":
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceUITableViewCell", for: indexPath) as! AttendanceUITableViewCell
                cell.studentNameLabel.text = "Week \(week)"
                cell.week = week
                cell.studentID = studentID
                cell.delegate = self
                
                if(rawGrade == 100)
                {
                    cell.attendanceSwitch.setOn(true, animated: false)
                    
                }
                else
                {
                    cell.attendanceSwitch.setOn(false, animated: false)
                }
                
                return cell
                
            case "score":
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreUITableViewCell", for: indexPath) as! ScoreUITableViewCell
                let maxScore = weekConfigs["week\(week)MaxScore"] as! Float
                let scaledGrade = Int(Float(rawGrade) / 100.0 * maxScore)
                
                cell.studentNameLabel.text = "Week \(week)"
                cell.scoreTextField.text = String(scaledGrade)
                cell.maxScoreLabel.text = "/ \(Int(maxScore))"
                cell.week = week
                cell.studentID = studentID
                cell.delegate = self
                
                return cell
                
            case "gradeNN-HD":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NNToHDUITableViewCell", for: indexPath) as! NNToHDUITableViewCell
                cell.studentNameLabel.text = "Week \(week)"
                cell.selector.selectedSegmentTintColor = UIColor.systemBlue     // For getting a blue that changes on system theme https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
                cell.week = week
                cell.studentID = studentID
                cell.delegate = self
                
                // For having a switch statement use ranges as cases https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html
                switch rawGrade
                {
                    case 100: cell.selector.selectedSegmentIndex = 5
                    case 80..<100: cell.selector.selectedSegmentIndex = 4
                    case 70..<80: cell.selector.selectedSegmentIndex = 3
                    case 60..<70: cell.selector.selectedSegmentIndex = 2
                    case 50..<60: cell.selector.selectedSegmentIndex = 1
                    default: cell.selector.selectedSegmentIndex = 0
                }
                
                return cell
                
            case "gradeA-F":
                let cell = tableView.dequeueReusableCell(withIdentifier: "FToAUITableViewCell", for: indexPath) as! FToAUITableViewCell
                cell.studentNameLabel.text = "Week \(week)"
                cell.selector.selectedSegmentTintColor = UIColor.systemBlue     // For getting a blue that changes on system theme https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
                cell.week = week
                cell.studentID = studentID
                cell.delegate = self
                
                switch rawGrade
                {
                    case 100: cell.selector.selectedSegmentIndex = 4
                    case 80..<100: cell.selector.selectedSegmentIndex = 3
                    case 70..<80: cell.selector.selectedSegmentIndex = 2
                    case 60..<70: cell.selector.selectedSegmentIndex = 1
                    default: cell.selector.selectedSegmentIndex = 0
                }
                
                return cell
                
            case "checkBox":
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsUITableViewCell", for: indexPath) as! CheckpointsUITableViewCell
                let numCheckboxes = weekConfigs["week\(week)CheckBoxNum"] as! Double
                let numCheckboxesComplete = Double(rawGrade) / 100.0 * numCheckboxes
                
                cell.studentNameLabel.text = "Week \(week)"
                cell.checkpointStepper.autorepeat = false
                cell.checkpointStepper.minimumValue = 0.0
                cell.checkpointStepper.maximumValue = numCheckboxes
                cell.checkpointStepper.value = numCheckboxesComplete.rounded(.up)
                cell.checkpointStepper.stepValue = 1.0
                cell.numCheckpointsCompletedLabel.text = String(Int(numCheckboxesComplete.rounded(.up)))
                cell.numCheckpointsLabel.text = "/\(Int(numCheckboxes))"
                cell.week = week
                cell.studentID = studentID
                cell.delegate = self
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "WeekUITableViewCell", for: indexPath) as! WeekUITableViewCell
                cell.weekLabel.text = "Failed to find the right cell"
                
                return cell
        }
    }
}
