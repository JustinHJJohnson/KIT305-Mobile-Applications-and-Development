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
        // #warning Incomplete implementation, return the number of rows
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
     {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentUITableViewCell", for: indexPath)

            //get the movie for this row
            let student = students[indexPath.row]

            //down-cast the cell from UITableViewCell to our cell class MovieUITableViewCell
            //note, this could fail, so we use an if let.
            if let studentCell = cell as? StudentUITableViewCell
            {
                //populate the cell
                studentCell.nameLabel.text = "\(student.firstName) \(student.lastName)"
                studentCell.studentIDLabel.text = student.studentID
            }

            return cell
    }

}