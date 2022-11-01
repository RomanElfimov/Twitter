//
//  LoginController.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 13.10.2021.
//

import UIKit

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    // Twitter Logo Image
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "TwitterLogo")
        return iv
    }()
    
    // email
    private lazy var emailContainerView: UIView = {
        let image = UIImage(named: "ic_mail_outline_white_2x-1")!
        let view = Utilites().inputContainerView(withImage: image, textField: emailTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilites().textField(withPlaceholder: "Email")
        return tf
    }()
    
    // password
    private lazy var passwordContainerView: UIView = {
        let image = UIImage(named: "ic_lock_outline_white_2x")!
        let view = Utilites().inputContainerView(withImage: image, textField: passwordTextField)
        return view
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilites().textField(withPlaceholder: "Пароль")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    // login button
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system) 
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    // dontHaveAccountButton at the bottom of screen
    private lazy var dontHaveAccountButton: UIButton = {
        let button = Utilites().attributedButton("Нет аккаунта?", " Зарегистрироваться")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { fatalError() }
        guard let password = passwordTextField.text else { fatalError() }
        AuthService.shared.logUserIn(withEmail: email, password: password) { [weak self] _, error in
            if let error = error {
                if error.localizedDescription == "The password is invalid or the user does not have a password." {
                    self?.presentAlertController(withTitle: "Ошибка", withMessage: "Неверный пароль")
                } else if error.localizedDescription == "The email address is badly formatted." {
                    self?.presentAlertController(withTitle: "Ошибка", withMessage: "Неверный email")
                } else if error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                    self?.presentAlertController(withTitle: "Такого пользователя не существует", withMessage: "Проверьте правильность заполнения email и пароля")
                }
                return
            }
            
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
            guard let container = keyWindow?.rootViewController as? ContainerViewController else { fatalError() }
            
            guard let tab = container.controller as? MainTabController else { return }
            tab.authenticateUserAndConfigureUI()

            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Heplers
    
    func configureUI() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        // twitter logo
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        logoImageView.setDimensions(width: 150, height: 150)
        
        // email & password
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   loginButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 24, paddingRight: 24)
        
        view?.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view?.leftAnchor,
                                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                     right: view.rightAnchor,
                                     paddingLeft: 40,
                                     paddingRight: 40)
    }
}
