//
//  Grades.swift
//  Assignment3
//
//  Created by Justin Johnson on 18/5/21.
//

import Firebase
import FirebaseFirestoreSwift

public struct Grades : Codable
{
    @DocumentID var id:String?
    var week1:Int
    var week2:Int
    var week3:Int
    var week4:Int
    var week5:Int
    var week6:Int
    var week7:Int
    var week8:Int
    var week9:Int
    var week10:Int
    var week11:Int
    var week12:Int
}
