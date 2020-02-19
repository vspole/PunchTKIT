//
//  StoreTableViewCell.swift
//  PunchTKIT
//
//  Created by Vishal Polepalli on 2/14/20.
//  Copyright © 2020 Vishal Polepalli. All rights reserved.
//

import UIKit

class StoreTableViewCell: UITableViewCell {
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.storeNameLabel.text = nil
        self.pointsLabel.text = nil
    }
    


}
