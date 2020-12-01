//
//  DataController.swift
//  Virtual Tourist
//
//  Created by António Bastião on 01.12.20.
//

import Foundation
import CoreData

class DataController {

    let persistentContainer: NSPersistentContainer

    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
}
