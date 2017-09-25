//
//  YelpSearchSettings.swift
//  Yelp
//
//  Created by Phan, Ngan on 9/22/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class YelpSearchSettings: NSObject {
    var term: String?
    var sort: YelpSortMode?
    var categories: [String]?
    var deals: Bool?
    var distance: Double?
}
