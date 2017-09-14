//
//  ViewController.swift
//  MechanicsAssistant
//
//  Created by Beau Burchfield on 8/15/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase
import SystemConfiguration

var currentBusinessLocation = ""
var currentBusinessID = ""

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //outlets for UI
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var IDField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var IDErrorLabel: UILabel!
    @IBOutlet weak var locationErrorLabel: UILabel!
    
    //array variables to populate fetch requests
    var userNameArray: [String] = []
    var passwordArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        emailField.delegate = self
        passwordField.delegate = self
        IDField.delegate = self
        locationField.delegate = self
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //If user is already signed in, skip login screen
        if Auth.auth().currentUser != nil{
            self.performSegue(withIdentifier: "SuccessfulLogin", sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func addBusinessButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "AddBusiness", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        //remove error labels
        emailErrorLabel.text = ""
        passwordErrorLabel.text = ""
        IDErrorLabel.text = ""
        
        //create shake animation
        let shake = CAKeyframeAnimation( keyPath:"transform" )
        shake.values = [
            NSValue( caTransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
        ]
        shake.autoreverses = true
        shake.repeatCount = 2
        shake.duration = 7/100
        
        
        //assign text field entries to variables
        let enteredUN = emailField.text
        let enteredPW = passwordField.text
        let enteredID = IDField.text
        let enteredLocation = locationField.text
        
        //if either field is empty or the email field is an invalid email...
        if enteredUN == "" || enteredPW == "" || enteredID == "" || enteredLocation == "" || !isValidEmail(testStr: enteredUN!) || (enteredPW?.characters.count)! < 7{
            
            //...Set text to error labels and shake text views
            if enteredUN == "" {
                emailErrorLabel.text = "Please enter email address"
                emailField.layer.add(shake, forKey:nil)
                emailErrorLabel.layer.add(shake, forKey:nil)
                passwordField.text = ""
            }
            if enteredPW == "" {
                passwordErrorLabel.text = "Please enter password"
                passwordField.layer.add(shake, forKey:nil)
                passwordErrorLabel.layer.add(shake, forKey:nil)
            }
            
            if enteredID == "" {
                IDErrorLabel.text = "Please enter business ID"
                IDField.layer.add(shake, forKey:nil)
                IDErrorLabel.layer.add(shake, forKey:nil)
            }
            
            if enteredLocation == "" {
                locationErrorLabel.text = "Please enter location"
                locationField.layer.add(shake, forKey:nil)
                locationErrorLabel.layer.add(shake, forKey:nil)
            }
            
            if enteredUN != "" && !isValidEmail(testStr: enteredUN!){
                emailErrorLabel.text = "This email address is not valid"
                emailField.layer.add(shake, forKey:nil)
                emailErrorLabel.layer.add(shake, forKey:nil)
                emailField.text = ""
                passwordField.text = ""
            }
            
            if enteredPW != "" && (enteredPW?.characters.count)! < 7{
                passwordErrorLabel.text = "Password must be at least 7 characters"
                passwordField.layer.add(shake, forKey:nil)
                passwordErrorLabel.layer.add(shake, forKey:nil)
                passwordField.text = ""
            }
            
            
            
            return
            
            //If all text fields have value and the email field has a valid email...
        }else{
            
            //...and user has internet connection...
            if isInternetAvailable() == true {
                
                
                //...Attempt to login with Firebase
                Auth.auth().signIn(withEmail: enteredUN!, password: enteredPW!) { (user, error) in
                    
                    //If login successful...
                    if error == nil {
                        
                        currentBusinessID = self.IDField.text!
                        currentBusinessLocation = self.locationField.text!
                        
                        let defaults = UserDefaults.standard
                        defaults.set(self.locationField.text!, forKey: "currentLocation")
                        defaults.set(self.IDField.text!, forKey: "currentBusiness")
                        
                        //move to DataViewController
                        self.performSegue(withIdentifier: "SuccessfulLogin", sender: sender)
                        
                        //and clear text fields
                        self.emailField.text = ""
                        self.passwordField.text = ""
                        
                        //If login not successful...
                    } else {
                        
                        //...show login errors from Firebase
                        self.displayAlert("Login Error", alertString: (error?.localizedDescription)!)
                        self.passwordField.text = ""
                        
                    }
                    
                }
                
                //If there's no internet connection...
            }else{
                //...show error
                displayAlert("No Connection", alertString: "You must be connected to the internet in order to login")
                passwordField.text = ""
            }
            
        }
        
    }
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SignUp", sender: sender)
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

