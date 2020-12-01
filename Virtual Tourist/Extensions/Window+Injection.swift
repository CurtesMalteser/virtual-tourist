//
// Created by António Bastião on 01.12.20.
//

import UIKit

extension UIWindow {

    func injectRootViewControllerAsMapVC() {
        let mapViewController = rootViewController as! MapViewController
        mapViewController.dataController = DataController(modelName: "VirtualTourist")
    }

/*    private func initApiKey() -> String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist")
                else {
            fatalError("Secrets.plist not found.")
        }

        let plist = NSDictionary(contentsOfFile: filePath)

        guard let key = plist?.object(forKey: "apiKey") as? String else {
            fatalError("'apiKey' not found on 'Secrets.plist' file.")
        }

        return key
    }*/
}
