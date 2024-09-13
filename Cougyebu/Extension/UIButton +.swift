//
//  UIButton +.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit
import RxSwift
import RxCocoa

extension UIButton {
    
    func showPasswordButtonToggle(textField: UITextField?, disposeBag: DisposeBag) {
        self.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                isSelected.toggle()
                let imageName = self.isSelected ? "eye.fill" : "eye.slash"
                setImage(UIImage(systemName: imageName), for: .normal)
                textField?.isSecureTextEntry = !self.isSelected
            }).disposed(by: disposeBag)
    }
    
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
