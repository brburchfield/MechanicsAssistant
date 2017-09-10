//
//  ForgotPasswordViewController.swift
//  MechanicsAssistant
//
//  Created by Beau Burchfield on 8/23/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase
import SystemConfiguration

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the navigation bar on this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        //if email field is populated and a valid email, and internet is available...
        if emailField.text != ""{
            if isValidEmail(testStr: emailField.text!){
                if isInternetAvailable(){
                    
                    //...send password reset email via Firebase
                    Auth.auth().sendPasswordReset(withEmail: emailField.text!) { (error) in
                        //if there's an error, display error alert
                        if error != nil {
                            self.displayAlert("Password Reset Error", alertString: "\(error?.localizedDescription ?? "An unknown error has occured. Please contact Mechanic's Assistant at brburchfield@fullsail.edu for more information.")")
                        }else{
                            //if successful, display success alert
                            self.displayAlert("Email Sent", alertString: "Please check for an email with your password.")
                        }
                    }
                    //otherwise, display error handling alert
                } else {
                    displayAlert("No Connection", alertString: "Please check your internet connection.")
                }
            } else {
                displayAlert("Email Invalid", alertString: "Please check your email input.")
            }
        } else {
            displayAlert("No input", alertString: "Please enter a valid email.")
        }
        
    }
    
    //function for displaying an alert controller
    func displayAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
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
    
}
