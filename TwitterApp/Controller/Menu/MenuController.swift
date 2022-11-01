//
//  MenuController.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 05.11.2021.
//

import UIKit
import Firebase

class MenuController: UIViewController {
    
    // MARK: - Properties
    
    private var user: TwitterUser?
    
    private let imagesArray: [String] = ["person", "arrow.backward.square"]
    private let dataSourceArray: [String] = ["Профиль", "Выйти"]
    
    var collectionView: UICollectionView!
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        return iv
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    // Информация о пользователе
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3
        label.textColor = .white
        return label
    }()
    
    private let followingLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        
        configureCollectionView()
        setupUI()
        fetchUser()
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = .twitterBlue
        
        self.view.addSubview(collectionView)
    }
    
    func setupUI() {
        view.addSubview(profileImageView)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 12, paddingLeft: 16)
        profileImageView.setDimensions(width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        let userDetailStack = UIStackView(arrangedSubviews: [fullNameLabel, usernameLabel, bioLabel])
        userDetailStack.axis = .vertical
        userDetailStack.distribution = .fillProportionally
        userDetailStack.spacing = 8
        
        view.addSubview(userDetailStack)
        userDetailStack.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 8, paddingLeft: 16, paddingRight: 12)
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.axis = .horizontal
        followStack.spacing = 12
        followStack.distribution = .fillEqually
        
        view.addSubview(followStack)
        followStack.anchor(top: userDetailStack.bottomAnchor, left: view.leftAnchor, paddingTop: 8, paddingLeft: 16)
    }
    
    func configure(user: TwitterUser) {
        let viewModel = ProfileHeaderViewModel(user: user)
        
        profileImageView.sd_setImage(with: user.profileImageUrl)
        followingLabel.attributedText = viewModel.followingString
        followingLabel.textColor = .white
        followersLabel.attributedText = viewModel.followersString
        followersLabel.textColor = .white
        
        fullNameLabel.text = user.fullname
        usernameLabel.text = viewModel.userNameText
        bioLabel.text = user.bio
    }
    
    // MARK: - API
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { [weak self] user in
            self?.user = user
            
            UserService.shared.fetchUserStats(uid: user.uid) { [weak self] stats in
                self?.user?.stats = stats
                
                var userWithStats = user
                userWithStats.stats = stats
                
                self?.configure(user: userWithStats)
                self?.collectionView.reloadData()
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegate

extension MenuController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            guard let user = user else { return }
            let controller = ProfileController(user: user)
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
            
        } else if indexPath.row == 1 {
            do {
                try Auth.auth().signOut()
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                
                self.dismiss(animated: true)
                self.present(nav, animated: true, completion: nil)
                
            } catch let error {
                print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MenuController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as? MenuCollectionViewCell else { return UICollectionViewCell() }
        cell.iconImageView.image = UIImage(systemName: imagesArray[indexPath.row])?.withTintColor(.white, renderingMode: .alwaysOriginal)
        cell.myLabel.text = dataSourceArray[indexPath.row]
        return cell
        
    }
}

// MARK: - Extension UICollectionViewDelegateFlowLayout

extension MenuController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        var height: CGFloat = 190
        if user?.bio != "" {
            height += 30
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}
