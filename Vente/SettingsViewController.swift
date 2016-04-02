//
//  SettingsViewController.swift
//  Vente
//
//  Created by Nicholas Miller on 3/29/16.
//  Copyright © 2016 nickbryanmiller. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var fooddrinkSwitch: UISwitch!
    @IBOutlet weak var entertainmentSwitch: UISwitch!
    @IBOutlet weak var sportsSwitch: UISwitch!
    @IBOutlet weak var chillSwitch: UISwitch!
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var academicSwitch: UISwitch!
    @IBOutlet weak var nightlifeSwitch: UISwitch!
    @IBOutlet weak var adventureSwitch: UISwitch!
    @IBOutlet weak var distanceSlider: UISlider!
    
    @IBOutlet weak var allLabel: UILabel!
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var fromExplore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSwitches()
        
        if (fromExplore) {
            distanceSlider.hidden = false
            allLabel.hidden = false
            oneLabel.hidden = false
            distanceLabel.hidden = false

        }
        else {
            distanceSlider.hidden = true
            allLabel.hidden = true
            oneLabel.hidden = true
            distanceLabel.hidden = true
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        setUserDefaults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSwitches() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        distanceSlider.value = defaults.floatForKey("distanceSlider")
        
        if (defaults.integerForKey("fooddrinkSwitch") == 1) {
            fooddrinkSwitch.on = true
        }
        if (defaults.integerForKey("entertainmentSwitch") == 1) {
            entertainmentSwitch.on = true
        }
        if (defaults.integerForKey("sportsSwitch") == 1) {
            sportsSwitch.on = true
        }
        if (defaults.integerForKey("chillSwitch") == 1) {
            chillSwitch.on = true
        }
        if (defaults.integerForKey("academicSwitch") == 1) {
            academicSwitch.on = true
        }
        if (defaults.integerForKey("musicSwitch") == 1) {
            musicSwitch.on = true
        }
        if (defaults.integerForKey("nightlifeSwitch") == 1) {
            nightlifeSwitch.on = true
        }
        if (defaults.integerForKey("adventureSwitch") == 1) {
            adventureSwitch.on = true
        }
    }
    
    @IBAction func clearTagsTouched(sender: AnyObject) {
        fooddrinkSwitch.on = false
        entertainmentSwitch.on = false
        sportsSwitch.on = false
        chillSwitch.on = false
        academicSwitch.on = false
        musicSwitch.on = false
        nightlifeSwitch.on = false
        adventureSwitch.on = false
        distanceSlider.value = 10
        
        setUserDefaults()
    }
    
    func setUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setFloat(distanceSlider.value, forKey: "distanceSlider")
        
        if (fooddrinkSwitch.on) {
            defaults.setInteger(1, forKey: "fooddrinkSwitch")
        }
        else if (!fooddrinkSwitch.on) {
            defaults.setInteger(0, forKey: "fooddrinkSwitch")
        }
        
        if (entertainmentSwitch.on) {
            defaults.setInteger(1, forKey: "entertainmentSwitch")
        }
        else if (!entertainmentSwitch.on) {
            defaults.setInteger(0, forKey: "entertainmentSwitch")
        }

        if (sportsSwitch.on) {
            defaults.setInteger(1, forKey: "sportsSwitch")
        }
        else if (!sportsSwitch.on) {
            defaults.setInteger(0, forKey: "sportsSwitch")
        }
        
        if (chillSwitch.on) {
            defaults.setInteger(1, forKey: "chillSwitch")
        }
        else if (!chillSwitch.on) {
            defaults.setInteger(0, forKey: "chillSwitch")
        }
        
        if (academicSwitch.on) {
            defaults.setInteger(1, forKey: "academicSwitch")
        }
        else if (!academicSwitch.on) {
            defaults.setInteger(0, forKey: "academicSwitch")
        }
        
        if (musicSwitch.on) {
            defaults.setInteger(1, forKey: "musicSwitch")
        }
        else if (!musicSwitch.on) {
            defaults.setInteger(0, forKey: "musicSwitch")
        }
        
        if (nightlifeSwitch.on) {
            defaults.setInteger(1, forKey: "nightlifeSwitch")
        }
        else if (!nightlifeSwitch.on) {
            defaults.setInteger(0, forKey: "nightlifeSwitch")
        }
        
        if (adventureSwitch.on) {
            defaults.setInteger(1, forKey: "adventureSwitch")
        }
        else if (!adventureSwitch.on) {
            defaults.setInteger(0, forKey: "adventureSwitch")
        }
        
        defaults.synchronize()
    }
}
