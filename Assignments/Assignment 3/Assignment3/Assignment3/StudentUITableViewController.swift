//
//  StudentUITableViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/10/21.
//

import UIKit

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
        print("Add a student")
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
