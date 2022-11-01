//
//  ConversationController.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 12.10.2021.
//

import UIKit
import Firebase
import FirebaseFirestore

private let reuseIdentifier = "UserCell"

protocol ChatsControllerProtocol {
    func hideNewChatButton()
    func showNewChatButton()
}

class ConversationController: UITableViewController {
    
    // MARK: - Properties
    
    var delegate: ChatsControllerProtocol?
    
    private var users = [TwitterUser]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var filteredUsers = [TwitterUser]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureSearchController()
        
        fetchConversationalistsID()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delegate?.showNewChatButton()
//        tableView.reloadData()
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true)
    }
    
    // MARK: - API
    
    func fetchConversationalistsID() {
        
        // Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection("Chats")
            .whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not Found User 1")
        
        db.getDocuments { (chatQuerySnap, error) in
            
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                
                // Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                
                if queryCount >= 1 {
                    // Chat(s) found for currentUser
                    for doc in chatQuerySnap!.documents {
                        guard let chat = Chat(dictionary: doc.data()) else { return }
                        self.fetchConversationalistByID(usersId: chat.users)
                    }
                }
            }
        }
    }
    
    func fetchConversationalistByID(usersId: [String]) {
        for userId in usersId {
            UserService.shared.fetchUser(uid: userId) { user in
                
                let curr = Auth.auth().currentUser?.uid
                if userId != curr {
                    self.users.append(user)
                }
            }
        }
    }
    
    // MARK: - Heplers
    
    func configureUI() {
        
        view.backgroundColor = .white
        navigationItem.title = "Сообщения"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск диалогов"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}

// MARK: - UITableViewDelegate / DataSource

extension ConversationController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    override func  tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? UserCell else { return UITableViewCell() }
        
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        
        let controller = ChatViewController()
        
        controller.conversationalistName = user.username
        controller.conversationalistImgUrl = user.profileImageUrl
        controller.conversationalistID = user.uid
        
        delegate?.hideNewChatButton()
            
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension ConversationController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({ $0.username.contains(searchText) })
    }
    
}
