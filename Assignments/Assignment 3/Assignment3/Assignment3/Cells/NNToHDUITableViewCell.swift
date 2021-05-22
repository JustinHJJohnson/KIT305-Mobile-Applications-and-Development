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
    var delegate: GradeUpdateDelegate?
    
    @IBAction func changedSelection(_ sender: Any)
    {
        switch selector.selectedSegmentIndex
        {
            case 5: delegate?.updateGrade(for: studentIDLabel.text!, inWeek: week, to: 100)
            case 4: delegate?.updateGrade(for: studentIDLabel.text!, inWeek: week, to: 80)
            case 3: delegate?.updateGrade(for: studentIDLabel.text!, inWeek: week, to: 70)
            case 2: delegate?.updateGrade(for: studentIDLabel.text!, inWeek: week, to: 60)
            case 1: delegate?.updateGrade(for: studentIDLabel.text!, inWeek: week, to: 50)
            default: delegate?.updateGrade(for: studentIDLabel.text!, inWeek: week, to: 0)
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
