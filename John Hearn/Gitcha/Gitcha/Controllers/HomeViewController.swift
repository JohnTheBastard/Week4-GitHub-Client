//
//  HomeViewController.swift
//  Gitcha
//
//  Created by John D Hearn on 11/1/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    var filteredRepos = [Repository]()
    let customTransition = CustomTransition()


    @IBOutlet weak var repositoryTableView: UITableView!
    @IBOutlet weak var repositorySearchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.repositoryTableView.estimatedRowHeight = 75
        self.repositoryTableView.rowHeight = UITableViewAutomaticDimension


        self.navigationController?.navigationBar.tintColor = .white
        self.repositoryTableView.dataSource = self
        self.repositoryTableView.delegate = self
        self.repositorySearchBar.delegate = self

        let nib = UINib(nibName: "RepositoryTableViewCell", bundle: Bundle.main)
        self.repositoryTableView.register(nib, forCellReuseIdentifier: RepositoryTableViewCell.identifier)

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
            let selectedIndex = repositoryTableView.indexPathForSelectedRow!.row
            let selectedRepository: Repository
            if repositorySearchBar.text! != "" {
                selectedRepository = self.filteredRepos[selectedIndex]
            } else {
                selectedRepository = GitHubService.shared.allRepos[selectedIndex]
            }

            if let destinationController = segue.destination as? RepoDetailViewController {
                destinationController.transitioningDelegate = self
                destinationController.navigationController?.transitioningDelegate = self
                destinationController.repository = selectedRepository

            }

        }
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.customTransition
    }

}

extension HomeViewController: UINavigationControllerDelegate{

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.customTransition
    }

}

extension HomeViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.resignFirstResponder()
        //        let text = searchBar.text!
        //        self.filteredRepos = GitHubService.shared.allRepos.filter({$0.name.lowercased().contains(text.lowercased())})
        //
        //        self.repositoryTableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredRepos = GitHubService.shared.allRepos.filter({$0.name.lowercased().contains(searchText.lowercased())})
        self.repositoryTableView.reloadData()
    }

}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: RepoDetailViewController.identifier, sender: nil)
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryTableViewCell.identifier,
                                                 for: indexPath) as? RepositoryTableViewCell

        var currentRepository: Repository
        if repositorySearchBar.text! != "" {
            currentRepository = self.filteredRepos[indexPath.row]
        } else {
            currentRepository = GitHubService.shared.allRepos[indexPath.row]
        }

        cell?.repositoryLabel?.text = currentRepository.name
        cell?.descriptionLabel?.text = currentRepository.description
        return cell!
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if repositorySearchBar.text! != "" {
            return self.filteredRepos.count
        } else {
            return GitHubService.shared.allRepos.count
        }
    }

}


