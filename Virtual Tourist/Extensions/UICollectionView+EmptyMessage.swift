//
//  UICollectionView+EmptyMessage.swift
//  Virtual Tourist
//
//  Created by António Bastião on 03.01.21.
//
// Credits to StackOverflow post :https://stackoverflow.com/a/45157417
//

import UIKit

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "San Francisco", size: 15)
        messageLabel.sizeToFit()

        backgroundView = messageLabel;
    }

    func restore() {
        backgroundView = nil
    }
}