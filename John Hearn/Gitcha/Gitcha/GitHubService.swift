//
//  GitHubService.swift
//  Gitcha
//
//  Created by John D Hearn on 10/31/16.
//  Copyright © 2016 Bastardized Productions. All rights reserved.
//

import UIKit

let kBaseUrlString = "https://github.com/login/oauth"

typealias GitHubAuthCompletion = (Bool)->()
typealias RepoCompletion = ([Repository]?)->()

enum SaveOptions{
    case userDefaults
}

enum GitHubOAuthError: Error{

    case extractingCode(String)

}

class GitHubService {
    static let shared = GitHubService()
    private var session: URLSession
    private var urlComponents: URLComponents

    private init() {
        self.session = URLSession(configuration: .ephemeral)
        self.urlComponents = URLComponents()
        configure()
    }

    private func configure() {
        self.urlComponents.scheme = "https"
        self.urlComponents.host = "api.github.com"
        if let token = UserDefaults.standard.getAccessToken() {
            let tokenQueryItem = URLQueryItem(name: "access_token",
                                              value: token)
            urlComponents.queryItems = [tokenQueryItem]
        }
    }

    func fetchRepos(completion: @escaping RepoCompletion) {
        self.urlComponents.path = "/user/repos"

        guard let url = self.urlComponents.url else { completion(nil); return }
        self.session.dataTask(with: url) { (data, response, error) in
            if error != nil { completion(nil); return }
            if let data = data {
                var repos = [Repository]()
                do {
                    if let json = try JSONSerialization.jsonObject(with: data,
                                                                   options: .mutableContainers)
                        as? [[String: Any]]{

                        for repoJSON in json{
                            if let repository = Repository(json: repoJSON){
                                repos.append(repository)
                            }
                        }
                        OperationQueue.main.addOperation { completion(repos) }
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }

    func oAuth(parameters: [String:String]) {
        var parameterString = String()

        for(key, value) in parameters{
            parameterString += "&\(key)=\(value)"
        }

        if let requestURL = URL(string: "\(kBaseUrlString)/authorize?client_id=\(kGitHubClientID)\(parameterString)" ) {
            print(requestURL.absoluteString)
            UIApplication.shared.open(requestURL)
        }
    }

    func codeFrom(url: URL) throws -> String{
        guard let code = url.absoluteString.components(separatedBy: "=").last else {
            throw GitHubOAuthError.extractingCode("Temporary code not found in string. See codeFrom(url:)")
        }
        return code
    }

    func accessTokenFrom(_ string: String) -> String? {
        if string.contains("access_token") {

            let components = string.components(separatedBy: "&")

            for component in components{
                if component.contains("access_token") {
                    let token = component.components(separatedBy: "=").last

                    return token
                }
            }
        }
        return nil
    }

    func tokenRequestFor(url: URL, options: SaveOptions, completion: @escaping GitHubAuthCompletion) {
        func returnToMainWith(success: Bool) {
            OperationQueue.main.addOperation { completion(success) }
        }

        do{
            let code = try codeFrom(url: url)
            let requestString = "\(kBaseUrlString)/access_token?client_id=\(kGitHubClientID)&client_secret=\(kGitHubClientSecret)&code=\(code)"

            if let requestURL = URL(string: requestString){
                let session = URLSession(configuration: .ephemeral)

                session.dataTask(with: requestURL, completionHandler: { (data, response, error) in
                    if error != nil { returnToMainWith(success: false) }
                    guard let data = data else { returnToMainWith(success: true); return }

                    if let dataString = String(data: data, encoding: .utf8) {    // better solution?
                        if let token = self.accessTokenFrom(dataString) {
                            print("Access Token: \(token)")
                            let success = UserDefaults.standard.save(accessToken: token)
                            returnToMainWith(success: success)
                        }

                    } else {
                        returnToMainWith(success: false)
                    }
                }).resume()
            }
        } catch {
            returnToMainWith(success: false)
        }

    }


}










