//
//  Global.swift
//
//  Created by Nam Truong on 7/20/16.
//  Copyright © 2016 MHT. All rights reserved.
//

import UIKit
import CoreLocation

class Global: NSObject {
    static var qrCode :UIImage?
    static var account :String = ""
    static var accountActive :Bool = true
//    static var ApplicationID :UInt = 2
//    static var AuthorizationKey :String = "mn3eRRYzT-tfUZ-"
//    static var AuthorizationSecret :String = "kvvyPjMUTt5HdPR"
//    static var accountKey :String = "3WWWzquyso67WCFtmehc"
    static var ApplicationID :UInt = 69917
    static var AuthorizationKey :String = "6KNKWeLCTJGEprK"
    static var AuthorizationSecret :String = "ZBCTNWbLehYWXkO"
    static var accountKey :String = "3WWWzquyso67WCFtmehc"
    static var apiEndpoint :String = "https://apitudime.quickblox.com"
    static var chatEndpoint :String = "chattudime.quickblox.com"
    static var currencySymbol :String = "$"
    static var currencyCode :String = "USD"
    static var currencyKey :String = "eae7eba472db4eebb5f6b9ea73c644cb"
    static var currencyConvert :Double = 1.0
}

