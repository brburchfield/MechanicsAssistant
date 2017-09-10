//
//  NewVehicleViewController.swift
//  MechanicsAssistant
//
//  Created by Beau Burchfield on 8/16/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import SystemConfiguration

class NewVehicleViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField:  UITextField!
    @IBOutlet weak var makeTextField:      UITextField!
    @IBOutlet weak var modelTextField:     UITextField!
    @IBOutlet weak var yearTextField:      UITextField!
    @IBOutlet weak var colorTextField:     UITextField!
    @IBOutlet weak var addressTextField:   UITextField!
    @IBOutlet weak var aptTextField:       UITextField!
    @IBOutlet weak var cityTextField:      UITextField!
    @IBOutlet weak var stateTextField:     UITextField!
    @IBOutlet weak var zipTextField:       UITextField!
    @IBOutlet weak var phoneTextField:     UITextField!
    @IBOutlet weak var emailTextField:     UITextField!
    @IBOutlet weak var vinTextField:       UITextField!
    @IBOutlet weak var servicesTextField:  UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        displayLookupAlert()
     
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        makeTextField.delegate = self
        modelTextField.delegate = self
        yearTextField.delegate = self
        colorTextField.delegate = self
        addressTextField.delegate = self
        aptTextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        zipTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        vinTextField.delegate = self
        servicesTextField.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addVehicleButtonPressed(_ sender: UIButton) {
        
        //Setup Firebase Reference variable for new entry
        let ref = Database.database().reference(withPath: "vehicles").childByAutoId()
        let refFirstName = ref.child("firstName")
        let refLastName = ref.child("lastName")
        let refMake = ref.child("make")
        let refModel = ref.child("model")
        let refYear = ref.child("year")
        let refColor = ref.child("color")
        let refStreet = ref.child("streetAddress")
        let refApt = ref.child("apt")
        let refCity = ref.child("city")
        let refState = ref.child("state")
        let refZip = ref.child("zip")
        let refPhone = ref.child("phone")
        let refEmail = ref.child("email")
        let refVIN = ref.child("vin")
        let refServices = ref.child("services")
        let refStatuses = ref.child("statuses")
        
        //if apt field is empty, populate it
        if aptTextField.text == "" {
            aptTextField.text = "N/A"
        }
        
        //if no fields (except apt) are empty...
        if firstNameTextField.text != "" && lastNameTextField.text != "" && makeTextField.text != "" && modelTextField.text != "" && yearTextField.text != "" && colorTextField.text != "" &&
            addressTextField.text != "" && cityTextField.text != "" && stateTextField.text != "" &&
            zipTextField.text != "" && phoneTextField.text != "" && emailTextField.text != "" &&
            servicesTextField.text != "" && vinTextField.text != "" {
            
            //Create service array from service text field by separating items by commas
            let serviceArray = servicesTextField.text?.components(separatedBy: ", ")
            
            //...and entered services are equal to or less than 5...
            if (serviceArray?.count)! <= 5 {
                
                //...and device is connected to the internet,
                if isInternetAvailable() == true {
                    
                    //set corresponding Firebase reference values to text field data
                    refFirstName.setValue(firstNameTextField.text)
                    refLastName.setValue(lastNameTextField.text)
                    refMake.setValue(makeTextField.text)
                    refModel.setValue(modelTextField.text)
                    refYear.setValue(yearTextField.text)
                    refColor.setValue(colorTextField.text)
                    refStreet.setValue(addressTextField.text)
                    refApt.setValue(aptTextField.text)
                    refCity.setValue(cityTextField.text)
                    refState.setValue(stateTextField.text)
                    refZip.setValue(zipTextField.text)
                    refPhone.setValue(phoneTextField.text)
                    refEmail.setValue(emailTextField.text)
                    refVIN.setValue(vinTextField.text)
                    
                    //Create multiple items for services (if applicable)
                    let serviceArray = servicesTextField.text?.components(separatedBy: ", ")
                    
                    var childNumber = 0
                    
                    for item in serviceArray! {
                        let thisRef = refServices.child("serviceNumber\(childNumber)")
                        thisRef.setValue(item)
                        refStatuses.child("mainService\(childNumber)").setValue("no")
                        childNumber += 1
                    }
                    
                    //set default value for preventative maintenance items
                    refStatuses.child("oilLevel").setValue("no")
                    refStatuses.child("transLevel").setValue("no")
                    refStatuses.child("brakeLevel").setValue("no")
                    refStatuses.child("steerLevel").setValue("no")
                    refStatuses.child("coolantLevel").setValue("no")
                    refStatuses.child("washerLevel").setValue("no")
                    refStatuses.child("tirePressure").setValue("no")
                    refStatuses.child("treadDepth").setValue("no")
                    refStatuses.child("airFilter").setValue("no")
                    refStatuses.child("lights").setValue("no")
                    refStatuses.child("batteryCables").setValue("no")
                    refStatuses.child("batteryFluid").setValue("no")
                    refStatuses.child("belts").setValue("no")
                    refStatuses.child("hoses").setValue("no")
                    refStatuses.child("horn").setValue("no")
                    
                    //TODO: Setup customer data
                    let customerRef = Database.database().reference(withPath: "customers").child(phoneTextField.text!)
                    
                    customerRef.child("firstName").setValue(firstNameTextField.text)
                    customerRef.child("lastName").setValue(lastNameTextField.text)
                    customerRef.child("streetAddress").setValue(addressTextField.text)
                    customerRef.child("apt").setValue(aptTextField.text)
                    customerRef.child("city").setValue(cityTextField.text)
                    customerRef.child("state").setValue(stateTextField.text)
                    customerRef.child("zip").setValue(zipTextField.text)
                    customerRef.child("email").setValue(emailTextField.text)
                    
                    //Setup confirmation alert
                    let alertController = UIAlertController(title: "Vehicle Entered Successfully", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    // Create alert actions
                    let popBackAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(popBackAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    //If no internet access, display alert
                } else {
                    displayAlert("No Connection", alertString: "You must be connected to the internet in order to add vehicle data")
                }
                
                //if number of services entered is greater than five
            }else {
                showTextFieldPlaceholder(textfield: servicesTextField, placeholderString: "You may only have a max of 5 services")
            }
            
            //If one or more of the fields are empty (other than apt), show error action (shake).
        } else {
            
            showTextFieldPlaceholder(textfield: firstNameTextField, placeholderString: "Please Enter First Name")
            showTextFieldPlaceholder(textfield: lastNameTextField, placeholderString: "Please Enter Last Name")
            showTextFieldPlaceholder(textfield: makeTextField, placeholderString: "Please Enter Vehicle Make")
            showTextFieldPlaceholder(textfield: modelTextField, placeholderString: "Please Enter Vehicle Model")
            showTextFieldPlaceholder(textfield: yearTextField, placeholderString: "Please Enter Vehicle Year")
            showTextFieldPlaceholder(textfield: colorTextField, placeholderString: "Please Enter Vehicle Color")
            showTextFieldPlaceholder(textfield: addressTextField, placeholderString: "Please Enter Customer Address")
            showTextFieldPlaceholder(textfield: cityTextField, placeholderString: "Please Enter Customer City")
            showTextFieldPlaceholder(textfield: stateTextField, placeholderString: "Please Enter Customer State")
            showTextFieldPlaceholder(textfield: zipTextField, placeholderString: "Please Enter Customer Zip")
            showTextFieldPlaceholder(textfield: phoneTextField, placeholderString: "Please Enter Customer Phone")
            showTextFieldPlaceholder(textfield: emailTextField, placeholderString: "Please Enter Customer Email")
            showTextFieldPlaceholder(textfield: vinTextField, placeholderString: "Please Enter Vehicle Vin Number")
            showTextFieldPlaceholder(textfield: servicesTextField, placeholderString: "Please Enter Services Required")
            
        }
        
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
    
    //funtion for displaying alert controller
    func displayAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
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
    
    
    func displayLookupAlert() {
        let alertController = UIAlertController(title: "Find Customer", message: "Input customer phone number", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Search Customers", style: .default) { (_) in
            
            let alertFieldText = alertController.textFields?[0].text
            
            if alertFieldText != "" {
                
                
                //Check Firebase for customer
                let ref = Database.database().reference().child("customers").child(alertFieldText!)
                ref.observe(.value, with: { (snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    
                    //If there's been a match...
                    if value != nil {
                        // Populate text fields and disable interaction to pre-populated fields
                        self.phoneTextField.text = alertFieldText
                        self.phoneTextField.isUserInteractionEnabled = false
                        self.phoneTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                        
                        self.firstNameTextField.text = value?["firstName"] as? String ?? ""
                        self.firstNameTextField.isUserInteractionEnabled = false
                        self.firstNameTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                        
                        self.lastNameTextField.text = value?["lastName"] as? String ?? ""
                        self.lastNameTextField.isUserInteractionEnabled = false
                        self.lastNameTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                        
                        self.addressTextField.text = value?["streetAddress"] as? String ?? ""
                        self.addressTextField.isUserInteractionEnabled = false
                        self.addressTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                        
                        self.aptTextField.text = value?["apt"] as? String ?? ""
                        self.aptTextField.isUserInteractionEnabled = false
                        self.aptTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                        
                        self.cityTextField.text = value?["city"] as? String ?? ""
                        self.cityTextField.isUserInteractionEnabled = false
                        self.cityTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                        
                        self.stateTextField.text = value?["state"] as? String ?? ""
                        self.stateTextField.isUserInteractionEnabled = false
                        self.stateTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                        
                        self.zipTextField.text = value?["zip"] as? String ?? ""
                        self.zipTextField.isUserInteractionEnabled = false
                        self.zipTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                        
                        self.emailTextField.text = value?["email"] as? String ?? ""
                        self.emailTextField.isUserInteractionEnabled = false
                        self.emailTextField.backgroundColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1.0)
                    
                    } else {
                       self.displayNoCustomerAlert("No Result", alertString: "No such customer has been found. Please try again or create a new customer.")
                    }
                    
                    
                    
                })
                
            } else {
                // user did not fill field
                self.displayNoCustomerAlert("Field Empty", alertString: "You must enter a valid phone number to search for a customer.")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Add/Edit Customer", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Primary Phone Number"
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //funtion for displaying alert controller
    func displayNoCustomerAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default) { (_) in
        
            self.displayLookupAlert()
            
        }
        
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
