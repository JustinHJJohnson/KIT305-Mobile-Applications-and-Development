//
//  SecondViewController.swift
//  MyFirstApp
//
//  Created by Joseph Holloway on 14/5/21.
//

import UIKit

class SecondViewController: UIViewController
{
    
    @IBOutlet var nameLabel: UILabel!
    var nameFromPreviousView:String?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.nameLabel.text = nameFromPreviousView

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
