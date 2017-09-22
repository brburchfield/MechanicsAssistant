//
//  ChecklistViewController.swift
//  MechanicsAssistant
//
//  Created by Beau Burchfield on 8/16/17.
//  Copyright © 2017 Beau Burchfield. All rights reserved.
//

import UIKit
import Firebase
import MessageUI
import SystemConfiguration
import AEXML

open class CustomChecklistCell:  UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    
}

class ChecklistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    //set empty variables
    var userFirstName = "", userLastName = "", userMake = "", userModel = "", userVin = "", userYear = "", userMileage = "", userEmail = "", mainService = "", airFilterStatus = "", batteryCablesStatus = "", batteryFluidStatus = "", beltsStatus = "", brakeLevelStatus = "", coolantLevelStatus = "", hornStatus = "", hosesStatus = "", lightsStatus = "", mainServicesStatus = "", oilLevelStatus = "", steerLevelStatus = "", tirePressureStatus = "", transLevelStatus = "", treadDepthStatus = "", washerLevelStatus = ""
    
    var mainService0exists = false
    var mainService1exists = false
    var mainService2exists = false
    var mainService3exists = false
    var mainService4exists = false
    var serviceNumber0 = ""
    var serviceNumber1 = ""
    var serviceNumber2 = ""
    var serviceNumber3 = ""
    var serviceNumber4 = ""
    var emailsComplete = false
    
    //array of item titles for cell labels
    var titles = ["Check Air Filter", "Check Battery Cables", "Check Battery Fluid", "Check Belts", "Check Brake Fluid Level", "Check Coolant", "Check Horn", "Check Hoses", "Check Lights", "Check Oil Level", "Check Power Steering Fluid", "Check Tire Pressure", "Check Transmission Fluid Level", "Check Tire Tread Depth", "Check Windshield Washer Fluid"]
    
    //array of status names for Firebase
    var statusNames = ["airFilter", "batteryCables", "batteryFluid", "belts", "brakeLevel", "coolantLevel", "horn", "hoses", "lights", "oilLevel", "steerLevel", "tirePressure", "transLevel", "treadDepth", "washerLevel"]
    
    //empty array for status values
    var statuses: [String] = []
    
    var noteText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Link table view cells with custom cell
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1.0)
        self.tableView.register(UINib(nibName: "CustomChecklistCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        //Get user data info from Firebase and set variables
        let ref = Database.database().reference().child("vehicles").child("\(currentID)")
        ref.observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.userFirstName = value?["firstName"] as? String ?? ""
            self.userLastName = value?["lastName"] as? String ?? ""
            self.userMake = value?["make"] as? String ?? ""
            self.userModel = value?["model"] as? String ?? ""
            self.userYear = value?["year"] as? String ?? ""
            self.userVin = value?["vin"] as? String ?? ""
            self.userMileage = value?["mileage"] as? String ?? ""
            self.userEmail = value?["email"] as? String ?? ""
        })
        
        //set statuses from Firebase
        ref.child("statuses").observe(.value, with: { (snapshot) in
            //delete statuses information (so that Firebase change doesn't append when data is changed)
            self.statuses = []
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.statuses.append(value?["airFilter"] as? String ?? "")
            self.statuses.append(value?["batteryCables"] as? String ?? "")
            self.statuses.append(value?["batteryFluid"] as? String ?? "")
            self.statuses.append(value?["belts"] as? String ?? "")
            self.statuses.append(value?["brakeLevel"] as? String ?? "")
            self.statuses.append(value?["coolantLevel"] as? String ?? "")
            self.statuses.append(value?["horn"] as? String ?? "")
            self.statuses.append(value?["hoses"] as? String ?? "")
            self.statuses.append(value?["lights"] as? String ?? "")
            self.statuses.append(value?["oilLevel"] as? String ?? "")
            self.statuses.append(value?["steerLevel"] as? String ?? "")
            self.statuses.append(value?["tirePressure"] as? String ?? "")
            self.statuses.append(value?["transLevel"] as? String ?? "")
            self.statuses.append(value?["treadDepth"] as? String ?? "")
            self.statuses.append(value?["washerLevel"] as? String ?? "")
            
            
            if(value?["mainService0"] != nil){
                self.statuses.append(value?["mainService0"] as? String ?? "")
                self.statusNames.append("mainService0")
                self.mainService0exists = true
            }
            if(value?["mainService1"] != nil){
                self.statuses.append(value?["mainService1"] as? String ?? "")
                self.statusNames.append("mainService1")
                self.mainService1exists = true
            }
            if(value?["mainService2"] != nil){
                self.statuses.append(value?["mainService2"] as? String ?? "")
                self.statusNames.append("mainService2")
                self.mainService2exists = true
            }
            
            if(value?["mainService3"] != nil){
                self.statuses.append(value?["mainService3"] as? String ?? "")
                self.statusNames.append("mainService3")
                self.mainService3exists = true
            }
            if(value?["mainService4"] != nil){
                self.statuses.append(value?["mainService4"] as? String ?? "")
                self.statusNames.append("mainService4")
                self.mainService4exists = true
            }
            
            self.delayWithSeconds(1){
                self.tableView.reloadData()
            }
            
        })
        
        delayWithSeconds(1){
            //get Main Service strings from Firebase
            ref.child("services").observe(.value, with: { (snapshot) in
                
                
                if self.mainService0exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.serviceNumber0 = value?["serviceNumber0"] as? String ?? ""
                    self.mainService.append(self.serviceNumber0)
                    self.titles.append(self.serviceNumber0)
                }
                if self.mainService1exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.serviceNumber1 = value?["serviceNumber1"] as? String ?? ""
                    self.mainService.append(", " + self.serviceNumber1)
                    self.titles.append(self.serviceNumber1)
                }
                if self.mainService2exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.serviceNumber2 = value?["serviceNumber2"] as? String ?? ""
                    self.mainService.append(", " + self.serviceNumber2)
                    self.titles.append(self.serviceNumber2)
                }
                if self.mainService3exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.serviceNumber3 = value?["serviceNumber3"] as? String ?? ""
                    self.mainService.append(", " + self.serviceNumber3)
                    self.titles.append(self.serviceNumber3)
                }
                if self.mainService4exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.serviceNumber4 = value?["serviceNumber4"] as? String ?? ""
                    self.mainService.append(", " + self.serviceNumber4)
                    self.titles.append(self.serviceNumber4)
                }
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            })
            
        }
        
        //When user removes a vehicle item, pop navigation
        let fullRef = Database.database().reference().child("vehicles")
        fullRef.observe(.childRemoved, with: { (snapshot) in
            self.navigationController?.popViewController(animated: true)
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let ref = Database.database().reference().child("vehicles")
        ref.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.statuses.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->  UITableViewCell{
        
        //use custom cell in table view
        let cell: CustomChecklistCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomChecklistCell
        
        //set item label to corresponding titles string
        cell.itemLabel.text = titles[indexPath.row]
        
        //set label colors based on whether the item is complete or not; bold and resize main service
        if indexPath.row > 14 && statuses[indexPath.row] == "no"{
            cell.itemLabel.textColor = UIColor.white
            cell.itemLabel.font = UIFont.boldSystemFont(ofSize: 40.0)
        } else if statuses[indexPath.row] == "yes"{
            cell.itemLabel.textColor = UIColor.green
            if indexPath.row > 14 {
                cell.itemLabel.font = UIFont.boldSystemFont(ofSize: 40.0)
            } else {
                cell.itemLabel.font = UIFont.systemFont(ofSize: 30.0)
            }
        }else {
            cell.itemLabel.textColor = UIColor(red:0.72, green:0.72, blue:0.72, alpha:1.0)
            cell.itemLabel.font = UIFont.systemFont(ofSize: 30.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _: UITableViewCell = tableView.cellForRow(at: indexPath)!
        
        //Toggle item completion
        let ref = Database.database().reference().child("vehicles").child("\(currentID)")
        
        if statuses[indexPath.row] == "no"{
            
            statuses[indexPath.row] = "yes"
            ref.child("statuses").updateChildValues([statusNames[indexPath.row]: "yes"])
            
        } else if statuses[indexPath.row] == "yes"{
            
            statuses[indexPath.row] = "no"
            ref.child("statuses").updateChildValues([statusNames[indexPath.row]: "no"])
            
        }
        
        //reload table view to allow color change
        tableView.reloadData()
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
        print("Began Editing Text Field!")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        print("Ended Editing Text Field!")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("Ended Editing Text Field!")
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func completeButtonPressed(_ sender: UIButton) {
        var numberCompleted = 0
        
        //if any items are incomplete, show alert
        for value in statuses {
            if value == "no"{
                self.displayAlert("Not Complete", alertString: "You must complete each checklist item before completing a vehicle.")
                return
            }else {
                numberCompleted += 1
            }
            
            //otherwise, display completion alert
            if numberCompleted == 16{
                displayCompletionAlert()
            }
        }
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
        self.displayEditServicesAlert()
        
    }
    
    func displayAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayNoDataAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default) { (_) in
            
            self.displayEditServicesAlert()
            
        }
        
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayEditServicesAlert(){
        var servicesString = ""
        
        if serviceNumber0 != "" {
            servicesString.append(serviceNumber0)
        }
        
        if serviceNumber1 != "" {
            servicesString.append(", " + serviceNumber1)
        }
        
        if serviceNumber2 != "" {
            servicesString.append(", " + serviceNumber2)
        }
        
        if serviceNumber3 != "" {
            servicesString.append(", " + serviceNumber3)
        }
        
        if serviceNumber4 != "" {
            servicesString.append(", " + serviceNumber4)
        }
        
        let editServicesAlertController = UIAlertController(title: "Edit Main Services", message: "Input new service information", preferredStyle: .alert)
        
        editServicesAlertController.addTextField{ (textField) in
            textField.placeholder = "Main Services"
            textField.text = servicesString
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let confirmAction = UIAlertAction(title: "Change Services", style: .default) { (_) in
            let alertFieldText = editServicesAlertController.textFields?[0].text
            
            if alertFieldText != "" {
                
                //Create service array from service text field by separating items by commas
                var serviceArray = alertFieldText?.components(separatedBy: ", ")
                
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
                
                //if entered services are equal to or less than 5 and greater than 0...
                if (serviceArray?.count)! <= 5 && (serviceArray?.count)! > 0 {
                    
                    //...and device is connected to the internet,
                    if self.isInternetAvailable() == true {
                        
                        //TODO: Now edit services in Firebase
                        
                        let statusesRef = Database.database().reference().child("vehicles").child("\(currentID)").child("statuses")
                        
                        if serviceArray!.count < 5 {
                            statusesRef.child("mainService4").removeValue()
                            if serviceArray!.count < 4 {
                                statusesRef.child("mainService3").removeValue()
                                if serviceArray!.count < 3 {
                                    statusesRef.child("mainService2").removeValue()
                                    if serviceArray!.count < 2 {
                                        statusesRef.child("mainService1").removeValue()
                                    }
                                }
                            }
                        }
                        
                        // Remove all services
                        Database.database().reference().child("vehicles").child("\(currentID)").child("services").removeValue()
                        
                        var childNumber = 0
                        
                        // Replace all services
                        for item in serviceArray!{
                            let thisRef = Database.database().reference().child("vehicles").child("\(currentID)").child("services").child("serviceNumber\(childNumber)")
                            thisRef.setValue(item)
                            statusesRef.child("mainService\(childNumber)").setValue("no")
                            childNumber += 1
                        }
                        
                        // pop view controller
                        self.navigationController?.popViewController(animated: false)
                        
                    } else {
                        self.displayAlert("No Connection", alertString: "You must have internet connection to edit services.")
                    }
                } else {
                    self.displayNoDataAlert("Invalid Services", alertString: "You must have no more than five and no less than one service(s).")
                }
                
            } else {
                self.displayNoDataAlert("No Services Entered", alertString: "You must enter services before completing this action.")
            }
            
        }
        
        
        editServicesAlertController.addAction(confirmAction)
        editServicesAlertController.addAction(cancelAction)
        
        self.present(editServicesAlertController, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        if result == .cancelled {
            controller.dismiss(animated: true, completion: { (success) -> Void in
                
            })
        } else {
            
            if emailsComplete {
                
                //Remove data from Firebase
                let ref = Database.database().reference().child("vehicles").child("\(currentID)")
                ref.removeValue()
                // Dismiss the mail compose view controller.
                controller.dismiss(animated: true, completion: { (success) -> Void in
                    //pop back to vehicle list screen
                    self.navigationController?.popViewController(animated: true)
                })
                
            } else {
                controller.dismiss(animated: true, completion: { (success) -> Void in
                    self.sendCustomerEmail()
                })
            }
        }
    }
    
    //function for displaying alert and handling vehicle completion
    func displayCompletionAlert() {
        let alertController = UIAlertController(title: "Complete Vehicle", message: "Add notes:", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Complete", style: .default) { (_) in
            //setup notes field
            if let field = alertController.textFields?[0] {
                if field.text == "" {
                    self.noteText = "N/A"
                } else {
                    self.noteText = field.text!
                }
                if !MFMailComposeViewController.canSendMail() {
                    self.displayAlert("Can't Email", alertString: "Mail services are not available")
                    return
                } else {
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = DateFormatter.Style.short
                    formatter.timeStyle = .medium
                    
                    let dateString = formatter.string(from: Date())
                    
                    //Create XML document
                    let xmlDocument = AEXMLDocument()
                    let attributes = ["xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" : "http://www.w3.org/2001/XMLSchema"]
                    let customerData = xmlDocument.addChild(name: "customer", attributes: attributes)
                    customerData.addChild(name: "customerName", value: "\(self.userFirstName) \(self.userLastName)")
                    customerData.addChild(name: "vehicleMake", value: self.userMake)
                    customerData.addChild(name: "vehicleModel", value: self.userModel)
                    customerData.addChild(name: "vehicleYear", value: self.userYear)
                    customerData.addChild(name: "vehicleMileage", value: self.userMileage)
                    customerData.addChild(name: "vehicleVIN", value: self.userVin)
                    customerData.addChild(name: "completionDate", value: dateString)
                    customerData.addChild(name: "mainServices", value: self.mainService)
                    customerData.addChild(name: "notes", value: self.noteText)
                    
                    //Create JSON document
                    let jsonObject: NSMutableDictionary = NSMutableDictionary()
                    jsonObject.setValue("\(self.userFirstName) \(self.userLastName)", forKey: "customerName")
                    jsonObject.setValue(self.userMake, forKey: "vehicleMake")
                    jsonObject.setValue(self.userModel, forKey: "vehicleModel")
                    jsonObject.setValue(self.userYear, forKey: "vehicleYear")
                    jsonObject.setValue(self.userMileage, forKey: "vehicleMileage")
                    jsonObject.setValue(self.userVin, forKey: "vehicleVIN")
                    jsonObject.setValue(dateString, forKey: "completionDate")
                    jsonObject.setValue(self.mainService, forKey: "mainServices")
                    jsonObject.setValue(self.noteText, forKey: "notes")
                    
                    var jsonData: Data!
                    
                    do {
                        jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as Data!
                        
                    } catch _ {
                        print ("JSON Failure")
                    }
                    
                    
                    
                    self.delayWithSeconds(1){
                        //Actually send email
                        let composeVC = MFMailComposeViewController()
                        composeVC.mailComposeDelegate = self
                        // Configure the fields of the interface.
                        composeVC.setToRecipients([currentBusinessEmail])
                        composeVC.setSubject("\(self.userFirstName) \(self.userLastName)'s vehicle completed")
                        composeVC.setMessageBody("Vehicle Completed\n\nCustomer Name: \(self.userFirstName) \(self.userLastName)\n\nMake: \(self.userMake) | Model: \(self.userModel) | Year: \(self.userYear)\n\nMileage: \(self.userMileage)\n\nVin Number: \(self.userVin)\n\nCompletion Time: \(dateString)\n\nMain Service Performed: \(self.mainService)\n\nAdditional Notes: \(self.noteText)", isHTML: false)
                        //Attach XML file
                        composeVC.addAttachmentData(xmlDocument.xml.data(using: .utf8)!, mimeType: "application/xml", fileName: "XMLDoc")
                        //Attach JSON file
                        composeVC.addAttachmentData(jsonData, mimeType: "application/json", fileName: "JSONDoc")
                        // Present the view controller modally.
                        self.present(composeVC, animated: true, completion: nil)
                        
                    }
                }
                
            } else {
                print("No text field")
                return
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Add notes"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func sendCustomerEmail () {
        emailsComplete = true
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = .medium
        
        let dateString = formatter.string(from: Date())
        
        //Actually send email
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients([self.userEmail])
        composeVC.setSubject("Your vehicle has been completed!")
        composeVC.setMessageBody(" \(self.userFirstName),\n\nWe've finished work on your \(self.userMake) on \(dateString). Please find notes and recommendations on your vehicle below.\n\n\nNotes: \(self.noteText)", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
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
