//
//  FilterViewController.swift
//  Yelp
//
//  Created by hoaqt on 9/5/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate: class {
    func filtersViewController (filterViewController: FilterViewController, params: [String: AnyObject])
}

class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var switchStates = [Int: Bool] ()
    weak var delegate: FiltersViewControllerDelegate?
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        switchCell(sender.superview as! SwitchCell, value: sender.on)
    }
    
    func getSingleValue(filter: Filter) -> AnyObject?{
        for option in filter.options {
            if option.isEnabled {
                return option.value
            }
        }
        return nil
    }
    
    @IBAction func onSearchButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        var params = [String : AnyObject]()
        //deal
        params["deal"] = getSingleValue(Global.filters[0])
        //distance
        params["distance"] = getSingleValue(Global.filters[1])
        //sort
        params["sort"] = getSingleValue(Global.filters[2])
        //categories
        var selectedCategories = [String]()
        for option in Global.filters[3].options {
            if option.isEnabled {
                selectedCategories.append(option.value as! String)
            }
        }
        if selectedCategories.count>0 {
            params["categories"] = selectedCategories
        }
        delegate?.filtersViewController(self, params: params)
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let categories = Global.filters[3]
        categories.options.sort { (option1, option2) -> Bool in
            return option1.isEnabled == true
        }
        categories.isExpanded = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let filter = Global.filters[section]
        return filter.name
    }
    
    func switchCell(switchCell: SwitchCell, value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)
        let filter = Global.filters[indexPath!.section]
        filter.options[indexPath!.row].isEnabled = value
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let filter = Global.filters[indexPath.section] as Filter
        let option = filter.options[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
        switch filter.type{
        case .DropDown:
            if filter.isExpanded {
                if option.isEnabled {
                    cell.accessoryView = UIImageView(image: UIImage(named: "Check"))
                } else {
                    cell.accessoryView = UIImageView(image: UIImage(named: "Uncheck"))
                }
                cell.switchLabel.text = option.name
            } else {
                cell.accessoryView = UIImageView(image: UIImage(named: "Dropdown"))
                cell.switchLabel.text = filter.selectedOption.name
            }
        case .MultipleSwitches:
            if filter.isExpanded || indexPath.row < filter.numberOfVisibleRows {
                addSwitch(cell, option: option)
            }
            else {
                cell.switchLabel.text = "See All"
                cell.switchLabel.textAlignment = NSTextAlignment.Center
                cell.switchLabel.textColor = .darkGrayColor()
            }
        case .SingleSwitch:
            addSwitch(cell, option: option)
        default:
            break
        }
        
        
        cell.delegate = self
        return cell
    }
    
    func addSwitch(cell: SwitchCell, option: Option){
        let switchButton = UISwitch()
        cell.accessoryView = switchButton
        switchButton.on = option.isEnabled ?? false
        cell.switchLabel.text = option.name
        switchButton.addTarget(self, action: "switchValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        cell.switchLabel.textAlignment = NSTextAlignment.Left
        cell.switchLabel.textColor = .blackColor()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Global.filters.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filter = Global.filters[section] as Filter
        if !filter.isExpanded {
            switch filter.type {
            case .MultipleSwitches:
                return filter.numberOfVisibleRows! + 1
            case .DropDown:
                return 1
            case .SingleSwitch:
                return 1
            }
        }
        return filter.options.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let filter = Global.filters[indexPath.section] as Filter
        switch filter.type {
        case .DropDown:
            if filter.isExpanded {
                filter.resetToFalse()
                filter.options[indexPath.row].isEnabled = true
            }
            filter.isExpanded = !filter.isExpanded
            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
        case .MultipleSwitches:
            if indexPath.row == filter.numberOfVisibleRows && !filter.isExpanded {
                filter.isExpanded = true
                tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
            }
        default:
            break
        }
    }
}
