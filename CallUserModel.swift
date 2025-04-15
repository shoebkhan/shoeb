//
//  File.swift
//  TuDime
//
//  Created by Shoeb on 07/10/21.
//  Copyright © 2021 ObjectSol. All rights reserved.
//

import Foundation

class CallUserModel: NSObject, NSCoding {

    var ID: Int
    var name: String
    var date: String
    var duration: String
    var type: String
    var direction: String
    init(ID: Int, name: String,date:String, duration:String, type:String, direction:String) {
        self.ID = ID
        self.name = name
        self.date = date
        self.duration = duration
        self.type = type
    self.direction = direction
    }

    required init?(coder aDecoder: NSCoder) {
        self.ID = aDecoder.decodeInteger(forKey: "ID")
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.date = aDecoder.decodeObject(forKey: "date") as? String ?? ""
        self.duration = aDecoder.decodeObject(forKey: "duration") as? String ?? ""
        self.type = aDecoder.decodeObject(forKey: "type") as? String ?? ""
        self.direction = aDecoder.decodeObject(forKey: "direction") as? String ?? ""
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(ID, forKey: "ID")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(direction, forKey: "direction")
    }

}
func saveCall(model : CallUserModel) {
    var placesArray: [CallUserModel] = loadCallUser()
    
    placesArray.append(model)


    let placesData = NSKeyedArchiver.archivedData(withRootObject: placesArray)
    UserDefaults.standard.set(placesData, forKey: "callUserList")
}
func saveCallUser(ID: Int, name: String,date:String, duration:String, type:String, direction:String) {
    var placesArray: [CallUserModel] = loadCallUser()
    
    placesArray.append(CallUserModel(ID: ID, name: name, date: date, duration: duration, type: type,direction: direction))


    let placesData = NSKeyedArchiver.archivedData(withRootObject: placesArray)
    UserDefaults.standard.set(placesData, forKey: "callUserList")
}

func loadCallUser() -> [CallUserModel] {
    guard let placesData = UserDefaults.standard.object(forKey: "callUserList") as? NSData else {
        print("'places' not found in UserDefaults")
        return []
    }

    guard let placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [CallUserModel] else {
        print("Could not unarchive from placesData")
        return []
    }
     return placesArray

}


