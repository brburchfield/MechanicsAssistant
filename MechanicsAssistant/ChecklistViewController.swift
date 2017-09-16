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

open class CustomChecklistCell:  UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel!
    
}

class ChecklistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    //set empty variables
    var userFirstName = ""
    var userLastName = ""
    var userMake = ""
    var userModel = ""
    var userVin = ""
    var userYear = ""
    var userMileage = ""
    var userEmail = ""
    var mainService = ""
    var airFilterStatus = ""
    var batteryCablesStatus = ""
    var batteryFluidStatus = ""
    var beltsStatus = ""
    var brakeLevelStatus = ""
    var coolantLevelStatus = ""
    var hornStatus = ""
    var hosesStatus = ""
    var lightsStatus = ""
    var mainServicesStatus = ""
    var oilLevelStatus = ""
    var steerLevelStatus = ""
    var tirePressureStatus = ""
    var transLevelStatus = ""
    var treadDepthStatus = ""
    var washerLevelStatus = ""
    
    var mainService0exists = false
    var mainService1exists = false
    var mainService2exists = false
    var mainService3exists = false
    var mainService4exists = false
    
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
                    self.titles.append("\(value?["serviceNumber0"] as? String ?? "")")
                }
                if self.mainService1exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.titles.append("\(value?["serviceNumber1"] as? String ?? "")")
                }
                if self.mainService2exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.titles.append("\(value?["serviceNumber2"] as? String ?? "")")
                }
                if self.mainService3exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.titles.append("\(value?["serviceNumber3"] as? String ?? "")")
                }
                if self.mainService4exists == true {
                    let value = snapshot.value as? NSDictionary
                    self.titles.append("\(value?["serviceNumber4"] as? String ?? "")")
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
        let ref = Database.database().reference().child("vehicles").child("\(currentID)")
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
            print(statusNames[indexPath.row])
            ref.child("statuses").updateChildValues([statusNames[indexPath.row]: "yes"])
            
        } else if statuses[indexPath.row] == "yes"{
            
            statuses[indexPath.row] = "no"
            print(statusNames[indexPath.row])
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
                displayAlert("Not Complete", alertString: "You must complete each checklist item before completing a vehicle.")
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
    
    //function for displaying an alert controller
    func displayAlert(_ alertTitle: String, alertString: String){
        let alertController = UIAlertController(title: alertTitle, message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        let okButton = UIAlertAction(title:"Ok", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(okButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //function for sending email
    func sendEmail(subjectString: String, messageBody: String) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients([currentBusinessEmail, userEmail])
        composeVC.setSubject(subjectString)
        composeVC.setMessageBody(messageBody, isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
        print("EmailSent")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        //Remove data from Firebase
        let ref = Database.database().reference().child("vehicles").child("\(currentID)")
        ref.removeValue()
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: { (success) -> Void in
            //pop back to vehicle list screen
            self.navigationController?.popViewController(animated: true)
        })
        
        
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
                    
                    //Actually send email
                    self.sendEmail(subjectString: "\(self.userFirstName) \(self.userLastName)'s vehicle completed", messageBody: "Vehicle Completed\n\nCustomer Name: \(self.userFirstName) \(self.userLastName)\n\nMake: \(self.userMake) | Model: \(self.userModel) | Year: \(self.userYear)\n\nVin Number: \(self.userVin)\n\nCompletion Time: \(dateString)\n\nMain Service Performed: \(self.mainService)\n\nMileage: \(self.userMileage)\n\nAdditional Notes: \(self.noteText)")
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
    
}
