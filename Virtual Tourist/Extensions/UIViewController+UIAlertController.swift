//
//  UIViewController+UIAlertController.swift
//  On-The-Map
//
//  Created by António Bastião on 01.11.20.
//  Copyright © 2020 António Bastião. All rights reserved.
//

import UIKit

extension UIViewController {

    /**
     Convenience function to show UIAlertController in case of errors from API calls or geolocation.
     */
    func showErrorAlert(message: String, callback: @escaping () -> Void = {
    }) {
        DispatchQueue.main.async {
            callback()
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showNetworkActivityAlert(_ completionHandler: @escaping (_ alertController: UIAlertController) -> Void) {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        alert.view.tintColor = UIColor.black

        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.color = UIColor.systemBlue
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)

        present(alert, animated: true) {
            completionHandler(alert)
        }

    }
}
