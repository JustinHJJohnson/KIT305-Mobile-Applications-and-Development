//
//  TabBarViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/10/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

//var students = [Student]()
//var weeks:[String] = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5", "Week 6", "Week 7", "Week 8", "Week 9", "Week 10", "Week 11", "Week 12"]

class TabBarViewController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //print("Just loading the TabBarController")
        self.navigationItem.title = "Weeks & Students"
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
