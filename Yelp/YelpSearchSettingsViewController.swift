//
//  YelpSearchSettingsViewController.swift
//  Yelp
//
//  Created by Phan, Ngan on 9/22/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

protocol YelpSearchSettingsViewControllerDelegate: class {
    func yelpSearchSettingsView(yelpSearchSettingsView: YelpSearchSettingsViewController, yelpSearchSettings: YelpSearchSettings)
}

enum SearchCategory: String {
    case Deal = ""
    case Distance = "Distance"
    case Sort = "Sort By"
    case Category = "Category"
}

struct YelpSearchSetting {
    var searchCategory: SearchCategory
    var selected: Set<String>
    var min: Int
    var expand: Bool
}

class YelpSearchSettingsViewController: UIViewController {

    @IBOutlet weak var searchSettingsTableView: UITableView!
    
    var searchCategories: [YelpSearchSetting]!
    weak var delegate: YelpSearchSettingsViewControllerDelegate?
    
    var currentSearchSettings: YelpSearchSettings! {
        didSet {
            let sort = currentSearchSettings.sort ?? YelpSortMode.auto  
            
            var deal = Set<String>()
            if currentSearchSettings.deals != nil && currentSearchSettings.deals! {
                deal.insert(YelpSearchOptions.offeringDealOption[0])
            }
            
            let distance = (currentSearchSettings.distance != nil) ? valueFrom(distance: currentSearchSettings.distance!) : "Auto"
            let category = (currentSearchSettings.categories != nil) ? valueFrom(categories: currentSearchSettings.categories!) : Set<String>()
            
            searchCategories = [YelpSearchSetting(searchCategory: .Deal,
                                                  selected: deal,
                                                  min: 1,
                                                  expand: false),
                                YelpSearchSetting(searchCategory: .Sort,
                                                  selected: [sort.description],
                                                  min: 1,
                                                  expand: false),
                                YelpSearchSetting(searchCategory: .Distance,
                                                  selected: [distance],
                                                  min: 1,
                                                  expand: false),
                                YelpSearchSetting(searchCategory: .Category,
                                                  selected: category,
                                                  min: 4,
                                                  expand: false)]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelSettings(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveSearchSettings(_ sender: Any) {
        let preferredSearchSettings = YelpSearchSettings()
        preferredSearchSettings.term = currentSearchSettings.term
        
        for searchCategory in searchCategories {
            switch searchCategory.searchCategory {
            case .Deal:
                preferredSearchSettings.deals = !searchCategory.selected.isEmpty
            case .Sort:
                if searchCategory.selected.count == 1 {
                    for option in YelpSearchOptions.sortBy {
                        if searchCategory.selected.contains(option["name"] as! String) {
                            preferredSearchSettings.sort = option["code"] as? YelpSortMode
                            break
                        }
                    }
                }
            case .Distance:
                if searchCategory.selected.count == 1 {
                    for option in YelpSearchOptions.distances {
                        if searchCategory.selected.contains(option["name"] as! String) {
                            preferredSearchSettings.distance = option["code"] as? Double
                            break
                        }
                    }
                }
            case .Category:
                if preferredSearchSettings.categories == nil {
                    preferredSearchSettings.categories = [String]()
                }
                
                preferredSearchSettings.categories?.removeAll()
                for option in YelpSearchOptions.categories {
                    if searchCategory.selected.contains(option["name"]!) {
                        preferredSearchSettings.categories?.append(option["code"]!)
                    }
                }
            }
        }
        delegate?.yelpSearchSettingsView(yelpSearchSettingsView: self, yelpSearchSettings: preferredSearchSettings)
        dismiss(animated: true, completion: nil)
    }
    
    func valueFrom(distance: Double) -> String {
        for option in YelpSearchOptions.distances {
            let code = option["code"] as! Double
            if code == distance {
                return option["name"] as! String
            }
        }
        return ""
    }
    
    func valueFrom(categories: [String]) -> Set<String> {
        var categoriesSet = Set<String>()
        
        for category in categories {
            for option in YelpSearchOptions.categories {
                if option["code"] == category {
                    categoriesSet.insert(option["name"]!)
                }
            }
        }
        return categoriesSet
    }
}

// MARK: Tableview methods
extension YelpSearchSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchCategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchCategories[section].searchCategory.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchCategories[section].expand {
            switch searchCategories[section].searchCategory {
            case .Deal:
                return YelpSearchOptions.offeringDealOption.count
            case .Sort:
                return YelpSearchOptions.sortBy.count
            case .Distance:
                return YelpSearchOptions.distances.count
            case .Category:
                return YelpSearchOptions.categories.count
            }
        }
        return searchCategories[section].min
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchCategories[indexPath.section].searchCategory {
        case .Deal:
            let option = YelpSearchOptions.offeringDealOption[indexPath.row]
            return getSwitchCell(tableView: tableView, indexPath: indexPath, option: option)
        case .Sort:
            return getSingleOptionCell(tableView: tableView, indexPath: indexPath, options: YelpSearchOptions.sortBy)
        case .Distance:
            return getSingleOptionCell(tableView: tableView, indexPath: indexPath, options: YelpSearchOptions.distances)
        case .Category:
            if !searchCategories[indexPath.section].expand && indexPath.row == searchCategories[indexPath.section].min - 1 {
                return getMinimumOptionCell(tableView: tableView, indexPath: indexPath, option: "See All")
            } else {
                let option = YelpSearchOptions.categories[indexPath.row]["name"] ?? ""
                return getSwitchCell(tableView: tableView, indexPath: indexPath, option: option)
            }
        }
    }
    
    func getSwitchCell(tableView: UITableView, indexPath: IndexPath, option: String) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as? SwitchCell else {
            return UITableViewCell()
        }
        cell.optionLabel.text = option
        cell.optionSwitch.isOn = searchCategories[indexPath.section].selected.contains(option)
        cell.handleOption = {(optionSwitch: UISwitch) -> Void in
            if optionSwitch.isOn {
                self.searchCategories[indexPath.section].selected.insert(option)
            } else {
                self.searchCategories[indexPath.section].selected.remove(option)
            }
        }
        return cell
    }
    
    func getSingleOptionCell(tableView: UITableView, indexPath: IndexPath, options: [Dictionary<String, Any>]) -> UITableViewCell {
        
        if !searchCategories[indexPath.section].expand && indexPath.row == searchCategories[indexPath.section].min - 1 {
            return getMinimumOptionCell(tableView: tableView, indexPath: indexPath, option: searchCategories[indexPath.section].selected.first!)
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") as? OptionCell else {
                return UITableViewCell()
            }
            
            let option = options[indexPath.row]["name"] as? String ?? ""
            cell.optionLabel.text = option
            cell.accessoryView = nil
            if searchCategories[indexPath.section].selected.contains(option) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    func getMinimumOptionCell(tableView: UITableView, indexPath: IndexPath, option: String) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") as? OptionCell else {
            return UITableViewCell()
        }
        
        cell.optionLabel.text = option
        let accessoryImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        accessoryImageView.image = UIImage(named:"downArrow.png")
        cell.accessoryView = accessoryImageView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchCategories[indexPath.section].searchCategory {
        case .Sort:
            selectSingleOptionCell(indexPath: indexPath, options: YelpSearchOptions.sortBy)
        case .Distance:
            selectSingleOptionCell(indexPath: indexPath, options: YelpSearchOptions.distances)
        case .Category:
            if !selectMinimumOptionCell(indexPath: indexPath) {
                break
            }
        default:
            break
        }
    }
    
    func selectSingleOptionCell(indexPath: IndexPath, options: [Dictionary<String, Any>]) {
        if !selectMinimumOptionCell(indexPath: indexPath) {
            if let option = options[indexPath.row]["name"] as? String {
                searchCategories[indexPath.section].selected.removeAll()
                searchCategories[indexPath.section].selected.insert(option)
                searchCategories[indexPath.section].expand = false
                searchSettingsTableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .fade)
            }
        }
    }
    
    func selectMinimumOptionCell(indexPath: IndexPath) -> Bool {
        let expand = searchCategories[indexPath.section].min - 1
        switch indexPath.row {
        case expand:
            if !searchCategories[indexPath.section].expand {
                searchCategories[indexPath.section].expand = true
                searchSettingsTableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .fade)
                return true
            }
        default:
            break
        }
        
        return false
    }
}
