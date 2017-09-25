//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController {
    
    @IBOutlet weak var businessTableView: UITableView!
    
    var businesses: [Business] = []
    var searchBar: UISearchBar!
    var searchSettings = YelpSearchSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // autoresize table cell height
        businessTableView.estimatedRowHeight = 120
        businessTableView.rowHeight = UITableViewAutomaticDimension
        
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        // Perform the first search when the view controller first loads
        searchSettings.sort = YelpSortMode.auto
        doSearch()
    }
    
    // Perform the search.
    fileprivate func doSearch() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Business.searchWithSettings(searchSettings: searchSettings, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            guard let businesses = businesses else {
                return
            }
            self.businesses = businesses
            self.businessTableView.reloadData()
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueNC = segue.destination as? UINavigationController else {
            return
        }
        
        guard let yelpSearchSettingsViewController = segueNC.topViewController as? YelpSearchSettingsViewController else {
            return
        }
        
        yelpSearchSettingsViewController.currentSearchSettings = searchSettings
        yelpSearchSettingsViewController.delegate = self
    }
}

// MARK: - SearchBar methods
extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchSettings.term = searchBar.text
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchSettings.term = searchBar.text
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("call search")
        doSearch()
    }
}

// MARK: TableView methods
extension BusinessesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell") as? BusinessCell else {
            return UITableViewCell()
        }
        cell.nameLabel.text = businesses[indexPath.row].name
        cell.addressLabel.text = businesses[indexPath.row].address
        cell.categoriesLabel.text = businesses[indexPath.row].categories
        cell.distanceLabel.text = businesses[indexPath.row].distance
        
        if let reviewCount = businesses[indexPath.row].reviewCount {
            cell.reviewCountLabel.text = String(describing: reviewCount)
        }
        
        if let imageURL = businesses[indexPath.row].imageURL {
            loadImage(imageUrl: imageURL, loadImageView: cell.businessImageView)
            cell.businessImageView.contentMode = .scaleAspectFill
        }
        
        if let ratingImageURL = businesses[indexPath.row].ratingImageURL {
            loadImage(imageUrl: ratingImageURL, loadImageView: cell.ratingImageView)
            cell.ratingImageView.contentMode = .scaleAspectFill
        }
        
        return cell
    }

    func loadImage(imageUrl: URL, loadImageView: UIImageView) {
        let imageRequest = URLRequest(url: imageUrl)
        
        loadImageView.setImageWith(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    loadImageView.alpha = 0.0
                    loadImageView.image = image
                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                        loadImageView.alpha = 1.0
                    })
                } else {
                    loadImageView.image = image
                }
        },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
    }
}

// MARK: - YelpSearchSettings methods
extension BusinessesViewController: YelpSearchSettingsViewControllerDelegate {
    func yelpSearchSettingsView(yelpSearchSettingsView: YelpSearchSettingsViewController, yelpSearchSettings: YelpSearchSettings) {
        searchSettings = yelpSearchSettings
        doSearch()
    }
}
