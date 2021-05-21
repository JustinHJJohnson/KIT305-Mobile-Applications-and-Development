//
//  checkpointsUITableViewCell.swift
//  Assignment3
//
//  Created by mobiledev on 20/5/21.
//

import UIKit

class CheckpointsUITableViewCell: UITableViewCell
{

    var week = 0;
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var numCheckpointsLabel: UILabel!
    @IBOutlet var numCheckpointsCompletedLabel: UILabel!
    @IBOutlet var checkpointStepper: UIStepper!
    @IBAction func stepperChanged(_ sender: Any)
    {
        let numCheckboxes = weekConfigs["week\(self.week)CheckBoxNum"] as! Double
        let numCheckboxesCompleted = Double(Int(checkpointStepper.value))
        let newGrade = numCheckboxesCompleted / numCheckboxes * 100.0
        
        //https://stackoverflow.com/questions/24007650/selector-in-swift
        //https://learnappmaking.com/target-action-swift/
        //checkpointStepper.addTarget(self, action: #selector(WeekDetailsViewController.updateGrade(ofGradeType:inWeek:withNewGrade:)), for: .valueChanged)
        numCheckpointsCompletedLabel.text = String(Int(numCheckboxesCompleted))
        
        print("student \(studentNameLabel.text!) grade set to \(newGrade)")
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
