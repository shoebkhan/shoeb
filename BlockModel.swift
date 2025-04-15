//
//  File.swift
//  TuDime
//
//  Created by Shoeb on 07/10/21.
//  Copyright © 2021 ObjectSol. All rights reserved.
//

import Foundation

class BlockModel: NSObject, NSCoding {

    var ID: Int
    var name: String

    init(ID: Int, name: String) {
        self.ID = ID
        self.name = name
    }

    required init?(coder aDecoder: NSCoder) {
        self.ID = aDecoder.decodeInteger(forKey: "ID")
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(ID, forKey: "ID")
        aCoder.encode(name, forKey: "name")
    }
}

class MuteModel: NSObject, NSCoding {

    var ID: String
    var name: String

    init(ID: String, name: String) {
        self.ID = ID
        self.name = name
    }

    required init?(coder aDecoder: NSCoder) {
        self.ID = aDecoder.decodeObject(forKey: "ID") as? String ?? ""
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(ID, forKey: "ID")
        aCoder.encode(name, forKey: "name")
    }
}

class saveBackgroundModel: NSObject, NSCoding {

    var ID: String
    var data: Data

    init(ID: String, data: Data) {
        self.ID = ID
        self.data = data
    }

    required init?(coder aDecoder: NSCoder) {
        self.ID = aDecoder.decodeObject(forKey: "ID") as? String ?? ""
        self.data = aDecoder.decodeObject(forKey: "data") as? Data ?? Data()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(ID, forKey: "ID")
        aCoder.encode(data, forKey: "data")
    }
}

func saveBlockUser(id:Int,name:String) {
    var placesArray: [BlockModel] = loadUser()
    
    placesArray.append(BlockModel(ID: id, name: name))


    let placesData = NSKeyedArchiver.archivedData(withRootObject: placesArray)
    UserDefaults.standard.set(placesData, forKey: "blockUser")
}
func sameUser(userID : Int) -> Bool {
    guard let placesData = UserDefaults.standard.object(forKey: "blockUser") as? NSData else {
        print("'places' not found in UserDefaults")
        return false
    }

    guard let placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [BlockModel] else {
        print("Could not unarchive from placesData")
        return false
    }
    for value in 0 ..< placesArray.count {
        let place = placesArray[value]
            if userID == place.ID {
                return true
                break
            }
     
        }
     return false

}

func loadUser() -> [BlockModel] {
    guard let placesData = UserDefaults.standard.object(forKey: "blockUser") as? NSData else {
        print("'places' not found in UserDefaults")
        return []
    }

    guard let placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [BlockModel] else {
        print("Could not unarchive from placesData")
        return []
    }
     return placesArray

}
func deleteUser(model : BlockModel) -> [BlockModel] {
    guard let placesData = UserDefaults.standard.object(forKey: "blockUser") as? NSData else {
        print("'places' not found in UserDefaults")
        return []
    }

    guard var placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [BlockModel] else {
        print("Could not unarchive from placesData")
        return []
    }
    for value in 0 ..< placesArray.count {
        let place = placesArray[value]
            if model.ID == place.ID {
                placesArray.remove(at: value)
                break
            }
     
        }
    let placesDataValue = NSKeyedArchiver.archivedData(withRootObject: placesArray)
    UserDefaults.standard.set(placesDataValue, forKey: "blockUser")
    
     return placesArray

}




func unMuteUser(model : MuteModel) {
    guard let placesData = UserDefaults.standard.object(forKey: "muteUser") as? NSData else {
        print("'places' not found in UserDefaults")
        return
    }

    guard var placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [MuteModel] else {
        print("Could not unarchive from placesData")
        return
    }
    for value in 0 ..< placesArray.count {
        let place = placesArray[value]
        if model.ID == place.ID {
            placesArray.remove(at: value)
            break
        }

    }
    let placesDataValue = NSKeyedArchiver.archivedData(withRootObject: placesArray)
    UserDefaults.standard.set(placesDataValue, forKey: "muteUser")

}

func saveBackgroundImage(id:String,data:Data) {
    var placesArray: [saveBackgroundModel] = loadbackgroundImage()

    placesArray.append(saveBackgroundModel(ID: id, data: data))


    let placesData = NSKeyedArchiver.archivedData(withRootObject: placesArray)
    UserDefaults.standard.set(placesData, forKey: "backgroundImage")
}

func saveMuteUser(id:String,name:String) {
    var placesArray: [MuteModel] = loadMuteUser()

    placesArray.append(MuteModel(ID: id, name: name))


    let placesData = NSKeyedArchiver.archivedData(withRootObject: placesArray)
    UserDefaults.standard.set(placesData, forKey: "muteUser")
}
func sameMuteUser(userID : String) -> Bool {
    guard let placesData = UserDefaults.standard.object(forKey: "muteUser") as? NSData else {
        print("'places' not found in UserDefaults")
        return false
    }

    guard let placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [MuteModel] else {
        print("Could not unarchive from placesData")
        return false
    }
    for value in 0 ..< placesArray.count {
        let place = placesArray[value]
        if userID == place.ID {
            return true
            break
        }

    }
    return false

}

func loadMuteUser() -> [MuteModel] {
    guard let placesData = UserDefaults.standard.object(forKey: "muteUser") as? NSData else {
        print("'places' not found in UserDefaults")
        return []
    }

    guard let placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [MuteModel] else {
        print("Could not unarchive from placesData")
        return []
    }
    return placesArray

}

func loadbackgroundImage() -> [saveBackgroundModel] {
    guard let placesData = UserDefaults.standard.object(forKey: "backgroundImage") as? NSData else {
        print("'places' not found in UserDefaults")
        return []
    }

    guard let placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [saveBackgroundModel] else {
        print("Could not unarchive from placesData")
        return []
    }
    return placesArray

}

func sameBackgroundImageUser(userID : String) -> UIImage? {
    guard let placesData = UserDefaults.standard.object(forKey: "backgroundImage") as? NSData else {
        print("'places' not found in UserDefaults")
        return nil
    }

    guard let placesArray = NSKeyedUnarchiver.unarchiveObject(with: placesData as Data) as? [saveBackgroundModel] else {
        print("Could not unarchive from placesData")
        return nil
    }
    for value in 0 ..< placesArray.count {
        let place = placesArray[value]
        if userID == place.ID {
            return UIImage(data: place.data)
            break
        }

    }
    return nil

}
