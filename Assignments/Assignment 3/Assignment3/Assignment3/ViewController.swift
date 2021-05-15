//
//  ViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/6/21.
//

import UIKit

class ViewController: UIViewController
{
    var currentWeek = 11
    
    @IBOutlet var currentWeekLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currentWeekLabel.text = "It is week \(currentWeek)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showWeekDetailsSegue"
        {
            //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
            guard let detailViewController = segue.destination as? WeekDetailsViewController else
            {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            //send it to the details screen
            detailViewController.week = currentWeek
        }
    }
}

