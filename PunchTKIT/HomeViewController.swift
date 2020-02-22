//
//  HomeViewController.swift
//  PunchTKIT
//
//  Created by Vishal Polepalli on 2/10/20.
//  Copyright © 2020 Vishal Polepalli. All rights reserved.
//

import UIKit
import Firebase

struct storeData
{
    var storeName: String?
    var points: Int?
    var phoneNumber: String?
    var documentReference: String?
}


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var storeTableView: UITableView!
    
    var phoneNumber: String?
    let db = Firestore.firestore()
    var storeArray = [storeData]()
    var currentStore = storeData()
    
    var refreshControl: UIRefreshControl?
    
    var doneButton: UIButton?
    var imageView: UIImageView?
    var blurredEffectView: UIVisualEffectView?
    var customView: UIView?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()


        storeTableView.dataSource = self
        storeTableView.delegate = self
        storeTableView.separatorStyle = .none
        //storeTableView.separatorColor = self.storeTableView.backgroundColor
        phoneNumber = UserDefaults.standard.string(forKey: "PhoneNumber")
        
        downloadData()
        
        addRefreshView()
    }
    
    func downloadData()
    {
        storeArray = [storeData]()
        db.collection("users").document(phoneNumber!).collection("points").getDocuments(){(querySnapshot, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                print(querySnapshot?.documents.count)
                for document in querySnapshot!.documents
                {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    self.storeArray.append(storeData(storeName: data["StoreName"] as? String, points: data["Points"] as? Int ?? 0, phoneNumber: self.phoneNumber!, documentReference: document.documentID))
                }
                self.storeTableView.reloadData()
            }
        }
    }
    
    @objc func refreshData()
    {
        downloadData()
        refreshControl?.endRefreshing()
    }
    
    func addRefreshView()
    {
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor(red: 241/255, green: 136/255, blue: 42/255, alpha: 1.0)
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        storeTableView.addSubview(refreshControl!)
    }
    
    
    @IBAction func qrCodeButtonClicked(_ sender: Any)
    {
        
        let data = phoneNumber!.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator")
        {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform)
            {
                
                let blurEffect = UIBlurEffect(style: .dark)
                let blurredEffectView = UIVisualEffectView(effect: blurEffect)
                blurredEffectView.frame = view.bounds
                
                let w = UIScreen.main.bounds.width
                let h = UIScreen.main.bounds.height
                
                imageView = UIImageView(image: UIImage(ciImage: output))
                imageView!.frame = CGRect(x: w/2, y: h/2, width: 200, height: 200)
                imageView!.center = CGPoint(x: w/2, y: h/2)
                
                doneButton = UIButton()
                doneButton!.setTitle("Dismiss", for: .normal)
                doneButton!.frame = CGRect(x: w/2, y: h/2 + 200, width: 200, height: 50)
                doneButton!.center = CGPoint(x: w/2, y: h/2 + 150)

                doneButton!.tintColor = .white
                doneButton!.backgroundColor = UIColor(red: 241/255, green: 136/255, blue: 42/255, alpha: 1.0)
                doneButton!.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)

                
                let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
                let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
                vibrancyEffectView.frame = imageView!.bounds
                
                blurredEffectView.contentView.addSubview(vibrancyEffectView)

                view.addSubview(blurredEffectView)
                view.addSubview(imageView!)
                view.addSubview(doneButton!)
            }
        }
    }
    
    @objc func doneButtonAction()
    {
        imageView?.removeFromSuperview()
        doneButton?.removeFromSuperview()
        customView?.removeFromSuperview()
        blurredEffectView?.isHidden = true
        for subview in view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return storeArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        currentStore = storeArray[indexPath.section]
        tableView.deselectRow(at: indexPath, animated: true)
        showDetailView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as! StoreTableViewCell


        
        cell.storeNameLabel.text = storeArray[indexPath.section].storeName
        cell.pointsLabel.text = String(storeArray[indexPath.section].points!)
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 3
        
        return cell
    }
    
      func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
      {
        if let headerView = view as? UITableViewHeaderFooterView
        {
            headerView.contentView.backgroundColor = UIColor(red: 232/255, green: 231/255, blue: 225/255, alpha: 1.0)
        }
    }
    
    
    func showDetailView()
    {
        
        db.collection("stores").whereField("StoreName", isEqualTo: currentStore.storeName ?? "").limit(to: 1).getDocuments()
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
                    
                    let points = self.currentStore.points!
                    let pointString = String(points) + " of "
                    let pointsNeeded = document.data()["NumToRecieve"] as? Int
                    UserDefaults.standard.set(pointString + String(pointsNeeded!) + " points ", forKey: "PointsString")
                    UserDefaults.standard.set(document.data()["RedemptionValue"] as? String ?? " ", forKey: "RedeemString")
                    UserDefaults.standard.set(self.currentStore.storeName, forKey: "StoreString")
                    
                    let blurEffect = UIBlurEffect(style: .dark)
                    let blurredEffectView = UIVisualEffectView(effect: blurEffect)
                    blurredEffectView.frame = self.view.bounds
                    
                    let w = UIScreen.main.bounds.width
                    let h = UIScreen.main.bounds.height
                    
                    self.customView = TableDetailView(frame: CGRect(x: 0, y: 0, width: 250, height: 175))
                    self.customView!.center = CGPoint(x: (w/2), y: h/2)
                    
                    self.doneButton = UIButton()
                    self.doneButton!.setTitle("Dismiss", for: .normal)
                    self.doneButton!.frame = CGRect(x: w/2, y: h/2 + 600, width: 250, height: 50)
                    self.doneButton!.center = CGPoint(x: w/2, y: h/2 + 150)

                    self.doneButton!.tintColor = .white
                    self.doneButton!.backgroundColor = UIColor(red: 241/255, green: 136/255, blue: 42/255, alpha: 1.0)
                    self.doneButton!.addTarget(self, action: #selector(self.doneButtonAction), for: .touchUpInside)

                    
                    let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
                    let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
                    vibrancyEffectView.frame = self.customView!.bounds
                    
                    blurredEffectView.contentView.addSubview(vibrancyEffectView)

                    self.view.addSubview(blurredEffectView)
                    self.view.addSubview(self.doneButton!)
                    self.view.addSubview(self.customView!)
                }
                
            }
        }
        


        

    }

}


