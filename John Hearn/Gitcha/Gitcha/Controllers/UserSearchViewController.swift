//
//  UserSearchViewController.swift
//  Gitcha
//
//  Created by John D Hearn on 11/3/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit
import SafariServices

protocol UserSearchViewControllerDelegate : class{
    func userSearchViewController(selected: UIImage)
}

class UserSearchViewController: UIViewController {

    weak var delegate: UserSearchViewControllerDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!  //TODO: remove

    private var session = URLSession()

    var searchedUsers = [User](){               //TODO: remove
        didSet{
            collectionView.reloadData()
        }
    }
//    var searchedUserAvatars = [PhotoRecord](){
//        didSet{
//            collectionView.reloadData()
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
//        self.tableView.dataSource = self
//        self.tableView.delegate = self
        self.searchBar.delegate = self

    }

}

extension UserSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text{
            GitHubService.shared.searchUsersWith(searchTerm: searchText, completion: { (results) in
                if let results = results {
                    self.searchedUsers = results
                }
            })
        }
        self.searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isValid {
            let lastIndex = searchText.index(before: searchText.endIndex)
            searchBar.text = searchText.substring(to: lastIndex)
        }

    }
}

extension UserSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let currentCell = collectionView.dequeueReusableCell(withReuseIdentifier: UserSearchCollectionViewCell.identifier,
                                                             for: indexPath) as! UserSearchCollectionViewCell
        currentCell.imageView.image = self.searchedUsers[indexPath.row].avatar.image
        currentCell.usernameLabel.text = self.searchedUsers[indexPath.row].login

        return currentCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return searchedUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let delegate = self.delegate else { return }

        let user = self.searchedUsers[indexPath.row]

        delegate.userSearchViewController(selected: user.avatar.image!)
    }

}

//TODO: remove
extension UserSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let currentUser = self.searchedUsers[indexPath.row]

        cell.textLabel?.text = currentUser.login

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedUsers.count
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = self.searchedUsers[indexPath.row]
        //presentWebViewControllerWith(url: selectedUser.webUrl)
        presentSafariViewControllerWith(url: selectedUser.webUrl)

        //self.performSegue(withIdentifier: <#T##String#>, sender: nil)
    }

    func presentWebViewControllerWith(url: String){
        let webViewController = WebViewController()
        webViewController.webUrl = url
        self.present(webViewController, animated: true, completion: nil)
    }

    func presentSafariViewControllerWith(url: String) {
        let safariViewController = SFSafariViewController(url: URL(string: url)!)
        self.present(safariViewController, animated: true, completion: nil)
    }


}
