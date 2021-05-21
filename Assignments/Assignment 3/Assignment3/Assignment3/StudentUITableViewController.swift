//
//  StudentUITableViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/10/21.
//

import UIKit
import FirebaseFirestore

class StudentUITableViewController: UITableViewController
{
    @IBOutlet var navigationBar: UINavigationItem!
    
    //This code was based on this https://stackoverflow.com/questions/12329895/setting-the-title-of-a-navigation-bar-inside-a-tab-bar-controller , https://stackoverflow.com/questions/45740811/how-to-run-a-function-every-time-a-uiviewcontroller-is-loaded and https://stackoverflow.com/questions/32558014/how-to-add-use-default-icons-to-navigation-bar
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        self.tabBarController?.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.action,
                target: self,
                action: #selector(shareAllStudentsButtonPressed)),
            UIBarButtonItem(
                barButtonSystemItem: UIBarButtonItem.SystemItem.add,
                target: self,
                action: #selector(addStudentButtonPressed))
        ]
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @objc
    func addStudentButtonPressed()
    {
        performSegue(withIdentifier: "showAddStudentSegue", sender: nil)
    }
    
    func deleteStudent(at indexPath: IndexPath)
    {
        let row = indexPath.row
        // alert controller stuff from here https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete \(students[row].firstName) \(students[row].lastName)?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
            let studentID = students[row].studentID!
            let db = Firestore.firestore()
            
            let studentCollection = db.collection("students")
            studentCollection.document(studentID).delete() {err in
                if let err = err
                {
                    print("Failed to remove student: \(err)")
                }
                else
                {
                    db.collection("grades").document(studentID).delete() {err in
                        if let err = err
                        {
                            print("Failed to remove student: \(err)")
                        }
                        else
                        {
                            print("student and grades deleted successfully")
                            students.remove(at: row)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }

    @objc
    func shareAllStudentsButtonPressed()
    {
        var shareString = "Firstname, Lastname, StudentID\n"
        
        for student in students
        {
            shareString.append("\(student.firstName), \(student.lastName), \(student.studentID!)\n")
        }
        
        let shareViewController = UIActivityViewController(activityItems: [shareString], applicationActivities:[])
        present(shareViewController, animated: true, completion: nil)
        
        //print(shareString)
    }

    // all code relating to swiping rows is based on this https://programmingwithswift.com/uitableviewcell-swipe-actions-with-swift/
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let action = UIContextualAction(
            style: .normal,
            title: "Delete")
            {
                [weak self] (action, view, completionHandler) in
                self?.deleteStudent(at: indexPath)
                completionHandler(true)
            }
        action.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //Makes sqiping work on iOS 13 and up
    override func tableView(_ tableView: UITableView,editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        return .none
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
     {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentUITableViewCell", for: indexPath)

            //get the movie for this row
            let student = students[indexPath.row]

            //down-cast the cell from UITableViewCell to our cell class StudentUITableViewCell
            //note, this could fail, so we use an if let.
            if let studentCell = cell as? StudentUITableViewCell
            {
                //populate the cell
                studentCell.nameLabel.text = "\(student.firstName) \(student.lastName)"
                studentCell.studentIDLabel.text = student.studentID
            }

            return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showStudentDetailsSegue"
        {
            //down-cast from UIViewController to StudentDetailViewController (this could fail if we didn’t link things up properly)
            guard let detailViewController = segue.destination as? StudentDetailsViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            //down-cast from UITableViewCell to StudentUITableViewCell (this could fail if we didn’t link things up properly)
            guard let selectedWeekCell = sender as? StudentUITableViewCell else
            {
                fatalError("Unexpected sender: \( String(describing: sender))")
            }

            //get the number of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
            guard let indexPath = tableView.indexPath(for: selectedWeekCell) else
            {
                fatalError("The selected cell is not being displayed by the table")
            }

            //send it to the details screen
            detailViewController.studentIndex = indexPath.row
        }
    }
}
