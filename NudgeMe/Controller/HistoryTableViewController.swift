//
//  HistoryTableViewController.swift
//  NudgeMe
//
//  Created by Joab Maldonado on 12/11/22.
//

import Foundation
import UIKit
import CoreData

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
}

class HistoryTableViewController: UITableViewController {
    
    @IBAction func clearHistoryButton(_ sender: Any) {
        deleteStoreReminders()
    }
    
    /// A date formatter for date text in reminder  cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    // MARK: CoreData
    
    //access the reminder array in CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var message: Message!
    var fetchedResultsController:NSFetchedResultsController<Message>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Message> = Message.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    func deleteStoreReminders() {
        for message in fetchedResultsController.fetchedObjects! {
            context.delete(message)
            try? context.save()
            setupFetchedResultsController()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func deleteMessage(at indexPath: IndexPath) {
        let messageToDelete = fetchedResultsController.object(at: indexPath)
        context.delete(messageToDelete)
        try? context.save()
        setupFetchedResultsController()
        DispatchQueue.main.async {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }
    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //fetch reminder count from core data
        return fetchedResultsController.fetchedObjects?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get reminder data from core data and display
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! HistoryTableViewCell
        let aMessage = fetchedResultsController.object(at: indexPath)
        
        //Set the text
        cell.messageLabel.text = aMessage.text
        
        if let creationDate = aMessage.creationDate {
            cell.createdDateLabel.text = dateFormatter.string(from: creationDate)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            deleteMessage(at: indexPath)
        }
    }
    
    
}
