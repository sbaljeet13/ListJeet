//
//  DetailViewController.swift
//  ListJeet
//
//  Created by Baljeet Singh on 3/23/17.
//  Copyright © 2017 Langara. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskField: UITextField!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var dateTimeButton: UIButton!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var detailText: UITextView!

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let task = self.detailItem {
            //Display existing task
            if let taskTitle = self.taskField{
                taskTitle.text = task.valueForKey("title")!.description
            }
            
            if let dateTime = self.dateTimeButton{
                dateTime.setTitle(TaskManager.sharedInstance.formatDateToString((task.valueForKey("timeStamp") as! NSDate)), forState: UIControlState.Normal)
            }
            
            if let timePicker = self.dateTimePicker{
                timePicker.setDate(task.valueForKey("timeStamp") as! NSDate, animated: false)
            }
            
            if let location = self.locationField {
                location.text = task.valueForKey("location")!.description
            }
            
            if let detail = detailText {
                detail.text = task.valueForKey("detail")!.description
            }
            
        } else{
            //Display new task
            if let taskTitle = self.taskField{
                taskTitle.text = ""
            }
            
            if let dateTime = self.dateTimeButton{
                dateTime.setTitle(TaskManager.sharedInstance.formatDateToString(dateTimePicker.date), forState: UIControlState.Normal)
            }
            
            if let location = self.locationField {
                location.text = ""
            }
            
            if let detail = detailText {
                detail.text = "Task Details"
                detail.textColor = UIColor.lightGrayColor()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveTask(){
        let title = self.taskField.text
        let date = self.dateTimePicker.date
        let location = self.locationField.text
        let detail = self.detailText.text
        let image = TaskManager.PENDING_TASK_IMAGE
        
        TaskManager.sharedInstance.insertNewObject(self, title: title!, date: date, location: location!, detail: detail, image: image)
    }
    
    func updateTask(){
        if let task = self.detailItem{
            task.setValue(self.taskField.text, forKey: "title")
            task.setValue(self.dateTimePicker.date, forKey: "timeStamp")
            task.setValue(self.locationField.text, forKey: "location")
            task.setValue(self.detailText.text, forKey: "detail")
            task.setValue(TaskManager.PENDING_TASK_IMAGE, forKey: "cellImage")
            
            do{
                try TaskManager.sharedInstance.managedObjectContext.save()
            } catch{
                abort()
            }
        }
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if let _ = self.detailItem{
            self.updateTask()
        } else{
            self.saveTask()
        }
        self.saveButton.enabled = false
    }
    
//    @IBAction func dateTimeButtonPressed(sender: AnyObject) {
//        
//        if dateTimePicker.hidden == false{
//            dateTimePicker.hidden = true
//        }
//        else{
//            dateTimePicker.hidden = false
//        }
//    }
    
    @IBAction func dateTimeRolled(sender: AnyObject) {
        dateTimeButton.setTitle(TaskManager.sharedInstance.formatDateToString(dateTimePicker.date), forState: UIControlState.Normal)
        self.saveButton.enabled = true
    }
    
    
    //Additional Features
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.saveButton.enabled = true
        
        return true
    }
    

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.saveButton.enabled = true
        
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if self.detailItem == nil {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
}

