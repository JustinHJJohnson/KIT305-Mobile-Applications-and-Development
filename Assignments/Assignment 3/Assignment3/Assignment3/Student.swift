//
//  Student.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/6/21.
//

import Firebase
import FirebaseFirestoreSwift

public struct Student : Codable
{
    var studentID:String?
    var firstName:String
    var lastName:String
    var image:String
}
