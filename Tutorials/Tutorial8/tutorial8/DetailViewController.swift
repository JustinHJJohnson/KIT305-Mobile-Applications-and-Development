//
//  DetailViewController.swift
//  tutorial8
//
//  Created by mobiledev on 29/4/21.
//

import UIKit

class DetailViewController: UIViewController {

    var movie : Movie?
    var movieIndex : Int? //used much later in tutorial
    
    @IBOutlet var titleLabel: UITextField!
    @IBOutlet var yearLabel: UITextField!
    @IBOutlet var durationLabel: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if let displayMovie = movie
        {
         self.navigationItem.title = displayMovie.title //this awesome line sets the page title
            titleLabel.text = displayMovie.title
            yearLabel.text = String(displayMovie.year)
            durationLabel.text = String(displayMovie.duration)
        }

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
