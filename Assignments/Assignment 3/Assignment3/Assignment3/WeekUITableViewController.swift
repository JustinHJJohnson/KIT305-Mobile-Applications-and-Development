//
//  WeekTableViewController.swift
//  Assignment3
//
//  Created by Joseph Holloway on 15/5/21.
//

import UIKit
import FirebaseFirestore

class WeekUITableViewController: UITableViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return weeks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekUITableViewCell", for: indexPath)

        //get the week for this row
        let week = weeks[indexPath.row]

        //down-cast the cell from UITableViewCell to our cell class WeekUITableViewCell
        //note, this could fail, so we use an if let.
        if let weekCell = cell as? WeekUITableViewCell
        {
            //populate the cell
            weekCell.weekLabel.text = week
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        navigationItem.title = "Weeks & Students"
        
        if segue.identifier == "showWeekDetailsSegue"
        {
            //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
            guard let detailViewController = segue.destination as? WeekDetailsViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            //down-cast from UITableViewCell to MovieUITableViewCell (this could fail if we didn’t link things up properly)
            guard let selectedWeekCell = sender as? WeekUITableViewCell else
            {
                fatalError("Unexpected sender: \( String(describing: sender))")
            }

            //get the number of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
            guard let indexPath = tableView.indexPath(for: selectedWeekCell) else
            {
                fatalError("The selected cell is not being displayed by the table")
            }

            //send it to the details screen
            let weekNum = indexPath.row + 1
            detailViewController.week = weekNum
            
            /*let db = Firestore.firestore()
            
            let gradeCollection = db.collection("grades")
            print("\nGot the grades collection")
            
            detailViewController.allGrades = []
            detailViewController.allGrades!.append(("Testname", 100))
            
            gradeCollection.getDocuments() { (result, err) in
                //check for server error
                if let err = err
                {
                    print("Error getting documents: \(err)")
                }
                else
                {
                    //loop through the results
                    for document in result!.documents
                    {
                        for (key, value) in document.data() where key == "week\(weekNum)"
                        {
                            print("Student \(document.documentID) grade: \(value)")
                            detailViewController.allGrades!.append((key, value as! Int))
                        }
                    }
                    
                    print("\nGrades in the list:")
                    for studentGrades in detailViewController.allGrades!
                    {
                        print("\t\(studentGrades)")
                    }
                }
            }*/
        }
    }

}
