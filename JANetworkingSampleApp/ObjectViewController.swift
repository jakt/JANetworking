//
//  ObjectViewController.swift
//  JANetworking
//
//  Created by Jay Chmilewski on 6/20/17.
//  Copyright © 2017 JAKT. All rights reserved.
//

import UIKit
import JANetworking

class ObjectViewController: UIViewController {

    @IBOutlet weak var numberLoadedLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var posts:[Post] = [] {
        didSet {
            numberLoadedLabel.text = "\(posts.count)"
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAll()
    }
    
    func fetchAll() {
        JANetworking.loadJSON(resource: Post.all()) { (posts, error) in
            guard let posts = posts else {
                if let err:JANetworkingError = error {
                    print("NETWORK ERROR: \(err.errorType.errorTitle())")
                    if let data = err.errorData, let code = err.statusCode {
                        print("Status Code: \(code), Details: \(data)")
                    }
                }
                return
            }
            self.posts = posts
        }
    }
    
    /// Use this function to test paged server calls
    func loadPage<A>(for resource:JANetworkingResource<A>) {
        JANetworking.loadPagedJSON(resource: resource, pageLimit:2) { [weak self] (data, error) in
            if error == nil {
                if JANetworking.isNextPageAvailable(for: resource, pageLimit:2) {
                    self?.loadPage(for: resource)
                } else {
                    print("NO PAGES LEFT")
                }
            } else {
                print("error")
            }
        }
    }
    
}

extension ObjectViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        titleLabel.text = post.title
        authorLabel.text = post.authorId
    }
}

extension ObjectViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        return cell
    }
}
