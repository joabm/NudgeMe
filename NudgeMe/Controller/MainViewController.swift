//
//  MainViewController.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 11/5/22.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    var category: Category!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController: NSFetchedResultsController<Category>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addCategoryObject(name: "mind")
        addCategoryObject(name: "body")
        addCategoryObject(name: "soul")
        
    }
    
    func addCategoryObject(name:String) {
        let category = Category(context: context)
        category.name = name
        try? context.save()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "mind" {
//            let nextVC = segue.destination as? MindViewController
//            //get mind category object
//        } else if segue.identifier == "body" {
//            let  nextVC = segue.destination as? BodyViewController
//            //get body category object
//        } else if segue.identifier == "sould" {
//            let nextVC = segue.destination as? SoulViewController
//            //bet sould category object
//        }
//    }

}

