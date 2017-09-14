//
//  SignUpViewController.swift
//  MechanicsAssistant
//
//  Created by Beau Burchfield on 9/10/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase
import SystemConfiguration

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        //create shake animation
        let shake = CAKeyframeAnimation( keyPath:"transform" )
        shake.values = [
            NSValue( caTransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
        ]
        shake.autoreverses = true
        shake.repeatCount = 2
        shake.duration = 7/100
        
        //if email, password, and confirm password fields are not empty...
        if(emailField.text != "" && passwordField.text != "" && confirmPasswordField.text != ""){
            //set variables for text field input
            let emailString = emailField.text
            let passwordString = passwordField.text
            let confirmPasswordString = confirmPasswordField.text
            
            //if the email is a valid format...
            if(isValidEmail(testStr: emailString!)){
                
                //...and password input equals confirm password input...
                if(passwordString! == confirmPasswordString && (passwordString?.characters.count)! > 6){
                    
                    //...and the device has connection to the internet
                    if isInternetAvailable() == true {
                        
                        //Create new account with Firebase
                        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
                            
                            //If account creation successful
                            if error == nil {
                                print("You have successfully signed up")
                                
                                //pop back to login view controller
                                _ = self.navigationController?.popViewController(animated: true)
                                
                                //If account creation not successful
                            } else {
                                print("There's been an error signing up")
                                self.displayAlert("Signup Error", alertString: (error?.localizedDescription)!)
                            }
                            
                        }
                        
                    }else{
                        displayAlert("No Connection", alertString: "You must be connected to the internet in order to sign up")
                        passwordField.text = ""
                        confirmPasswordField.text = ""
                    }
                    
                }else{
                    
                    if passwordField.text! == confirmPasswordField.text! && (passwordField.text?.characters.count)! < 7 {
                        
                        showTextFieldPlaceholder(textfield: passwordField, placeholderString: "Password must be at least 7 characters")
                        passwordField.layer.add(shake, forKey: nil)
                        confirmPasswordField.layer.add( shake, forKey: nil)
                        
                        passwordField.layer.add(shake, forKey: nil)
                        confirmPasswordField.text = ""
                        
                    }else{
                        
                        showTextFieldPlaceholder(textfield: passwordField, placeholderString: "Passwords must match")
                        showTextFieldPlaceholder(textfield: confirmPasswordField, placeholderString: "Passwords must match")
                        passwordField.layer.add(shake, forKey: nil)
                        confirmPasswordField.layer.add(shake, forKey: nil)
                        passwordField.text = ""
                        confirmPasswordField.text = ""
                        
                    }
                    
                }
                
            }else{
                
                showTextFieldPlaceholder(textfield: emailField, placeholderString: "Please enter a valid email")
                emailField.layer.add(shake, forKey: nil)
                passwordField.text = ""
                confirmPasswordField.text = ""
                
            }
            
        }else{
            
            if emailField.text == "" {
                showTextFieldPlaceholder(textfield: emailField, placeholderString: "Please enter email")
            }
            
            if passwordField.text == "" {
                showTextFieldPlaceholder(textfield: passwordField, placeholderString: "Please enter password")
            }
            
            if confirmPasswordField.text == "" {
                showTextFieldPlaceholder(textfield: confirmPasswordField, placeholderString: "You must confirm password")
            }
            
            passwordField.text = ""
            confirmPasswordField.text = ""
            
        }
        
    }
    
    //funtion for displaying alert controller
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
    
}
