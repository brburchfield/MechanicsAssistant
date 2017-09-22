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
var currentBusinessEmail = ""

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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //array variables to populate fetch requests
    var userNameArray: [String] = []
    var passwordArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        activityIndicator.isHidden = true
        
        //Setup text field delegate
        emailField.delegate = self
        passwordField.delegate = self
        IDField.delegate = self
        locationField.delegate = self
        
        //Check local storage for business ID and location. If exists, populate text fields
        if currentBusinessID == "" || currentBusinessLocation == "" {
            let defaults = UserDefaults.standard
            if let businessIDFromStorage = defaults.string(forKey: "currentBusiness") {
                IDField.text = businessIDFromStorage
            }
            if let locationFromStorage = defaults.string(forKey: "currentLocation") {
                locationField.text = locationFromStorage
            }
        }
        
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
        //remove Firebase observers
        let ref = Database.database().reference(withPath: "businesses")
        ref.removeAllObservers()
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
        //start activity indicator
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
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
            //remove activity indicator
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            
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
            if isInternetAvailable() {
                
                
                //...Attempt to login with Firebase
                Auth.auth().signIn(withEmail: enteredUN!, password: enteredPW!) { (user, error) in
                    
                    //If login successful...
                    if error == nil {
                        
                        //store ID and location fields in public variables
                        currentBusinessID = self.IDField.text!
                        currentBusinessLocation = self.locationField.text!
                        
                        //TODO: Check to see if business exists and get business email
                        let ref = Database.database().reference(withPath: "businesses")
                        
                        ref.observe(.value, with: { (snapshot) -> Void in
                            
                            var businesses = [DataSnapshot]()
                            
                            //add businesses to businesses variable
                            for item in snapshot.children{
                                businesses.append(item as! DataSnapshot)
                            }
                            
                            //setup business error variable
                            var shouldShowBusinessError = true
                            
                            //find correlating businesses and store information to local storage
                            self.delayWithSeconds(1) {
                                for item in businesses {
                                    let value = item.value as? NSDictionary
                                    let business = value?["id"] as? String ?? ""
                                    if business == currentBusinessID {
                                        shouldShowBusinessError = false
                                        let defaults = UserDefaults.standard
                                        defaults.set(self.locationField.text!, forKey: "currentLocation")
                                        defaults.set(self.IDField.text!, forKey: "currentBusiness")
                                        defaults.set(value?["email"] as? String ?? "", forKey: "currentEmail")
                                        currentBusinessEmail = value?["email"] as? String ?? ""
                                        
                                        //remove activity indicator
                                        self.activityIndicator.stopAnimating()
                                        self.activityIndicator.isHidden = true
                                        
                                        //move to DataViewController
                                        self.performSegue(withIdentifier: "SuccessfulLogin", sender: sender)
                                        
                                        //and clear text fields
                                        self.emailField.text = ""
                                        self.passwordField.text = ""
                                    }
                                }
                                
                                //if there's no correlating business, show error
                                if shouldShowBusinessError {
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.isHidden = true
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
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        //...show login errors from Firebase
                        self.displayAlert("Login Error", alertString: (error?.localizedDescription)!)
                        self.passwordField.text = ""
                        
                        
                    }
                    
                }
                
                //If there's no internet connection...
            }else{
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                //...show error
                displayAlert("No Connection", alertString: "You must be connected to the internet in order to login")
                passwordField.text = ""
                
            }
            
        }
        
    }
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SignUp", sender: sender)
    }
    
    @IBAction func editBusinessButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "EditBusiness", sender: sender)
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
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
}

