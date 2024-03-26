//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource {
        
    private var posts: [Post] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        fetchPosts()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Post Cell", for: indexPath) as! PostCell
        

        let post = posts[indexPath.row]
        if let photo = post.photos.first {
            let url = photo.originalSize.url
            Nuke.loadImage(with: url, into: cell.postImageView)
        }
        cell.label.text = post.summary
        return cell
    }

    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)
                DispatchQueue.main.async {
                    self.posts = blog.response.posts
                    self.tableView.reloadData()
//                    self.tableView.refreshControl?.endRefreshing()
                    print("✅ We got \(self.posts.count) posts!")
                }
            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
