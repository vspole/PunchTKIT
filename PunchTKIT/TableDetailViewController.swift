//
//  TableDetailViewController.swift
//  PunchTKIT
//
//  Created by Vishal Polepalli on 2/10/20.
//  Copyright © 2020 Vishal Polepalli. All rights reserved.
//

import UIKit
import Firebase

class TableDetailViewController: UIViewController {

    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var redeemLabel: UILabel!
    
    var store: storeData?
    let db = Firestore.firestore()
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumber = UserDefaults.standard.string(forKey: "PhoneNumber")
        storeNameLabel.text = store?.storeName
        db.collection("stores").whereField("StoreName", isEqualTo: store?.storeName ?? "").limit(to: 1).getDocuments()
        { (querySnapshot, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
               
                for document in querySnapshot!.documents
                {
                    print("\(document.documentID) => \(document.data())")
                    
                    let points = self.store?.points!
                    let pointString = "You have earned " + String(points!) + " of "
                    let pointsNeeded = document.data()["NumToRecieve"] as? Int
                    self.pointsLabel.text = pointString + String(pointsNeeded!) + " points needed to redeem reward."
                    self.redeemLabel.text = document.data()["RedemptionValue"] as? String ?? " "
                }
                
            }
        }
        
        // Do any additional setup after loading the view.
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
