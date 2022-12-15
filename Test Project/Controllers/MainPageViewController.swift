//
//  MainPageViewController.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 29.08.2022.
//

import UIKit

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var mainTableView: UITableView!
    var pageModel: PageModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.register(MainPageTableViewCell.nib(), forCellReuseIdentifier: MainPageTableViewCell.cellIdentifier)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        parseData()
    }
    
    
    private func parseData() {
        let urlString = "https://www.reddit.com/top.json"
        
        self.loadJson(fromURLString: urlString) { (result) in
            switch result {
            case .success(let data):
                self.parse(jsonData: data)
                DispatchQueue.main.async {
                    self.mainTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func parse(jsonData: Data) {
        do {
            self.pageModel = try JSONDecoder().decode(PageModel.self,
                                                     from: jsonData)
        } catch {
            print("Parse fail with error: \(error)")
        }
    }
    
    private func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageModel?.data.children.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  MainPageTableViewCell.cellIdentifier, for: indexPath) as! MainPageTableViewCell
        if let pageModel = pageModel {
            let viewModel = MainPageViewModel(with: pageModel.data.children[indexPath.row].data)
            
            cell.configure(with: viewModel)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainTableView.deselectRow(at: indexPath, animated: true)
    }
    
}