//
//  scoreUITableViewCell.swift
//  Assignment3
//
//  Created by mobiledev on 20/5/21.
//

import UIKit

class ScoreUITableViewCell: UITableViewCell
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
