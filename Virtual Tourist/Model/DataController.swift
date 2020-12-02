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

    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in

            guard error == nil else {
                fatalError("Unresolved error \(String(describing: error?.localizedDescription))")
            }

            completion?()

        }
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}