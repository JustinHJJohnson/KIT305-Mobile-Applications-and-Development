//
//  ViewController.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/6/21.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class ViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let db = Firestore.firestore()
        
        let studentCollection = db.collection("students")
        print("\nGot the collection")
        
        studentCollection.getDocuments() { (result, err) in
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
                    //attempt to convert to Student object
                    let conversionResult = Result
                    {
                        try document.data(as: Student.self)
                    }
                    
                    //check if conversionResult is a success or failure (i.e was an exception/error thrown?)
                    switch conversionResult
                    {
                        //success, but could still be nil
                        case .success(let convertedDoc):
                            if let student = convertedDoc
                            {
                                //A Student was successfully initialized from the DocumentSnapshot
                                print("Student: \(student)")
                            }
                            else
                            {
                                //a nil value was successful converted to a Student, or there were no documents
                                print("Document doesn not exist")
                            }
                        
                        case .failure(let error):
                            //a Student could not be initialized from the DocumentSnapshot
                            print("Error decoding student: \(error)")
                    }
                }
            }
        }
    }
}

