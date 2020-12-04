//
// Created by António Bastião on 03.12.20.
//

import UIKit

extension UIViewController {

    // Push view controller
    func pushViewControllerWithInject<T: UIViewController>(storyboard: UIStoryboard?,
                                                           identifier: String,
                                                           navigationController: UINavigationController?,
                                                           injectArgs: (_ targetVC: T) -> Void) {

        let viewController = storyboard?.instantiateViewController(withIdentifier: identifier) as! T

        injectArgs(viewController)

        navigationController?.pushViewController(viewController, animated: true)
    }

}
