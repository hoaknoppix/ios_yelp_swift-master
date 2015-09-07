//
//  Option.swift
//  Yelp
//
//  Created by hoaqt on 9/6/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Option{
    var name: String
    var apiName: String?
    var value: AnyObject
    var isEnabled: Bool
    init(name: String, apiName:String?=nil, value: AnyObject, isEnabled:Bool?=false){
        self.name = name
        self.apiName = apiName
        self.value = value
        self.isEnabled = isEnabled!
    }
}
