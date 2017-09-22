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
import MessageUI

class EditBusinessViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var ownerEmailField: UITextField!
    @IBOutlet weak var businessNameField: UITextField!
    @IBOutlet weak var businessEmailField: UITextField!
    @IBOutlet weak var businessIDField: UITextField!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let pickerDataSource = ["Blue", "Red", "Green", "Yellow", "Cyan", "White"]
    var currentPickerValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imagePicker.delegate = self
        colorPicker.dataSource = self
        colorPicker.delegate = self
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //Check to see if business exists and get business email
        let ref = Database.database().reference(withPath: "businesses").child(currentBusinessToEdit)
        
        // Get business associated with owner account
        ref.observe(.value, with: { (snapshot) -> Void in
            let value = snapshot.value as? NSDictionary
            
            // Populate text fields with the information
            self.businessNameField.text = value?["name"] as? String ?? ""
            self.businessEmailField.text = value?["email"] as? String ?? ""
            self.businessIDField.text = value?["id"] as? String ?? ""
            self.ownerEmailField.text = value?["ownerEmail"] as? String ?? ""
            
            let logoString = value?["logo"] as? String ?? ""
            //Decode logo image from base64 string
            let dataDecoded : Data = Data(base64Encoded: logoString, options: .ignoreUnknownCharacters)!
            let decodedimage = UIImage(data: dataDecoded)
            self.logoView.image = decodedimage
            
            //Set background color and picker selection to correlate with pre-existing business color
            let colorString = value?["color"] as? String ?? ""
            let colorInt = Int(colorString)
            self.colorPicker.selectRow(colorInt!, inComponent: 0, animated: false)
            
            if colorInt! == 0 {
                self.backgroundImage.image = UIImage(named: "BackgroundBlue")
                self.currentPickerValue = colorInt!
            }
            else if colorInt! == 1 {
                self.backgroundImage.image = UIImage(named: "BackgroundRed")
                self.currentPickerValue = colorInt!
            }
            else if colorInt! == 2 {
                self.backgroundImage.image = UIImage(named: "BackgroundGreen")
                self.currentPickerValue = colorInt!
            }
            else if colorInt! == 3 {
                self.backgroundImage.image = UIImage(named: "BackgroundYellow")
                self.currentPickerValue = colorInt!
            }
            else if colorInt! == 4 {
                self.backgroundImage.image = UIImage(named: "BackgroundCyan")
                self.currentPickerValue = colorInt!
            } else {
                self.backgroundImage.image = UIImage(named: "BackgroundWhite")
                self.currentPickerValue = colorInt!
            }
            
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    //Set background to correlate with picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            backgroundImage.image = UIImage(named: "BackgroundBlue")
            currentPickerValue = row
        }
        else if row == 1 {
            backgroundImage.image = UIImage(named: "BackgroundRed")
            currentPickerValue = row
        }
        else if row == 2 {
            backgroundImage.image = UIImage(named: "BackgroundGreen")
            currentPickerValue = row
        }
        else if row == 3 {
            backgroundImage.image = UIImage(named: "BackgroundYellow")
            currentPickerValue = row
        }
        else if row == 4 {
            backgroundImage.image = UIImage(named: "BackgroundCyan")
            currentPickerValue = row
        } else {
            backgroundImage.image = UIImage(named: "BackgroundWhite")
            currentPickerValue = row
        }
    }
    
    //Set image view to input logo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            logoView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        // Check for errors
        if self.ownerEmailField.text! == "" || self.businessNameField.text! == "" || self.businessEmailField.text == "" || self.businessIDField.text == "" || self.logoView.image == nil || !self.isInternetAvailable() || !self.isValidEmail(testStr: self.businessEmailField.text!) {
            
            // Handle errors
            if self.ownerEmailField.text == "" {
                self.showTextFieldPlaceholder(textfield: self.ownerEmailField, placeholderString: "Add owner email")
            }
            
            if self.businessNameField.text == "" {
                self.showTextFieldPlaceholder(textfield: self.businessNameField, placeholderString: "Add business name")
            }
            
            if self.businessEmailField.text == "" {
                self.showTextFieldPlaceholder(textfield: self.businessEmailField, placeholderString: "Add business email")
            }
            
            if self.businessIDField.text == "" {
                self.showTextFieldPlaceholder(textfield: self.businessIDField, placeholderString: "Add custom business ID")
            }
            
            if self.logoView.image == nil {
                self.displayAlert("No Logo Added", alertString: "You must add a logo to add a new business.")
            }
            
            if !self.isValidEmail(testStr: self.businessEmailField.text!){
                self.showTextFieldPlaceholder(textfield: self.businessEmailField, placeholderString: "Not a valid email")
            }
            
            if !self.isInternetAvailable() {
                self.displayAlert("No Connection", alertString: "You must be connected to the internet to edit a business.")
            }
            
        } else {
            
            //Encode input image
            let imagePNG = UIImagePNGRepresentation(self.logoView.image!)
            let encoded64image = imagePNG?.base64EncodedString(options: .lineLength64Characters)
            let stringSize = encoded64image?.utf8.count
            if stringSize! < 10485760 {
                
                
                //Save information to Firebase
                let businessRef = Database.database().reference(withPath: "businesses").child(currentBusinessToEdit)
                businessRef.child("ownerEmail").setValue(self.ownerEmailField.text)
                businessRef.child("name").setValue(self.businessNameField.text)
                businessRef.child("email").setValue(self.businessEmailField.text)
                businessRef.child("id").setValue(self.businessIDField.text)
                businessRef.child("color").setValue("\(self.currentPickerValue)")
                businessRef.child("logo").setValue(encoded64image)
                
                if !MFMailComposeViewController.canSendMail() {
                    self.displayCompletionAlert("Can't Email", alertString: "Mail services are not available, but your business has been edited. Your business ID is:\n\n\(self.businessIDField.text!)")
                    return
                } else {
                    
                    // Send new ID email
                    self.sendEmail(subjectString: "Your business ID", messageBody: "Thank you for using Mechanic's Assistant!\n\nYour business ID is:\n\n\(self.businessIDField.text!)\n\nPlease keep this on file. This will be your key to sign in to the employee and lobby applications. If you have any issues or questions, please email us at info@mechanicsassistant.com.")
                    
                }
                
            } else {
                
                self.logoView.image = nil
                //Show image too large alert
                self.displayAlert("Invalid Logo", alertString: "The logo file you've provided is too large. Please add a smaller image and try again.")
                
            }
            
        }
        
    }
    
    @IBAction func uploadImageButtonPressed(_ sender: UIButton) {
        // Present image picker
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
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
    
    func displayCompletionAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title: "Ok", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //function for sending email
    func sendEmail(subjectString: String, messageBody: String) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients([editBusinessEmail])
        composeVC.setSubject(subjectString)
        composeVC.setMessageBody(messageBody, isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        controller.dismiss(animated: true, completion: { (success) -> Void in
            
            let alertController = UIAlertController(title: "Business Edited", message: "Your business has been edited! Make sure you keep your business ID, as you'll use it to sign in!\n\nBusiness ID: \(self.businessIDField.text ?? "Error")", preferredStyle: UIAlertControllerStyle.alert)
            let okButton = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default) { (_) in
                self.navigationController?.popViewController(animated: true)
            }
            
            alertController.addAction(okButton)
            self.present(alertController, animated: true, completion: nil)
            
        })
        
        
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
