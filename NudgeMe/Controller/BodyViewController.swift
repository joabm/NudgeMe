//
//  BodyViewController.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/13/22.
//

import Foundation
import UIKit
import CoreData


class BodyViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var reminderOne: UITextField!
    @IBOutlet weak var reminderTwo: UITextField!
    @IBOutlet weak var reminderThree: UITextField!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTextFieldValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func applyTextFieldValues(){
        reminderOne.text = UserDefaults.standard.string(forKey: "bodyOne")
        reminderTwo.text = UserDefaults.standard.string(forKey: "bodyTwo")
        reminderThree.text = UserDefaults.standard.string(forKey: "bodyThree")
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

extension BodyViewController {
    func textFieldDidEndEditing(_ textField: UITextField) {
        UserDefaults.standard.set(reminderOne.text, forKey: "bodyOne")
        UserDefaults.standard.set(reminderTwo.text, forKey: "bodyTwo")
        UserDefaults.standard.set(reminderThree.text, forKey: "bodyThree")
    }

}
