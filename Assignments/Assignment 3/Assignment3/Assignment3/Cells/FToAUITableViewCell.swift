//
//  FToAUITableViewCell.swift
//  Assignment3
//
//  Created by mobiledev on 20/5/21.
//

import UIKit

class FToAUITableViewCell: UITableViewCell
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
