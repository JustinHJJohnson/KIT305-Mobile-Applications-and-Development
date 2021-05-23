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
            //print("student \(studentNameLabel.text!) grade set to 100 from 0")
            delegate?.updateGrade(for: studentID!, inWeek: week, to: 100)
        }
        else
        {
            
            //print("student \(studentNameLabel.text!) grade set to 0 from 100")
            delegate?.updateGrade(for: studentID!, inWeek: week, to: 0)
        }
    }
}
