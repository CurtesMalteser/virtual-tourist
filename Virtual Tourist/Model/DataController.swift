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
    
    lazy var viewContext: NSManagedObjectContext = persistentContainer.viewContext

    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores {storeDescription, error in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            
            completion?()
        
        }
    }
}
