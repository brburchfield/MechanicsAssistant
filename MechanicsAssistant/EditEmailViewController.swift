//
//  EditEmailViewController.swift
//  MechanicsAssistant
//
//  Created by Beau Burchfield on 9/16/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase
import SystemConfiguration

class EditEmailViewController:  UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var currentEmailField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var confirmEmailField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityIndicator.isHidden = true
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let ref = Database.database().reference(withPath: "businesses")
        ref.removeAllObservers()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeEmailButtonPressed(_ sender: UIButton) {
        
        if idField.text == "" || currentEmailField.text == "" || newEmailField.text == "" || confirmEmailField.text == "" || !isValidEmail(testStr: newEmailField.text!) || newEmailField.text != confirmEmailField.text {
            
            if idField.text == "" {
                showTextFieldPlaceholder(textfield: idField, placeholderString: "Enter business ID")
            }
            
            if currentEmailField.text == "" {
                showTextFieldPlaceholder(textfield: currentEmailField, placeholderString: "Enter current email address")
            }
            
            if newEmailField.text == "" {
                showTextFieldPlaceholder(textfield: newEmailField, placeholderString: "Enter new email")
            }
            
            if confirmEmailField.text == "" {
                showTextFieldPlaceholder(textfield: confirmEmailField, placeholderString: "Confirm new email")
            }
            
            if newEmailField.text! != "" && !isValidEmail(testStr: newEmailField.text!){
                showTextFieldPlaceholder(textfield: newEmailField, placeholderString: "Not a valid email")
                showTextFieldPlaceholder(textfield: confirmEmailField, placeholderString: "")
            }
            
            if newEmailField.text != confirmEmailField.text {
                showTextFieldPlaceholder(textfield: confirmEmailField, placeholderString: "Confirm field does not match")
            }
            
        } else {
            
            let ref = Database.database().reference(withPath: "businesses")
            
            ref.observe(.value, with: { (snapshot) -> Void in
                
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                
                var businesses = [DataSnapshot]()
                
                //add vehicles to tempVehicles variable
                for item in snapshot.children{
                    businesses.append(item as! DataSnapshot)
                }
                
                var shouldShowBusinessError = true
                self.delayWithSeconds(1) {
                    for item in businesses {
                        let key = item.key
                        let value = item.value as? NSDictionary
                        let id = value?["id"] as? String ?? ""
                        let email = value?["email"] as? String ?? ""
                        if id == self.idField.text && email == self.currentEmailField.text {
                            
                            ref.child(key).child("email").setValue(self.newEmailField.text)
                            
                            shouldShowBusinessError = false
                            
                            let alertController = UIAlertController(title: "Email Changed", message: "You've successfully changed your business email.", preferredStyle: .alert)
                            let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
                                self.navigationController?.popViewController(animated: true)
                            }
                            alertController.addAction(confirmAction)
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                    }
                    
                    if shouldShowBusinessError {
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        self.displayAlert("No such business/location", alertString: "There is no business with that info in the database.")
                        
                    }
                    
                }
                
            })
            
            
        }
    }
    
    //Function for email validation using regular expression.
    func isValidEmail(testStr:String) -> Bool {
        let emailRegularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegularExpression)
        return emailPredicate.evaluate(with: testStr)
    }
    
    //Function to check connection availability
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func showTextFieldPlaceholder(textfield: UITextField, placeholderString: String){
        
        textfield.text = ""
        
        //create shake animation
        let shake = CAKeyframeAnimation( keyPath:"transform" )
        shake.values = [
            NSValue( caTransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
        ]
        shake.autoreverses = true
        shake.repeatCount = 2
        shake.duration = 7/100
        
        if textfield.text == "" {
            textfield.attributedPlaceholder = NSAttributedString(string: placeholderString, attributes: [NSForegroundColorAttributeName: UIColor.red])
            textfield.layer.add(shake, forKey: nil)
        }
        
    }
    
    //funtion for displaying alert controller
    func displayAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
