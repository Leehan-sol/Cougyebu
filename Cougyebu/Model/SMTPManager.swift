//
//  SMTPManager.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation
import SwiftSMTP
import RxSwift

struct SMTPManager {
    static private let hostSMTP = SMTP(hostname: "smtp.naver.com", email: Secret.email, password: Secret.password)
    
    static func sendAuth(userEmail: String) -> Observable<Int> {
          return Observable.create { observer in
              let code = Int.random(in: 10000...99999)
              let fromUser = Mail.User(email: Secret.email)
              let toUser = Mail.User(email: userEmail)
              let verificationCode = String(code)
              let emailContent = """
              [커계부]

              커계부 인증 메일

              인증번호 : [\(verificationCode)]

              APP에서 인증번호를 입력해주세요.
              """
              let mail = Mail(from: fromUser, to: [toUser], subject: "커계부 인증 안내", text: emailContent)
              
              hostSMTP.send([mail], completion:  { _, fail in
                  if let error = (fail.first?.1 as? NSError) {
                      observer.onError(error)
                  } else {
                      observer.onNext(code)
                      observer.onCompleted()
                  }
              })
              return Disposables.create()
          }
      }

}

