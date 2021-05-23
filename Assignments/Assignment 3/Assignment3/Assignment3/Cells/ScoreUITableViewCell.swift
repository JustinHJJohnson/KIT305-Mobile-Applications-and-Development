//
//  scoreUITableViewCell.swift
//  Assignment3
//
//  Created by Justin Johnson on 20/5/21.
//

import UIKit

// this code loops through the cells parent responders until it find a UIViewController, which I use to display an alert
// from https://stackoverflow.com/questions/58421761/present-alert-controller-from-table-view-cell-across-multiple-view-controllers
extension UIView
{
    var parentViewController: UIViewController?
    {
        var parentResponder: UIResponder? = self
        while parentResponder != nil
        {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController
            {
                return viewController
            }
        }
        return nil
    }
}

class ScoreUITableViewCell: UITableViewCell
{
    var week = 0;
    var studentID: String?
        
    @IBOutlet var studentNameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    @IBOutlet var scoreTextField: UITextField!
    @IBOutlet var maxScoreLabel: UILabel!
    var delegate: GradeUpdateDelegate?
    
    @IBAction func updatedGrade(_ sender: Any)
    {
        let maxScore = weekConfigs["week\(week)MaxScore"] as! Int
            
        if(Int(scoreTextField.text!) == nil)
        {
            displayAlert(withMessage: "Please only enter digits")
        }
        else
        {
            if(Int(scoreTextField.text!)! > maxScore)
            {
                scoreTextField.text = String(maxScore)
            }
            
            let rawGrade = Double(Int(scoreTextField.text!)!) / Double(maxScore) * 100.0
            
            if studentIDLabel != nil
            {
                studentID = studentIDLabel.text!
            }
            
            print("student \(studentNameLabel.text!) grade set to \(scoreTextField.text!)")
            delegate?.updateGrade(for: studentID!, inWeek: week, to: Int(rawGrade))
        }
    }
    
    func displayAlert(withMessage message: String)
    {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

        self.parentViewController?.present(alert, animated: true)
    }
}
