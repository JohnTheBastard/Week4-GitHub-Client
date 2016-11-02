//
//  HomeViewController.swift
//  Gitcha
//
//  Created by John D Hearn on 11/1/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

let kGitHubClientID = ""
let kGitHubClientSecret = ""

class HomeViewController: UIViewController {

    let customTransition = CustomTransition()

    @IBOutlet weak var repositoryTableView: UITableView!
    @IBOutlet weak var repositorySearchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.repositoryTableView.dataSource = self
        self.repositoryTableView.delegate = self
        self.repositorySearchBar.delegate = self
        update()
        // Do any additional setup after loading the view.
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func update() {
        // Do we really want to query GitHub everytime the view appears?
        GitHubService.shared.fetchRepos { (repositories) in
            if let repositories = repositories{
                GitHubService.shared.allRepos = repositories
            }
            self.repositoryTableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == RepoDetailViewController.identifier{
            if let destinationController = segue.destination as? RepoDetailViewController {
                destinationController.transitioningDelegate = self
            }

        }
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.customTransition
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: RepoDetailViewController.identifier, sender: nil)
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.identifier,
                                                 for: indexPath) as? RepositoryCell

        var currentRepository: Repository
        if repositorySearchBar.text! != "" {
            currentRepository = GitHubService.shared.filteredRepos[indexPath.row]
        } else {
            currentRepository = GitHubService.shared.allRepos[indexPath.row]
        }

        cell?.textLabel?.text = currentRepository.name
        cell?.detailTextLabel?.text = currentRepository.description
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if repositorySearchBar.text! != "" {
            return GitHubService.shared.filteredRepos.count
        } else {
            return GitHubService.shared.allRepos.count
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resignFirstResponder()
//        let text = searchBar.text!
//        let filteredRepos = GitHubService.shared.allRepos.filter({$0.name.lowercased().contains(text.lowercased())})
//        GitHubService.shared.filteredRepos = filteredRepos
//
//        self.repositoryTableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filteredRepos = GitHubService.shared.allRepos.filter({$0.name.lowercased().contains(searchText.lowercased())})
        GitHubService.shared.filteredRepos = filteredRepos

        self.repositoryTableView.reloadData()
    }

}


