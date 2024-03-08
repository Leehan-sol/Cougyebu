//
//  MyPageViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import FirebaseAuth
import MessageUI

class MyPageViewController: UIViewController {
    private let myPageView = MyPageView()
    // ✨ 프로토콜 타입으로 변경
    private let viewModel: MyPageViewModel
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = myPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setViewModelUser()
        setBinding()
    }
    
    func setTableView() {
        myPageView.tableView.delegate = self
        myPageView.tableView.dataSource = self
        myPageView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func setViewModelUser() {
        viewModel.setUser()
    }
    
    func setBinding() {
        viewModel.observableUser?.bind { [weak self] user in
            self?.myPageView.nicknameLabel.text = user.nickname
            if user.isConnect {
                self?.myPageView.coupleNicknameLabel.text = user.coupleNickname
            }
        }
    }

    
}


// MARK: - UITableViewDelegate
extension MyPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        headerView.textLabel?.text = viewModel.headerData[section]
        headerView.textLabel?.textColor = .systemGray2
        headerView.textLabel?.textAlignment = .left
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellText = viewModel.cellData[indexPath.section][indexPath.row]
        
        switch cellText {
        case "공지사항":
            let appNoticeVC = AppNoticeViewController()
            self.navigationController?.pushViewController(appNoticeVC, animated: true)
        case "개인정보처리방침":
            let privacyPolicyVC = PrivacyPolicyViewController()
            self.navigationController?.pushViewController(privacyPolicyVC, animated: true)
        case "서비스이용약관":
            let termsVC = TermsViewController()
            self.navigationController?.pushViewController(termsVC, animated: true)
        case "문의하기":
            setMail()
        case "커플 연결":
            let connectVM = ConnectViewModel(observableUser: viewModel.observableUser!)
            let connectVC = ConnectViewController(viewModel: connectVM)
            self.navigationController?.pushViewController(connectVC, animated: true)
        case "닉네임 변경":
            let nicknameEditVC = NicknameEditViewController(user: viewModel.observableUser!)
            self.navigationController?.pushViewController(nicknameEditVC, animated: true)
        case "카테고리 설정":
            let categoryVC = CategoryViewController(user: viewModel.observableUser!)
            self.navigationController?.pushViewController(categoryVC, animated: true)
        case "로그아웃":
            AlertManager.showAlertTwoButton(from: self, title: "로그아웃", message: "정말 로그아웃하시겠습니까?", button1Title: "확인", button2Title: "취소") {
                do {
                    // ✨ 화면이동 로직 구현 
                    try Auth.auth().signOut()
                    let loginVC = LoginViewController()
                    self.navigationController?.pushViewController(loginVC, animated: true)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        case "비밀번호 변경":
            let passwordEditVC = PasswordEditViewController()
            self.navigationController?.pushViewController(passwordEditVC, animated: true)
        case "회원탈퇴":
            let withdrawalVC = WithdrawalViewController(user: viewModel.observableUser)
            self.navigationController?.pushViewController(withdrawalVC, animated: true)
        default:
            break
        }
    }
    
    
}


// MARK: - UITableViewDataSource
extension MyPageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.headerData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.headerData[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = viewModel.cellData[indexPath.section][indexPath.row]
        
        let chevronImageView = UIImageView()
        chevronImageView.image = UIImage(systemName: "chevron.forward")
        chevronImageView.tintColor = .gray
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(chevronImageView)
        
        chevronImageView.snp.makeConstraints { make in
            make.width.equalTo(14)
            make.height.equalTo(22)
            make.centerY.equalTo(cell.contentView)
            make.trailing.equalTo(cell.contentView).offset(-24)
        }
        
        return cell
    }
    
    
}


// MARK: - MFMailComposeViewControllerDelegate
extension MyPageViewController: MFMailComposeViewControllerDelegate {
    func setMail() {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return }
        
        if MFMailComposeViewController.canSendMail() {
            
            let compseVC = MFMailComposeViewController()
            compseVC.mailComposeDelegate = self
            
            compseVC.setToRecipients(["ho20128@naver.com"])
            compseVC.setSubject("커계부 오류 및 문의사항")
            compseVC.setMessageBody("""
                                       앱을 사용하면서 발생한 오류 및 문의사항을 입력해주세요.
                                       
                                       App Version: \(appVersion)
                                       Device: \(UIDevice.iPhoneModel)
                                       OS: \(UIDevice.iOSVersion)
                                       
                                       사용자 아이디: "사용중이신 아이디를 입력해주세요."
                                       
                                       오류 및 문의사항: "오류 및 문의사항을 입력해주세요."
                                       
                                       """, isHTML: false)
            
            self.present(compseVC, animated: true, completion: nil)
            
        }
        else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let message = """
        이메일 설정을 확인하고 다시 시도해주세요.
        아이폰 설정 > Mail > 계정 > 계정추가
        """
        
        let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { (action) in
        }
        
        sendMailErrorAlert.addAction(confirmAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    
    @objc func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        navigationController?.popViewController(animated: false)
    }
    
    
}
