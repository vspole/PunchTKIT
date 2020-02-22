//
//  LoginViewController.swift
//  PunchTKIT
//
//  Created by Vishal Polepalli on 2/10/20.
//  Copyright © 2020 Vishal Polepalli. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var phoneNumberTextEdit: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var name: String?
    var emailAddress: String?
    var phoneNumber: String?
    let db = Firestore.firestore()
    
    var verificationCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberTextEdit.returnKeyType = .done
        phoneNumberTextEdit.delegate = self
        phoneNumberTextEdit.textColor = .white
        phoneNumberTextEdit.keyboardType = .phonePad
        phoneNumberTextEdit.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        UIView.animate(withDuration: 1.0)
        {
            self.view.backgroundColor = UIColor(red: 47.0/255.0, green: 37.0/255.0, blue: 47.0/255.0, alpha: 1.0)
            self.logoImageView.image = UIImage(named: "FullLogoWhite")
            
        }
        
        loginButton.isEnabled = false
        
        addDoneButtonOnKeyboard()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButtonPressed(_ sender: Any)
    {
        phoneNumber = "+1 " + phoneNumberTextEdit.text!
        UserDefaults.standard.set(phoneNumber, forKey: "PhoneNumber")
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber!, uiDelegate: nil)
        { (verificationID, error) in
          if let error = error
          {
            print("HERE: " + error.localizedDescription)
            return
          }
            
            let alertController = UIAlertController(title: "Verification Code", message: "Please enter the verification code sent to ypur phone.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Enter", style: .default)
            { (_) in
                self.verificationCode = alertController.textFields?[0].text
                let credential = PhoneAuthProvider.provider().credential(
                  withVerificationID: verificationID!,
                  verificationCode: self.verificationCode!)
                Auth.auth().signIn(with: credential)
                { (authResult, error) in
                  if let error = error
                  {
                    let alertController = UIAlertController(title: "Login Failed", message: "Login failed. Please try again", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                  }
                    UserDefaults.standard.set(self.phoneNumber, forKey: "PhoneNumber")
                    self.downloadInfo()
                }
            }
            alertController.addTextField(configurationHandler: {(textfield) in
                textfield.placeholder = "Verification Code"
                textfield.keyboardType = .numberPad
            })
            alertController.addAction(confirmAction)
            self.present(alertController,animated: true)
        }
        
        

    }
    

    

    // MARK: - Navigation

    func downloadInfo()
    {
        db.collection("users").document(phoneNumber!).getDocument()
        { (document, error) in
            if let document = document
            {
                if document.exists
                {
                    self.performSegue(withIdentifier: "loginToHome", sender: self)
                }
                else
                {
                    self.db.collection("users").document(self.phoneNumber!).setData(
                        [
                        "PhoneNumber": self.phoneNumber!
                        ]) { err in
                            if let err = err
                            {
                                print("Error writing document: \(err)")
                            }
                            else
                            {
                                print("Document successfully written!")
                            }
                            self.performSegue(withIdentifier: "loginToHome", sender: self)
                        }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is HomeViewController
        {
            let vc = segue.destination as? HomeViewController
            vc?.phoneNumber = phoneNumber
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return false
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.placeholder = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField.text?.count == 12
        {
            loginButton.isEnabled = true
        }
    }
    
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.phoneNumberTextEdit.inputAccessoryView = doneToolbar

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var fullString = textField.text ?? ""
        fullString.append(string)
        if range.length == 1 {
            textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
        } else {
            textField.text = format(phoneNumber: fullString)
        }
        return false
    }
    
    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String
    {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")

        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: range)
        }

        return number
    }


}
