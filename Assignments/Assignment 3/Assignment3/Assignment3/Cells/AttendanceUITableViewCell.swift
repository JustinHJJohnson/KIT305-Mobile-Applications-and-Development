//
//  attendanceUITableViewCell.swift
//  Assignment3
//
//  Created by mobiledev on 20/5/21.
//

import UIKit

class AttendanceUITableViewCell: UITableViewCell
{

    var week = 0;
    
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var attendanceSwitch: UISwitch!
    var delegate: GradeUpdateDelegate?
    
    @IBAction func attendanceSwitchClicked(_ sender: UISwitch)
    {
        if(attendanceSwitch.isOn)
        {
            //print("student \(studentNameLabel.text!) grade set to 100 from 0")
            delegate?.updateGrade(for: studentIDLabel.text!, inWeek: week, to: 100)
        }
        else
        {
            //print("student \(studentNameLabel.text!) grade set to 0 from 100")
            delegate?.updateGrade(for: studentIDLabel.text!, inWeek: week, to: 0)
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
