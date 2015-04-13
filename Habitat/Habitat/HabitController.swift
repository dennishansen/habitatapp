//
//  HabitController.swift
//  Habitat
//
//  Created by Brian Palma on 4/12/15.
//  Copyright (c) 2015 Eastman Labs, LLC. All rights reserved.
//

import UIKit

@objc protocol HabitControllerDelegate {
    func habitController(habitController: HabitController, didRemoveFinalHabit habit: Habit)
    func habitController(habitController: HabitController, didLoadHabits: [Habit])
}

class HabitController: NSObject, NSCoding {
    
    @IBOutlet weak var delegate: UIViewController? {
        didSet {
            habitControllerDelegate = delegate as?HabitControllerDelegate
        }
    }
    
    private var habitControllerDelegate: HabitControllerDelegate?
    private var habits: [Habit]
    
    var allHabits: [Habit] {
        get { return habits.map { $0 } }
    }
    
    override init() {
        habits = [Habit]()
        super.init()
        loadHabits { self.habits = $0 }
    }
    
    // MARK: - NSCoding
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        loadHabits { self.habits = $0 }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    }

    // MARK: Add / Remove
    
    func addHabit(habit: Habit) {
       habits.append(habit)
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
            NSKeyedArchiver.archiveRootObject(habits as NSArray, toFile: plistPath)
        }
    }
    
    private func loadHabits(completion: (habits: [Habit]) -> ()) {
        dispatch_async(dispatch_queue_create("com.eastmanlabs.loading-plist", nil)) {
            dispatch_async(dispatch_get_main_queue()) {
                let loadedHabits = NSKeyedUnarchiver.unarchiveObjectWithFile(self.habitPlistPath()!) as? [Habit] ?? [Habit]()
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
                    habitControllerDelegate.habitController(self, didRemoveFinalHabit: habit)
                }
            }
        }
    }
}
