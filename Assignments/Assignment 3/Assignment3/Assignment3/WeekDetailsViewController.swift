//
//  WeekDetailsViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 15/5/21.
//

import UIKit
import FirebaseFirestore

// code to call the updateGrade function from the TableViewCells using delegates from here https://stackoverflow.com/questions/62013328/uitableviewcell-call-function-from-parent-tableview
protocol GradeUpdateDelegate
{
    func updateGrade(for studentID: String, inWeek week: Int, to newGrade: Int)
}

//My tableview code came fron this tutorial https://guides.codepath.com/ios/Table-View-Quickstart
class WeekDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GradeUpdateDelegate
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
        performSegue(withIdentifier: "showWeekConfigSegue", sender: sender)
    }
    
    @IBAction func unwindToWeekDetails(sender: UIStoryboardSegue)
    {
        if ((sender.source as? WeekConfigViewController) != nil)
        {
            print("Unwind segue triggered")
            weekType = (weekConfigs["week\(week!)"] as! String)
            self.gradesView.reloadData()
            self.calculateGradeAverage()
        }
    }
    
    public func updateGrade(for studentID: String, inWeek week: Int, to newGrade: Int)
    {
        // find object by property from here https://stackoverflow.com/questions/26073331/find-object-with-property-in-array/26077388
        let studentIndex = students.firstIndex(where: { $0.studentID == studentID })!
        let student = students[studentIndex]

        let db = Firestore.firestore()
        let gradeCollection = db.collection("grades")

        gradeCollection.document(studentID).updateData([
            "week\(week)": newGrade
        ]) { (err) in
            if let err = err {
                print("Error updating document: \(err)")
            }
            else
            {
                self.allGrades[studentIndex] = (studentID, newGrade)
                self.calculateGradeAverage()
                print("Grade successfully updated to \(newGrade)")
            }
        }
    }
    
    func calculateGradeAverage()
    {
        var gradeAverage = 0;
        
        for studentGrades in self.allGrades
        {
            gradeAverage += studentGrades.grade
        }
        
        gradeAverage /= self.allGrades.count
        
        switch self.weekType
        {
            case "attendance": self.gradeAverageLabel.text = "Average grade is not applicable for attendance"
                
            case "score":
                let maxScore = Double(weekConfigs["week\(self.week!)MaxScore"] as! Int)
                let scaledGrade = Int(Double(gradeAverage) / 100.0 * maxScore)
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
                let numCheckboxes = Double(weekConfigs["week\(self.week!)CheckBoxNum"] as! Int)
                let numCheckboxesComplete = Double(gradeAverage) / 100.0 * numCheckboxes
                
                self.gradeAverageLabel.text = "Average number of checkpoints complete is\n \(Int(numCheckboxesComplete.rounded(.up))) out of \(Int(numCheckboxes))"
                
            default: self.gradeAverageLabel.text = "Could not calculate average grade"
            
        }
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
                        self.allGrades.append((document.documentID, value as! Int))
                    }
                }
                
                self.calculateGradeAverage()
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
                let maxScore = Double(weekConfigs["week\(week!)MaxScore"] as! Int)
                let scaledGrade = Int(Double(rawGrade) / 100.0 * maxScore)
                
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.scoreTextField.text = String(scaledGrade)
                cell.maxScoreLabel.text = "/ \(Int(maxScore))"
                cell.week = week!
                cell.delegate = self
                
                return cell
                
            case "gradeNN-HD":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NNToHDUITableViewCell", for: indexPath) as! NNToHDUITableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.selector.selectedSegmentTintColor = UIColor.systemBlue     // For getting a blue that changes on system theme https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
                cell.week = week!
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
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.selector.selectedSegmentTintColor = UIColor.systemBlue     // For getting a blue that changes on system theme https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/
                cell.week = week!
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
                let numCheckboxes = Double(weekConfigs["week\(week!)CheckBoxNum"] as! Int)
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
                cell.delegate = self
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "WeekUITableViewCell", for: indexPath) as! WeekUITableViewCell
                cell.weekLabel.text = "Failed to find the right cell"
                
                return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showWeekConfigSegue"
        {
            //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
            guard let weekConfigViewController = segue.destination as? WeekConfigViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            switch weekType
            {
                case "score":
                    let maxScore = weekConfigs["week\(week!)MaxScore"] as! Int
                    weekConfigViewController.currentWeekConfig = (weekType!, maxScore)
                case "checkBox":
                    let numCheckBoxes = weekConfigs["week\(week!)CheckBoxNum"] as! Int
                    weekConfigViewController.currentWeekConfig = (weekType!, numCheckBoxes)
                default: weekConfigViewController.currentWeekConfig = (weekType!, 0)
                
            }
            
            weekConfigViewController.week = week
        }
    }
}
