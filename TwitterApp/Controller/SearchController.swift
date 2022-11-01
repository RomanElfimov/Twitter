//
//  ExploreController.swift
//  TwitterApp
//
//  Created by Роман Елфимов on 12.10.2021.
//

import UIKit

private let reuseIdentifier = "UserCell"

// Search, New Message configurations
enum SearchControllerConfiguration {
    case messages
    case userSearch
}

class SearchController: UITableViewController {
    
    // MARK: - Properties
    
    private let config: SearchControllerConfiguration
    
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
    
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    
    func fetchUsers() {
        UserService.shared.fetchUsers { [weak self] users in
            self?.users = users
        }
    }
    
    // MARK: - Selectors
    
    @objc func handleDismissal() {
        dismiss(animated: true)
    }
    
    // MARK: - Heplers
    
    func configureUI() {
        
        view.backgroundColor = .white
        navigationItem.title = config == .messages ? "Написать" : "Поиск"
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissal))
        }
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск в Твиттере"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
    
}

// MARK: - UITableViewDelegate / DataSource

extension SearchController {
    
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
        
        if config == .userSearch {
            let controller = ProfileController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = ChatViewController()
            controller.conversationalistName = user.username
            controller.conversationalistImgUrl = user.profileImageUrl
            controller.conversationalistID = user.uid
            navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

// MARK: - UISearchResultsUpdating

extension SearchController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({ $0.username.contains(searchText) })
    }
    
}
