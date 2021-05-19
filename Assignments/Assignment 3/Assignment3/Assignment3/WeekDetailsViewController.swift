//
//  WeekDetailsViewController.swift
//  Assignment3
//
//  Created by Joseph Holloway on 15/5/21.
//

import UIKit
import FirebaseFirestore

class AttendanceTableViewCell: UITableViewCell
{
    var week = 0;
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var attendanceSwitch: UISwitch!
    @IBOutlet var studentIDLabel: UILabel!
    @IBAction func attendanceSwitchClicked(_ sender: UISwitch)
    {
        if(attendanceSwitch.isOn)
        {
            print("student \(studentNameLabel.text!) grade set to 100 from 0")
        }
        else
        {
            print("student \(studentNameLabel.text!) grade set to 0 from 100")
        }
    }
}

class ScoreTableViewCell: UITableViewCell
{
    var week = 0;
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var scoreTextField: UITextField!
    @IBOutlet var maxScoreLabel: UILabel!
    @IBAction func updatedGrade(_ sender: Any)
    {
        let maxScore = weekConfigs["week\(week)MaxScore"] as! Int
        
        if(Int(scoreTextField.text!)! > maxScore)
        {
            scoreTextField.text = String(maxScore)
        }
        
        print("student \(studentNameLabel.text!) grade set to \(scoreTextField.text!)")
    }
}

class NNToHDTableViewCell: UITableViewCell
{
    var week = 0;
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var selector: UISegmentedControl!
    @IBAction func changedSelection(_ sender: Any)
    {
        switch selector.selectedSegmentIndex
        {
            case 5: print("student \(studentNameLabel.text!) grade set to HD+")
            case 4: print("student \(studentNameLabel.text!) grade set to HD")
            case 3: print("student \(studentNameLabel.text!) grade set to DN")
            case 2: print("student \(studentNameLabel.text!) grade set to CR")
            case 1: print("student \(studentNameLabel.text!) grade set to PP")
            default: print("student \(studentNameLabel.text!) grade set to NN")
        }
    }
}

class FToATableViewCell: UITableViewCell
{
    var week = 0;
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var selector: UISegmentedControl!
    @IBAction func changedSelection(_ sender: UISegmentedControl)
    {
        switch selector.selectedSegmentIndex
        {
            case 4: print("student \(studentNameLabel.text!) grade set to A")
            case 3: print("student \(studentNameLabel.text!) grade set to B")
            case 2: print("student \(studentNameLabel.text!) grade set to C")
            case 1: print("student \(studentNameLabel.text!) grade set to D")
            default: print("student \(studentNameLabel.text!) grade set to F")
        }
    }
}

class CheckpointsTableViewCell: UITableViewCell
{
    var week = 0;
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
}

//My tableview code came fron this tutorial https://guides.codepath.com/ios/Table-View-Quickstart
//Note I made the cells in this class because I couldn't get the assistant to detect them as seperate classes so I couldn't do the binding
class WeekDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var week: Int?
    var allGrades: [(studentID:String, grade:Int)] = []
    var weekType: String?
    
    @IBOutlet var gradesView: UITableView!
    @IBOutlet var gradeAverageLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Week \(week!)"
        weekType = weekConfigs["week\(week!)"] as? String
        
        gradesView.dataSource = self
        gradesView.delegate = self
        
        let db = Firestore.firestore()
        
        let gradeCollection = db.collection("grades")
        print("\nGot the grades collection")
        
        gradeCollection.getDocuments() { (result, err) in
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
                    for (key, value) in document.data() where key == "week\(self.week!)"
                    {
                        print("Student \(document.documentID) grade: \(value)")
                        self.allGrades.append((document.documentID, value as! Int))
                    }
                }
                
                var gradeAverage = 0;
                
                print("\nGrades in the list:")
                for studentGrades in self.allGrades
                {
                    gradeAverage += studentGrades.grade
                    print("\t\(studentGrades)")
                }
                
                gradeAverage /= self.allGrades.count
                
                switch self.weekType
                {
                    case "attendance": self.gradeAverageLabel.text = "Average grade is not applicable for attendance"
                        
                    case "score":
                        let maxScore = weekConfigs["week\(self.week!)MaxScore"] as! Float
                        let scaledGrade = Int(Float(gradeAverage) / 100.0 * maxScore)
                        self.gradeAverageLabel.text = "Average score is \(scaledGrade) / \(Int(maxScore))"
                        
                    case "gradeNN-HD":
                        switch gradeAverage
                        {
                            case 100: self.gradeAverageLabel.text = "Average grade is HD+"
                            case 80..<100: self.gradeAverageLabel.text = "Average grade is HD"
                            case 70..<80: self.gradeAverageLabel.text = "Average grade is DN"
                            case 60..<70: self.gradeAverageLabel.text = "Average grade is CR"
                            case 50..<60: self.gradeAverageLabel.text = "Average grade is PP"
                            default: self.gradeAverageLabel.text = "Average grade is NN"
                        }
                        
                    case "gradeA-F":
                        switch gradeAverage
                        {
                            case 100: self.gradeAverageLabel.text = "Average grade is A"
                            case 80..<100: self.gradeAverageLabel.text = "Average grade is B"
                            case 70..<80: self.gradeAverageLabel.text = "Average grade is C"
                            case 60..<70: self.gradeAverageLabel.text = "Average grade is D"
                            default: self.gradeAverageLabel.text = "Average grade is F"
                        }
                        
                    //case "checkBox":
                        
                    default: self.gradeAverageLabel.text = "Could not calculate average grade"
                    
                }
                
                self.gradesView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return allGrades.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let rawGrade = allGrades[indexPath.row].grade
        
        switch weekType
        {
            case "attendance":
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath) as! AttendanceTableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.week = week!
                
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) as! ScoreTableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.week = week!
                
                let maxScore = weekConfigs["week\(week!)MaxScore"] as! Float
                let scaledGrade = Int(Float(rawGrade) / 100.0 * maxScore)
                cell.scoreTextField.text = String(scaledGrade)
                cell.maxScoreLabel.text = "/ \(weekConfigs["week\(week!)MaxScore"]!)"
                
                return cell
                
            case "gradeNN-HD":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NNToHDCell", for: indexPath) as! NNToHDTableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.selector.selectedSegmentTintColor = UIColor.systemBlue     // For getting a blue that changes on system theme https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
                cell.week = week!
                
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "FToACell", for: indexPath) as! FToATableViewCell
                print("initialised cell")
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                print("set student name")
                cell.studentIDLabel.text = students[indexPath.row].studentID
                print("set student ID")
                cell.selector.selectedSegmentTintColor = UIColor.systemBlue     // For getting a blue that changes on system theme https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
                cell.week = week!
                
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsCell", for: indexPath) as! CheckpointsTableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.week = week!
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsCell", for: indexPath) as! CheckpointsTableViewCell
                cell.studentNameLabel.text = "Failed to find Right cell"
                
                return cell
        }
    }
}
