//
//  SoulViewController.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/13/22.
//

import Foundation
import UIKit
import CoreData


class SoulViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: CoreData
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    //var dataController: DataController!
//    var fetchedResultsController: NSFetchedResultsController<Message>!
//
//    fileprivate func setupFetchResultsController() {
//        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("Data Error: \(error.localizedDescription)")
//        }
//    }
    
    // MARK: Outlets
    
    @IBOutlet weak var soulTextView: UITextView!
    @IBOutlet weak var reminderOne: UITextField!
    @IBOutlet weak var reminderTwo: UITextField!
    @IBOutlet weak var reminderThree: UITextField!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //createMindArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Keyboard controls
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        //removes both observers at once
        NotificationCenter.default.removeObserver(self)
    }
    
    //keeps the keyboard from covering the input field by removing the height of the keyboard from the views frame.
    @objc func keyboardWillShow(_ notification:Notification) {
        if reminderOne.isEditing && UIDevice.current.orientation.isLandscape {
            view.frame.origin.y = -150 //reduce verticle frame
        } else if reminderTwo.isEditing && UIDevice.current.orientation.isLandscape || reminderThree.isEditing && UIDevice.current.orientation.isLandscape {
            view.frame.origin.y = -210 //reduce verticle frame
        } else {
            view.frame.origin.y = -325 //reduce verticle frame
        }
    }
    
    //resets the frame height
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    //dismisses the keyboard when the return button is selected by the user
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
}
