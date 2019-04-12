// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UIView {

    enum SeparatorType {
        case top
        case bottom
    }

    struct SeparatorInsets {
        let left: CGFloat
        let right: CGFloat

        public static let zero = SeparatorInsets(left: 0, right: 0)

        public init(left: CGFloat, right: CGFloat) {
            self.left = left
            self.right = right
        }
    }

    func addSeparator(type: SeparatorType, color: UIColor, insets: SeparatorInsets = .zero, height: CGFloat = 1) {
        let separatorView = UIImageView()
        addSubview(separatorView)
        with(separatorView) {
            $0.image = UIImage.pixelImage(withColor: color)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: height),
                $0.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
                $0.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)
            ])
        }
        switch type {
        case .top:
            separatorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        default:
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }

}
