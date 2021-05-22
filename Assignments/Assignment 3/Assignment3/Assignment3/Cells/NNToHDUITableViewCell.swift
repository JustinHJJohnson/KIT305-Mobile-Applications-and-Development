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
    var studentID: String?
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var selector: UISegmentedControl!
    var delegate: GradeUpdateDelegate?
    
    @IBAction func changedSelection(_ sender: Any)
    {
        if studentIDLabel != nil
        {
            studentID = studentIDLabel.text!
        }
        
        switch selector.selectedSegmentIndex
        {
            case 5: delegate?.updateGrade(for: studentID!, inWeek: week, to: 100)
            case 4: delegate?.updateGrade(for: studentID!, inWeek: week, to: 80)
            case 3: delegate?.updateGrade(for: studentID!, inWeek: week, to: 70)
            case 2: delegate?.updateGrade(for: studentID!, inWeek: week, to: 60)
            case 1: delegate?.updateGrade(for: studentID!, inWeek: week, to: 50)
            default: delegate?.updateGrade(for: studentID!, inWeek: week, to: 0)
        }
    }
}
