//
//  MasterViewController.swift
//  ListJeet
//
//  Created by Baljeet Singh on 3/23/17.
//  Copyright © 2017 Langara. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    //var managedObjectContext: NSManagedObjectContext? = nil
    
    var listController = TaskManager.sharedInstance.fetchedResultsController
    
     @IBOutlet weak var taskImage: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.addNewTask))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
           
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        listController.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //To show the detail view controller when "Add" button is pressed from Master View Controller
    func addNewTask() {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let newTaskViewController = storyBoard.instantiateViewControllerWithIdentifier("DetailView")
        self.navigationController?.pushViewController(newTaskViewController, animated: true)
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.listController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
       
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.listController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.listController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = self.listController.objectAtIndexPath(indexPath) as! NSManagedObject
        
        //cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        
        self.configureCell(cell, withObject: object)
        return cell
    }
//    
    @IBAction func handleImageTap(sender: UITapGestureRecognizer ) {
//
//        if  sender.state == .Ended {
//            let tappedView = sender.view as! UITableView
//            let taskCell = UITableView.indexPathForCell(tappedView) as! UITableViewCell
//            
//            //let task = self.listController.objectAtIndexPath(indexPath)
//            
//            taskCell.setValue(TaskManager.DONE_TASK_IMAGE, forKey: "cellImage")
//            
//            do{
//                try TaskManager.sharedInstance.managedObjectContext.save()
//            } catch{
//                abort()
//            }
//            
////            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
//            
//            self.configureCell(taskCell, withObject: listController.objectAtIndexPath(<#T##indexPath: NSIndexPath##NSIndexPath#>) as! NSManagedObject)
//            
//        }
//        
//        
    }
    
    //override func tableview

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.listController.managedObjectContext
            context.deleteObject(self.listController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        cell.textLabel!.text = object.valueForKey("title")!.description
        cell.detailTextLabel?.text = TaskManager.sharedInstance.formatDateToString(object.valueForKey("timeStamp") as! NSDate)
        cell.imageView?.image = UIImage(imageLiteral: object.valueForKey("cellImage")!.description)
        
        
        print("I'm called")
    }

       func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
            case .Move:
                tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

   
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
//     func controllerDidChangeContent(controller: NSFetchedResultsController) {
//         // In the simplest, most efficient, case, reload the table view.
//         self.tableView.reloadData()
//     }
    

}

