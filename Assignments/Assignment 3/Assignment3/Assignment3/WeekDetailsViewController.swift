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
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var attendanceSwitch: UISwitch!
    @IBOutlet var studentIDLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class ScoreTableViewCell: UITableViewCell
{
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var scoreTextField: UITextField!
    @IBOutlet var maxScoreLabel: UILabel!
}

class NNToHDTableViewCell: UITableViewCell
{
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var selector: UISegmentedControl!
}

class FToATableViewCell: UITableViewCell
{
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var selector: UISegmentedControl!
}

class CheckpointsTableViewCell: UITableViewCell
{
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
}

//My tableview code came fron this tutorial https://guides.codepath.com/ios/Table-View-Quickstart
//Note I made the cells in this class because I couldn't get the assistant to detect them as seperate classes so I couldn't do the binding
class WeekDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    var week: Int?
    //var allGrades: [(studentID:String, grade:Int)]?
    
    var test: Int = grades[0].grades.week
    var data: [String] = ["This", "Is", "A", "Test", "Please", "Work"]
    
    @IBOutlet var gradesView: UITableView!
    @IBOutlet var weekLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Week \(week!)"
        weekLabel.text = "Week \(week!)"
        
        gradesView.dataSource = self
        gradesView.delegate = self
        
        allGrades.removeAll()
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
                        self.allGrades.append((key, value as! Int))
                    }
                }
                
                print("\nGrades in the list:")
                for studentGrades in self.allGrades
                {
                    print("\t\(studentGrades)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return students.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //print("Week\(week!)")
        //print(weekConfigs["Week\(week!)"])
        
        let weekType = weekConfigs["week\(week!)"] as! String
        
        switch weekType
        {
            case "attendance":
                /*let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath)
                
                if let weekCell = cell as? AttendanceTableViewCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                    weekCell.attendanceSwitch.setOn(true, animated: true)
                }*/
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath) as! AttendanceTableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                
                if(allGrades[indexPath.row].grade == 100)
                {
                    cell.attendanceSwitch.setOn(true, animated: false)
                    
                }
                else
                {
                    cell.attendanceSwitch.setOn(false, animated: false)
                }
                
                return cell
            case "score":
                /*let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath)
                
                if let weekCell = cell as? ScoreTableViewCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                    weekCell.scoreTextField.text = "12"
                    weekCell.maxScoreLabel.text = "/ 50"
                }*/
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath) as! ScoreTableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.scoreTextField.text = "12"
                cell.maxScoreLabel.text = "/ 50"
                
                return cell
            case "gradeNN-HD":
                /*let cell = tableView.dequeueReusableCell(withIdentifier: "NNToHDCell", for: indexPath)
                
                if let weekCell = cell as? NNToHDTableViewCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                    weekCell.selector.setEnabled(true, forSegmentAt: 3)
                }*/
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NNToHDCell", for: indexPath) as! NNToHDTableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.selector.setEnabled(true, forSegmentAt: 3)
                
                
                return cell
            case "gradeA-F":
                /*let cell = tableView.dequeueReusableCell(withIdentifier: "FToACell", for: indexPath)
                
                if let weekCell = cell as? FToATableViewCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                    weekCell.selector.setEnabled(true, forSegmentAt: 2)
                }*/
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "FToACell", for: indexPath) as! FToATableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                cell.selector.setEnabled(true, forSegmentAt: 2)
                
                return cell
            case "checkBox":
                /*let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsCell", for: indexPath)
                
                if let weekCell = cell as? CheckpointsTableViewCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                }*/
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsCell", for: indexPath) as! CheckpointsTableViewCell
                cell.studentNameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
                cell.studentIDLabel.text = students[indexPath.row].studentID
                
                return cell
            default:
                /*let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsCell", for: indexPath)
                
                if let weekCell = cell as? CheckpointsTableViewCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Failed to find Right cell"
                }*/
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsCell", for: indexPath) as! CheckpointsTableViewCell
                cell.studentNameLabel.text = "Failed to find Right cell"
                
                return cell
        }
        
        
        
        /*let cell = tableView.dequeueReusableCell(withIdentifier: "WeekUITableViewCell", for: indexPath)

        //get the week for this row
        let student = data[indexPath.row]

        //down-cast the cell from UITableViewCell to our cell class WeekUITableViewCell
        //note, this could fail, so we use an if let.
        if let weekCell = cell as? WeekUITableViewCell
        {
            //populate the cell
            weekCell.weekLabel.text = student
        }

        return cell*/
    }

}
