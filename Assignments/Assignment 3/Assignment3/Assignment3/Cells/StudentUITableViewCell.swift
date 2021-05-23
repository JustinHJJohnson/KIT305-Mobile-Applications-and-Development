//
//  StudentUITableViewCell.swift
//  Assignment3
//
//  Created by Justin Johnson on 20/5/21.
//

import UIKit

class StudentUITableViewCell: UITableViewCell
{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
