//
//  StudentUITableViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/10/21.
//

import UIKit

class StudentUITableViewController: UITableViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        navigationItem.title = "Students"
        
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
