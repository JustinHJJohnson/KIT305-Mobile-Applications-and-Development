//
//  NNToHDUITableViewCell.swift
//  Assignment3
//
//  Created by mobiledev on 20/5/21.
//

import UIKit

class NNToHDUITableViewCell: UITableViewCell
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
