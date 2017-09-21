//
//  EditBusinessLoginView.swift
//  MechanicsAssistant
//
//  Created by Beau Burchfield on 9/21/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase
import SystemConfiguration

public var currentBusinessToEdit = ""
public var editBusinessEmail = ""

class EditBusinessLoginViewController:  UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ownerEmailField: UITextField!
    @IBOutlet weak var ownerPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //sign out of Firebase
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if !isValidEmail(testStr: ownerEmailField.text!) || ownerPasswordField.text == "" {
            
            if ownerEmailField.text == "" {
                showTextFieldPlaceholder(textfield: ownerEmailField, placeholderString: "Enter owner email")
            } else if !isValidEmail(testStr: ownerEmailField.text!) {
                showTextFieldPlaceholder(textfield: ownerEmailField, placeholderString: "Not a valid email")
            }
            
            if ownerPasswordField.text == "" {
                showTextFieldPlaceholder(textfield: ownerPasswordField, placeholderString: "Enter owner password")
            }
            
        } else {
            
            //If user has internet connection...
            if isInternetAvailable() {
                
                
                //...Attempt to login with Firebase
                Auth.auth().signIn(withEmail: ownerEmailField.text!, password: ownerPasswordField.text!) { (user, error) in
                    
                    //If login successful...
                    if error == nil {
                        
                        //TODO: Check to see if business exists and get business email
                        let ref = Database.database().reference(withPath: "businesses")
                        
                        ref.observe(.value, with: { (snapshot) -> Void in
                            
                            var businesses = [DataSnapshot]()
                            
                            //add businesses to businesses variable
                            for item in snapshot.children{
                                businesses.append(item as! DataSnapshot)
                            }
                            
                            var shouldShowBusinessError = true
                            
                            self.delayWithSeconds(1) {
                                for item in businesses {
                                    let value = item.value as? NSDictionary
                                    let businessOwnerEmail = value?["ownerEmail"] as? String ?? ""
                                    if businessOwnerEmail == self.ownerEmailField.text! {
                                        currentBusinessToEdit = item.key
                                        editBusinessEmail = businessOwnerEmail
                                        shouldShowBusinessError = false
                                        self.performSegue(withIdentifier: "EditBusinessLoginSuccessful", sender: sender)
                                    }
                                }
                                
                                if shouldShowBusinessError {
                                    self.displayAlert("No such business/location", alertString: "There is no business with that value in the database.")
                                    do {
                                        try Auth.auth().signOut()
                                    } catch let signOutError as NSError {
                                        print ("Error signing out: %@", signOutError)
                                    }
                                }
                                
                            }
                            
                        })
                        
                        
                        //If login not successful...
                    } else {
                        //...show login errors from Firebase
                        self.displayAlert("Login Error", alertString: (error?.localizedDescription)!)
                        
                    }
                    
                }
                
                //If there's no internet connection...
            }else{
                //...show error
                displayAlert("No Connection", alertString: "You must be connected to the internet in order to login")
                
            }
            
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
