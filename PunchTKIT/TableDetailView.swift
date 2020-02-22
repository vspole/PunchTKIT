//
//  TableDetailView.swift
//  PunchTKIT
//
//  Created by Vishal Polepalli on 2/22/20.
//  Copyright © 2020 Vishal Polepalli. All rights reserved.
//

import UIKit

class TableDetailView: UIView {
    var phoneNumber: String?

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.addCustomView()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addCustomView()
    {
        let storeNameLabel: UILabel = UILabel()
        storeNameLabel.frame = CGRect(x: 0, y: 0, width: 250, height: 75)
        storeNameLabel.adjustsFontSizeToFitWidth = true
        storeNameLabel.backgroundColor=UIColor.white
        storeNameLabel.textAlignment = NSTextAlignment.center
        storeNameLabel.text = UserDefaults.standard.string(forKey: "StoreString")
        
        let pointsLabel: UILabel = UILabel()
        pointsLabel.frame = CGRect(x: 0, y: 50, width: 250, height: 75)
        pointsLabel.adjustsFontSizeToFitWidth = true
        pointsLabel.backgroundColor=UIColor.white
        pointsLabel.textAlignment = NSTextAlignment.center
        pointsLabel.text = UserDefaults.standard.string(forKey: "PointsString")

        
        let redeemLabel: UILabel = UILabel()
        redeemLabel.frame = CGRect(x: 0, y: 100, width: 250, height: 75)
        redeemLabel.adjustsFontSizeToFitWidth = true
        redeemLabel.backgroundColor=UIColor.white
        redeemLabel.textAlignment = NSTextAlignment.center
        redeemLabel.text = UserDefaults.standard.string(forKey: "RedeemString")

        

        self.addSubview(storeNameLabel)
        self.addSubview(pointsLabel)
        self.addSubview(redeemLabel)

    }
}
