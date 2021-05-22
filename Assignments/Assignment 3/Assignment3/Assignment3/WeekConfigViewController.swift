//
//  WeekConfigViewController.swift
//  Assignment3
//
//  Created by Joseph Holloway on 22/5/21.
//

import UIKit
import FirebaseFirestore

class WeekConfigViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    // UIPicker stuff from here https://medium.com/@javedmultani16/uipickerview-swift-b4561823e66a
    @IBOutlet var pickerView: UIPickerView!
    
    var week: Int?
    var secondColumnEnable = true
    var currentWeekConfig: (String, Int)?
    // array of formatted and non-formatted config names
    let weekConfigTuples = [
        ("Attendance", "attendance"),
        ("Score", "score"),
        ("Check Points", "checkBox"),
        ("Grade NN to HD+", "gradeNN-HD"),
        ("Grade F to A", "gradeA-F")
    ]
    // array of numbers from 1 to 100 to select for max score or number of check points
    let numOptions = Array(1...100)
    
    @IBAction func saveButtonClicked(_ sender: Any)
    {
        let newWeekConfig = weekConfigTuples[pickerView.selectedRow(inComponent: 0)]
        
        let db = Firestore.firestore()
        
        let gradeConfigDocument = db.collection("gradesConfig").document("UK71QI0qFPiP2zcmsclx")
        
        if(currentWeekConfig!.0 == "score")
        {
            gradeConfigDocument.updateData([
                "week\(week!)MaxScore": FieldValue.delete()
            ]) { (err) in
                if let err = err {
                    print("Error deleting field: \(err)")
                }
                else
                {
                    print("Successfully removed week\(self.week!)MaxScore field")
                }
            }
            weekConfigs.removeValue(forKey: "week\(week!)MaxScore")
        }
        else if(currentWeekConfig!.0 == "checkBox")
        {
            gradeConfigDocument.updateData([
                "week\(week!)CheckBoxNum": FieldValue.delete()
            ]) { (err) in
                if let err = err {
                    print("Error deleting field: \(err)")
                }
                else
                {
                    print("Successfully removed week\(self.week!)CheckBoxNum field")
                }
            }
            weekConfigs.removeValue(forKey: "week\(week!)CheckBoxNum")
        }
        
        weekConfigs["week\(week!)"] = newWeekConfig.1
        
        if(newWeekConfig.1 == "score")
        {
            let newMax = pickerView.selectedRow(inComponent: 1) + 1
            gradeConfigDocument.updateData([
                "week\(week!)MaxScore": newMax,
                "week\(week!)": newWeekConfig.1
            ]) { (err) in
                if let err = err {
                    print("Error updating field: \(err)")
                }
                else
                {
                    print("Successfully changed week\(self.week!)MaxScore field to \(newMax)")
                }
            }
            weekConfigs["week\(week!)MaxScore"] = newMax
        }
        else if(newWeekConfig.1 == "checkBox")
        {
            let newCheckBoxNum = pickerView.selectedRow(inComponent: 1) + 1
            gradeConfigDocument.updateData([
                "week\(week!)CheckBoxNum": newCheckBoxNum,
                "week\(week!)": newWeekConfig.1
            ]) { (err) in
                if let err = err {
                    print("Error updating field: \(err)")
                }
                else
                {
                    print("Successfully changed week\(self.week!)CheckBoxNum field to \(newCheckBoxNum)")
                }
            }
            weekConfigs["week\(week!)CheckBoxNum"] = newCheckBoxNum
        }
        
        self.performSegue(withIdentifier: "gradeConfigUnwindSegue", sender: sender)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        switch component
        {
            case 0: return weekConfigTuples.count
            case 1:
                if(secondColumnEnable)
                {
                    return numOptions.count
                }
                else
                {
                    return 0
                }
            default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        switch component
        {
            case 0: return weekConfigTuples[row].0
            case 1: return String(numOptions[row])
            default: return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(component == 0)
        {
            let weekConfigSelected = weekConfigTuples[row].0
            if(weekConfigSelected == "Score" || weekConfigSelected == "Check Points")
            {
                secondColumnEnable = true
            }
            else
            {
                secondColumnEnable = false
            }
            
            pickerView.reloadComponent(1)
        }
        
    }

    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.pickerView.dataSource = self
        self.pickerView.delegate = self
        
        if(currentWeekConfig!.0 == "score" || currentWeekConfig!.0 == "checkBox")
        {
            secondColumnEnable = true
        }
        else
        {
            secondColumnEnable = false
        }
        
        let weekConfigIndex = weekConfigTuples.firstIndex(where: { $0.1 == currentWeekConfig!.0})!
        
        pickerView.selectRow(weekConfigIndex, inComponent: 0, animated: true)
        if(secondColumnEnable)
        {
            pickerView.selectRow(currentWeekConfig!.1, inComponent: 1, animated: true)
        }

        // Do any additional setup after loading the view.
    }

}
