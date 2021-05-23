//
//  TabBarViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/10/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class TabBarViewController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Weeks & Students"
    }
}
