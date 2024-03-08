//
//  UIButton +.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit

extension UIButton {

    func resizeImageButton(image: UIImage?, width: Int, height: Int, color: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        let newSize = CGSize(width: width, height: height)
        let coloredImage = image.withTintColor(color)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        coloredImage.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
}
