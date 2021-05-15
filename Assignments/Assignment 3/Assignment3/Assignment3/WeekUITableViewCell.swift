//
//  WeekTableViewCell.swift
//  Assignment3
//
//  Created by Joseph Holloway on 15/5/21.
//

import UIKit

class WeekUITableViewCell: UITableViewCell
{

    @IBOutlet var weekLabel: UILabel!
    
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
