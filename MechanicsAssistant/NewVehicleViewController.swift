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

//String extension to filter all non-digits from input
extension String {
    
    var justDigits: String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}

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
    @IBOutlet weak var mileageTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        activityIndicator.isHidden = true
        
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
        mileageTextField.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let vehicleRef = Database.database().reference(withPath: "vehicles")
        let customerRef = Database.database().reference(withPath: "customers")
        vehicleRef.removeAllObservers()
        customerRef.removeAllObservers()
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
        let refMileage = ref.child("mileage")
        let refServices = ref.child("services")
        let refStatuses = ref.child("statuses")
        let refBusiness = ref.child("business")
        let refLocation = ref.child("location")
        
        //if apt field is empty, populate it
        if aptTextField.text == "" {
            aptTextField.text = "N/A"
        }
        
        //if no fields (except apt) are empty...
        if firstNameTextField.text != "" && lastNameTextField.text != "" && makeTextField.text != "" && modelTextField.text != "" && yearTextField.text != "" && colorTextField.text != "" &&
            addressTextField.text != "" && cityTextField.text != "" && stateTextField.text != "" &&
            zipTextField.text != "" && phoneTextField.text != "" && emailTextField.text != "" &&
            servicesTextField.text != "" && vinTextField.text != "" && mileageTextField.text != "" {
            
            //Create service array from service text field by separating items by commas
            var serviceArray = servicesTextField.text?.components(separatedBy: ", ")
            
            //Remove any empty items or items that would duplicate existing services from serviceArray
            var itemNumber = 0
            for item in serviceArray! {
                if item == "Check Air Filter" || item == "Check Battery Cables" || item == "Check Battery Fluid" || item == "Check Belts" || item == "Check Brake Fluid Level" || item == "Check Coolant" || item == "Check Horn" || item == "Check Hoses" || item == "Check Lights" || item == "Check Oil Level" || item == "Check Power Steering Fluid" || item == "Check Tire Pressure" || item == "Check Transmission Fluid Level" || item == "Check Tire Tread Depth" || item == "Check Windshield Washer Fluid" {
                    serviceArray?.remove(at: itemNumber)
                }
                if item.characters.count == 0 || item == "" {
                    serviceArray?.remove(at: itemNumber)
                }else{
                    itemNumber += 1
                }
            }
            
            //...and entered services are equal to or less than 5 and greater than 0...
            if (serviceArray?.count)! <= 5 && (serviceArray?.count)! > 0 {
                
                //...and device is connected to the internet,
                if isInternetAvailable() == true {
                    
                    //First, remove all non-numeric characters from phone, year, zip, and mileage user inputs
                    let inputPhoneNumber = self.phoneTextField.text?.justDigits
                    self.phoneTextField.text = inputPhoneNumber
                    
                    let inputYear = self.yearTextField.text?.justDigits
                    self.yearTextField.text = inputYear
                    
                    let inputZip = self.zipTextField.text?.justDigits
                    self.zipTextField.text = inputZip
                    
                    let inputMileage = self.mileageTextField.text?.justDigits
                    self.mileageTextField.text = inputMileage
                    
                    //Then, check if all fields contain correct input
                    if (firstNameTextField.text?.characters.count)! > 30 || (lastNameTextField.text?.characters.count)! > 30 || (makeTextField.text?.characters.count)! > 23 || (modelTextField.text?.characters.count)! > 20 ||
                        (yearTextField.text?.characters.count)! != 4 || (colorTextField.text?.characters.count)! > 20 || (aptTextField.text?.characters.count)! > 20 || (cityTextField.text?.characters.count)! > 30 || (stateTextField.text?.characters.count)! > 2 || (addressTextField.text?.characters.count)! > 40 || (zipTextField.text?.characters.count)! != 5 || (phoneTextField.text?.characters.count)! != 10 || !isValidEmail(testStr: emailTextField.text!) || (vinTextField.text?.characters.count)! < 11 || (vinTextField.text?.characters.count)! > 17 || (mileageTextField.text?.characters.count)! > 7 {
                        
                        if (firstNameTextField.text?.characters.count)! > 30 {
                            showTextFieldPlaceholder(textfield: firstNameTextField, placeholderString: "Must be less than 30 characters")
                        }
                        
                        if (lastNameTextField.text?.characters.count)! > 30 {
                            showTextFieldPlaceholder(textfield: lastNameTextField, placeholderString: "Must be less than 30 characters")
                        }
                        
                        if (makeTextField.text?.characters.count)! > 23 {
                            showTextFieldPlaceholder(textfield: makeTextField, placeholderString: "Must be less than 23 characters")
                        }
                        
                        if (modelTextField.text?.characters.count)! > 40 {
                            showTextFieldPlaceholder(textfield: modelTextField, placeholderString: "Make must be less than 40 characters")
                        }
                        
                        if (yearTextField.text?.characters.count)! != 4 {
                            showTextFieldPlaceholder(textfield: yearTextField, placeholderString: "Must be a 4-digit number")
                        }
                        
                        if (colorTextField.text?.characters.count)! > 20 {
                            showTextFieldPlaceholder(textfield: colorTextField, placeholderString: "Must be less than 20 characters")
                        }
                        
                        if (addressTextField.text?.characters.count)! > 40 {
                            showTextFieldPlaceholder(textfield: addressTextField, placeholderString: "Address must be less than 40 characters")
                        }
                        
                        if (aptTextField.text?.characters.count)! > 20 {
                            showTextFieldPlaceholder(textfield: aptTextField, placeholderString: "Too long")
                        }
                        
                        if (cityTextField.text?.characters.count)! > 30 {
                            showTextFieldPlaceholder(textfield: cityTextField, placeholderString: "City must be less than 30 characters")
                        }
                        
                        if (stateTextField.text?.characters.count)! > 2 {
                            showTextFieldPlaceholder(textfield: stateTextField, placeholderString: "AA")
                        }
                        
                        if zipTextField.text?.characters.count != 5 {
                            showTextFieldPlaceholder(textfield: zipTextField, placeholderString: "5-digits")
                        }
                        
                        if phoneTextField.text?.characters.count != 10 {
                            showTextFieldPlaceholder(textfield: phoneTextField, placeholderString: "Must be 10-digit number")
                        }
                        
                        if !isValidEmail(testStr: emailTextField.text!) {
                            showTextFieldPlaceholder(textfield: emailTextField, placeholderString: "Enter a valid email")
                        }
                        
                        if (vinTextField.text?.characters.count)! < 11 || (vinTextField.text?.characters.count)! > 17 {
                            showTextFieldPlaceholder(textfield: vinTextField, placeholderString: "VIN must be between 11 and 17 characters")
                        }
                        
                        if (mileageTextField.text?.characters.count)! > 7 {
                            showTextFieldPlaceholder(textfield: mileageTextField, placeholderString: "Mileage must contain less than 7 characters")
                        }
                        
                        return
                    }
                    
                    
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
                    refMileage.setValue(mileageTextField.text)
                    refBusiness.setValue(currentBusinessID)
                    refLocation.setValue(currentBusinessLocation)
                    
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
                showTextFieldPlaceholder(textfield: servicesTextField, placeholderString: "You may only have a max of 5 services and must have at least one")
            }
            
            //If one or more of the fields are empty (other than apt), show error action (shake).
        } else {
            if firstNameTextField.text == "" {
                showTextFieldPlaceholder(textfield: firstNameTextField, placeholderString: "Please Enter First Name")
            }
            if lastNameTextField.text == "" {
                showTextFieldPlaceholder(textfield: lastNameTextField, placeholderString: "Please Enter Last Name")
            }
            if makeTextField.text == "" {
                showTextFieldPlaceholder(textfield: makeTextField, placeholderString: "Please Enter Vehicle Make")
            }
            if modelTextField.text == "" {
                showTextFieldPlaceholder(textfield: modelTextField, placeholderString: "Please Enter Vehicle Model")
            }
            if yearTextField.text == "" {
                showTextFieldPlaceholder(textfield: yearTextField, placeholderString: "Please Enter Vehicle Year")
            }
            if colorTextField.text == "" {
                showTextFieldPlaceholder(textfield: colorTextField, placeholderString: "Please Enter Vehicle Color")
            }
            if addressTextField.text == "" {
                showTextFieldPlaceholder(textfield: addressTextField, placeholderString: "Please Enter Customer Address")
            }
            if cityTextField.text == "" {
                showTextFieldPlaceholder(textfield: cityTextField, placeholderString: "Please Enter Customer City")
            }
            if stateTextField.text == "" {
                showTextFieldPlaceholder(textfield: stateTextField, placeholderString: "Please Enter Customer State")
            }
            if zipTextField.text == "" {
                showTextFieldPlaceholder(textfield: zipTextField, placeholderString: "Please Enter Customer Zip")
            }
            if phoneTextField.text == "" {
                showTextFieldPlaceholder(textfield: phoneTextField, placeholderString: "Please Enter Customer Phone")
            }
            if emailTextField.text == "" {
                showTextFieldPlaceholder(textfield: emailTextField, placeholderString: "Please Enter Customer Email")
            }
            if vinTextField.text == "" {
                showTextFieldPlaceholder(textfield: vinTextField, placeholderString: "Please Enter Vehicle Vin Number")
            }
            
            if servicesTextField.text == "" {
                showTextFieldPlaceholder(textfield: servicesTextField, placeholderString: "Please Enter Services Required")
            }
            
            if mileageTextField.text == "" {
                showTextFieldPlaceholder(textfield: mileageTextField, placeholderString: "Please Enter Vehicle Mileage")
            }
            
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
                
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                
                //Check Firebase for customer
                let ref = Database.database().reference().child("customers").child(alertFieldText!)
                ref.observe(.value, with: { (snapshot) in
                    
                    let value = snapshot.value as? NSDictionary
                    
                    //If there's been a match...
                    if value != nil {
                        // Populate text fields
                        self.phoneTextField.text = alertFieldText
                        
                        self.firstNameTextField.text = value?["firstName"] as? String ?? ""
                        
                        self.lastNameTextField.text = value?["lastName"] as? String ?? ""
                        
                        self.addressTextField.text = value?["streetAddress"] as? String ?? ""
                        
                        self.aptTextField.text = value?["apt"] as? String ?? ""
                        
                        self.cityTextField.text = value?["city"] as? String ?? ""
                        
                        self.stateTextField.text = value?["state"] as? String ?? ""
                        
                        self.zipTextField.text = value?["zip"] as? String ?? ""
                        
                        self.emailTextField.text = value?["email"] as? String ?? ""
                        
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        
                    } else {
                        self.displayNoCustomerAlert("No Result", alertString: "No such customer has been found. Please try again or create a new customer.")
                    }
                    
                })
                
            } else {
                // user did not fill field
                self.displayNoCustomerAlert("Field Empty", alertString: "You must enter a valid phone number to search for a customer.")
            }
        }
        
        let editAction = UIAlertAction(title: "Add/Edit Customer", style: .default) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Primary Phone Number"
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(editAction)
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
    
    //Function for email validation using regular expression.
    func isValidEmail(testStr:String) -> Bool {
        let emailRegularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegularExpression)
        return emailPredicate.evaluate(with: testStr)
    }
    
}
