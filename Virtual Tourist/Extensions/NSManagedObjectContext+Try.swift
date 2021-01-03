//
//  NSManagedObjectContext+Try.swift
//  Virtual Tourist
//
//  Created by António Bastião on 02.01.21.
//

import Foundation
import CoreData

extension NSManagedObjectContext {

    func doTry(onSuccess: (_ context: NSManagedObjectContext) throws ->  Void,
                 onError: (_ error: Error) -> Void = { error in
                     fatalError("\(error.localizedDescription)")
                 }
    ) {
        do {
            try onSuccess(self)
        } catch {
            onError(error)
        }
    }

}
