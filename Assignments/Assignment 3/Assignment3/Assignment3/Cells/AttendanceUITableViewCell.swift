//
//  attendanceUITableViewCell.swift
//  Assignment3
//
//  Created by Justin Johnson on 20/5/21.
//

import UIKit

class AttendanceUITableViewCell: UITableViewCell
{
    var week = 0;
    var studentID: String?
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var attendanceSwitch: UISwitch!
    var delegate: GradeUpdateDelegate?
    
    @IBAction func attendanceSwitchClicked(_ sender: UISwitch)
    {
        if studentIDLabel != nil
        {
            studentID = studentIDLabel.text!
        }
        
        if(attendanceSwitch.isOn)
        {
            delegate?.updateGrade(for: studentID!, inWeek: week, to: 100)
        }
        else
        {
            delegate?.updateGrade(for: studentID!, inWeek: week, to: 0)
        }
    }
}
