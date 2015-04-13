//
//  HabitController.swift
//  Habitat
//
//  Created by Brian Palma on 4/12/15.
//  Copyright (c) 2015 Eastman Labs, LLC. All rights reserved.
//

import UIKit

@objc protocol HabitControllerDelegate {
    func habitController(habitController: HabitController, didAddHabit habit: Habit, isFirst first: Bool)
    func habitController(habitController: HabitController, didRemoveHabit habit: Habit, wasLast last: Bool)
    func habitController(habitController: HabitController, didLoadHabits: [Habit])
}

class HabitController: NSObject {
    
    @IBOutlet weak var delegate: AnyObject? {
        didSet {
            habitControllerDelegate = delegate as? HabitControllerDelegate
        }
    }
    
    private var habitControllerDelegate: HabitControllerDelegate?
    private var habits: [Habit]
    private var serialQueue: dispatch_queue_t = {
        return dispatch_queue_create("com.eastmanlabs.plist-queue", nil)
    }()
    
    var allHabits: [Habit] {
        get { return habits.map { $0 } }
    }

    // MARK: - Initialization
    
    override init() {
        habits = [Habit]()
        super.init()
        loadHabits { self.habits = $0 }
    }
    
    // MARK: Add / Remove
    
    func addHabit(habit: Habit) {
       habits.append(habit)
        
        let isFirst: Bool
        
        if habits.count == 1 {
           isFirst = true
        } else {
            isFirst = false
        }
        
        delegate?.habitController(self, didAddHabit: habit, isFirst: isFirst)
    }
    
    func removeHabitAtIndex(index: Int) {
        habits.removeAtIndex(index)
    }
    
    // MARK: - Saving / Loading
    
    private func habitPlistPath() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDirPath: AnyObject? = (paths.count > 0) ? paths.first! : nil
        var plistPath: String? = nil
        
        if let path = docDirPath as? NSString {
            plistPath = path.stringByAppendingPathComponent("habits.plist")
        }
        
        return plistPath
    }
    
    func saveHabits() {
        if let plistPath = self.habitPlistPath() {
            dispatch_async(serialQueue) {
                NSKeyedArchiver.archiveRootObject(habits as NSArray, toFile: plistPath)
            }
        }
    }
    
    private func loadHabits(completion: (habits: [Habit]) -> ()) {
        dispatch_async(serialQueue) {
                let loadedHabits = NSKeyedUnarchiver.unarchiveObjectWithFile(self.habitPlistPath()!) as? [Habit] ?? [Habit]()
            
            dispatch_async(dispatch_get_main_queue()) {
                completion(habits: loadedHabits)
                self.habitControllerDelegate?.habitController(self, didLoadHabits: loadedHabits)
            }
        }
    }
}

    // MARK: - Table View Data Source

extension HabitController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let habitCell = tableView.dequeueReusableCellWithIdentifier("HabitCellIdentifier") as! UITableViewCell
        habitCell.textLabel?.text = habits[indexPath.row].name
        
        return habitCell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let habit = habits.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            
            if habits.isEmpty {
                if let habitControllerDelegate = delegate as? HabitControllerDelegate {
                    habitControllerDelegate.habitController(self, didRemoveHabit: habit, wasLast: true)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}
