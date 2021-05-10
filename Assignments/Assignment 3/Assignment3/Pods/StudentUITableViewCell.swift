//
//  StudentUITableViewCell.swift
//  Assignment3
//
//  Created by Justin Johnson on 5/10/21.
//

import UIKit

class StudentUITableViewCell: UITableViewCell
{

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var studentIDLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
