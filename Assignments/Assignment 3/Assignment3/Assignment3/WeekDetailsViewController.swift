//
//  WeekDetailsViewController.swift
//  Assignment3
//
//  Created by Joseph Holloway on 15/5/21.
//

import UIKit
import FirebaseFirestore

//My tableview code came fron this tutorial https://guides.codepath.com/ios/Table-View-Quickstart
//Note I made the cells in this class because I couldn't get the assistant to detect them as seperate classes so I couldn't do the binding
class WeekDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var week: Int?
    var allGrades: [(studentID:String, grade:Int)] = []
    var gradesFetched = false
    var weekType: String?
    
    @IBOutlet var gradesView: UITableView!
    @IBOutlet var gradeAverageLabel: UILabel!
    @IBAction func shareButtonClicked(_ sender: Any)
    {
        if(gradesFetched)
        {
            var shareString = "Firstname, Lastname, StudentID, Week \(week!) Grade\n"
            
            for student in allGrades
            {
                shareString.append("\(student.studentID), \(student.grade)\n")
            }
            
            let shareViewController = UIActivityViewController(activityItems: [shareString], applicationActivities:[])
            present(shareViewController, animated: true, completion: nil)
        }
        else
        {
            print("Wait")
        }
    }
    @IBAction func settingsButtonClicked(_ sender: Any)
    {
        print("Settings button clicked")
    }
    
    @objc public func updateGrade(ofGradeType gradeType: String, inWeek week: Int, withNewGrade newGrade: Int)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Week \(week!)"
        self.gradeAverageLabel.numberOfLines = 2
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
                        
                    case "checkBox":
                        let numCheckboxes = weekConfigs["week\(self.week!)CheckBoxNum"] as! Double
                        let numCheckboxesComplete = Double(gradeAverage) / 100.0 * numCheckboxes
                        
                        self.gradeAverageLabel.text = "Average number of checkpoints complete is\n \(Int(numCheckboxesComplete.rounded(.up))) out of \(Int(numCheckboxes))"
                        
                    default: self.gradeAverageLabel.text = "Could not calculate average grade"
                    
                }
                
                self.gradesView.reloadData()
                self.gradesFetched = true
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceUITableViewCell", for: indexPath) as! AttendanceUITableViewCell
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreUITableViewCell", for: indexPath) as! ScoreUITableViewCell
                let maxScore = weekConfigs["week\(week!)MaxScore"] as! Float
                let scaledGrade = Int(Float(rawGrade) / 100.0 * maxScore)
                
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.week = week!
                cell.scoreTextField.text = String(scaledGrade)
                cell.maxScoreLabel.text = "/ \(Int(maxScore))"
                
                return cell
                
            case "gradeNN-HD":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NNToHDUITableViewCell", for: indexPath) as! NNToHDUITableViewCell
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "FToAUITableViewCell", for: indexPath) as! FToAUITableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsUITableViewCell", for: indexPath) as! CheckpointsUITableViewCell
                let numCheckboxes = weekConfigs["week\(week!)CheckBoxNum"] as! Double
                let numCheckboxesComplete = Double(rawGrade) / 100.0 * numCheckboxes
                
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.checkpointStepper.autorepeat = false
                cell.checkpointStepper.minimumValue = 0.0
                cell.checkpointStepper.maximumValue = numCheckboxes
                cell.checkpointStepper.value = numCheckboxesComplete.rounded(.up)
                cell.checkpointStepper.stepValue = 1.0
                cell.numCheckpointsCompletedLabel.text = String(Int(numCheckboxesComplete.rounded(.up)))
                cell.numCheckpointsLabel.text = "/\(Int(numCheckboxes))"
                cell.week = week!
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "WeekUITableViewCell", for: indexPath) as! WeekUITableViewCell
                cell.weekLabel.text = "Failed to find the right cell"
                
                return cell
        }
    }
}
