//
//  customTableViewCell.swift
//  DormDash
//
//  Created by Harshith Sadhu on 3/23/24.
//

import UIKit

class customTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var price: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
