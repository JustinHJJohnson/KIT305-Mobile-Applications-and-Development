//
//  WeekDetailsViewController.swift
//  Assignment3
//
//  Created by Joseph Holloway on 15/5/21.
//

import UIKit

class AttendanceCell: UITableViewCell
{
    @IBOutlet var weekLabel: UILabel!
    @IBOutlet var attendanceSwitch: UISwitch!
    
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

class ScoreCell: UITableViewCell
{
    @IBOutlet var weekLabel: UILabel!
    @IBOutlet var scoreTextField: UITextField!
    @IBOutlet var maxScoreLabel: UILabel!
}

class NNToHDCell: UITableViewCell
{
    @IBOutlet var weekLabel: UILabel!
    @IBOutlet var selector: UISegmentedControl!
}

class FToACell: UITableViewCell
{
    @IBOutlet var weekLabel: UILabel!
    @IBOutlet var selector: UISegmentedControl!
}

class CheckpointsCell: UITableViewCell
{
    @IBOutlet var weekLabel: UILabel!
}
//Tbaleview stuff https://stackoverflow.com/questions/30774671/uitableview-with-more-than-one-custom-cells-with-swift
class WeekDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    var week: Int?
    var data: [String] = ["This", "Is", "A", "Test", "Please", "Work"]
    
    @IBOutlet var gradesView: UITableView!
    @IBOutlet var weekLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Week \(week!)"
        weekLabel.text = "Week \(week!)"
        
        self.gradesView.delegate = self
        self.gradesView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.row
        {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceCell", for: indexPath)
                
                if let weekCell = cell as? AttendanceCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                    weekCell.attendanceSwitch.setOn(true, animated: true)
                }
                
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell", for: indexPath)
                
                if let weekCell = cell as? ScoreCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                    weekCell.scoreTextField.text = "12"
                    weekCell.maxScoreLabel.text = "/ 50"
                }
                
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "NNToHDCell", for: indexPath)
                
                if let weekCell = cell as? NNToHDCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                    weekCell.selector.setEnabled(true, forSegmentAt: 3)
                }
                
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "FToACell", for: indexPath)
                
                if let weekCell = cell as? FToACell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                    weekCell.selector.setEnabled(true, forSegmentAt: 2)
                }
                
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsCell", for: indexPath)
                
                if let weekCell = cell as? CheckpointsCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Week \(week!)"
                }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "CheckpointsCell", for: indexPath)
                
                if let weekCell = cell as? CheckpointsCell
                {
                    //populate the cell
                    weekCell.weekLabel.text = "Failed to find Right cell"
                }
                
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
