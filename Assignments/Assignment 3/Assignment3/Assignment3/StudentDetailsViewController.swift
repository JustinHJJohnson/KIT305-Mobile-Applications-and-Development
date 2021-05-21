//
//  StudentDetailsViewController.swift
//  Assignment3
//
//  Created by Joseph Holloway on 21/5/21.
//

import UIKit
import FirebaseFirestore

class StudentDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Student Details"
        
        studentID = students[studentIndex!].studentID!
        gradesTableView.delegate = self
        gradesTableView.dataSource = self

        let db = Firestore.firestore()
        
        let gradeCollection = db.collection("grades").document(studentID)
        print("\nGot the document")
        
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
                            print("Grades: \(grades)")
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
                
                print("\nGrades in the instance variable:\n\(self.grades!)")
                let gradeSum1 = self.grades!.week1 + self.grades!.week2 + self.grades!.week3
                let gradeSum2 = self.grades!.week4 + self.grades!.week5 + self.grades!.week6
                let gradeSum3 = self.grades!.week7 + self.grades!.week8 + self.grades!.week9
                let gradeSum4 = self.grades!.week10 + self.grades!.week11 + self.grades!.week12
                let gradeSum = gradeSum1 + gradeSum2 + gradeSum3 + gradeSum4
                let gradeAverage = gradeSum / 12
                self.gradeAverageLabel.text = "This students average grade is \(gradeAverage)%"
                
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
                cell.week = week
                cell.scoreTextField.text = String(scaledGrade)
                cell.maxScoreLabel.text = "/ \(Int(maxScore))"
                
                return cell
                
            case "gradeNN-HD":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NNToHDUITableViewCell", for: indexPath) as! NNToHDUITableViewCell
                cell.studentNameLabel.text = "Week \(week)"
                cell.selector.selectedSegmentTintColor = UIColor.systemBlue     // For getting a blue that changes on system theme https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
                cell.week = week
                
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
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "WeekUITableViewCell", for: indexPath) as! WeekUITableViewCell
                cell.weekLabel.text = "Failed to find the right cell"
                
                return cell
        }
    }
}
