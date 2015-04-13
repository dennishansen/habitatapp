//
//  AddHabitViewController.swift
//  Habitat
//
//  Created by Brian Palma on 4/12/15.
//  Copyright (c) 2015 Eastman Labs, LLC. All rights reserved.
//

import UIKit

class AddHabitViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    
    var habit: Habit?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "DoneAddHabitIdentifier" {
                habit = Habit(dictionary: ["name": textField.text])
                textField.resignFirstResponder()
            }
        }
    }
}
