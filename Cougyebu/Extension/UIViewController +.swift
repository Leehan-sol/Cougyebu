//
//  UIViewController +.swift
//  Cougyebu
//
//  Created by hansol on 2024/08/17.
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    
    func bindTextFieldsToMoveNext(fields: [UITextField], disposeBag: DisposeBag) {
        for (index, textField) in fields.enumerated() {
            let nextField = index < fields.count - 1 ? fields[index + 1] : nil
            textField.rx.controlEvent(.editingDidEndOnExit)
                .subscribe(onNext: { [weak nextField] in
                    nextField?.becomeFirstResponder()
                }).disposed(by: disposeBag)
        }
    }
    
}
