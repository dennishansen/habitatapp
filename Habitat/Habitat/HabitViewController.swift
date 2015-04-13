//
//  HabitViewController.swift
//  Habitat
//
//  Created by Brian Palma on 4/12/15.
//  Copyright (c) 2015 Eastman Labs, LLC. All rights reserved.
//

import UIKit

class HabitViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var habitController: HabitController!
    
    // MARK: - Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - View Life Cycle
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        habitController.saveHabits()
    }
    
    // MARK: - Editing
    
    @IBAction func editButtonTapped(sender: UIBarButtonItem?) {
        if !habitController.allHabits.isEmpty {
            super.setEditing(!editing, animated: true)
            tableView.setEditing(editing, animated: true)
        } else {
            super.setEditing(false, animated: true)
            tableView.setEditing(false, animated: true)
        }
        
        editButton.title = editing ? "Done" : "Edit"
    }
    
    // MARK: AddHabitVC Exit Segues
    
    @IBAction func cancel(segue: UIStoryboardSegue) {
        // This method needs to exist to trigger a modal dismissal without passing data
    }
    
    @IBAction func done(segue: UIStoryboardSegue) {
        if let habit = (segue.sourceViewController as! AddHabitViewController).habit {
            habitController.addHabit(habit)
            tableView.reloadData()
        }
    }
}

extension HabitViewController: HabitControllerDelegate {
    func habitController(habitController: HabitController, didRemoveFinalHabit habit: Habit) {
        editButtonTapped(nil)
    }
    
    func habitController(habitController: HabitController, didLoadHabits: [Habit]) {
        tableView.reloadData()
    }
}