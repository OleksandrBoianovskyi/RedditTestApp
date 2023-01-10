//
//  MainPageViewController.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 29.08.2022.
//

import UIKit
import AVKit
import SnapKit

class MainPageViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var mainTableView: UITableView!
    
    var pageModel: PageModel?
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var downloadManager: DownloadManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadManager = DownloadManager(pageViewModel: pageModel, mainPageViewModel: nil)
        
        mainTableView.register(MainPageTableViewCell.nib(), forCellReuseIdentifier: MainPageTableViewCell.cellIdentifier)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        prepareActivityIndicator()
        parseData()
    }
    
    // MARK: - SetupUI
    
    private func prepareActivityIndicator() {
        mainTableView.addSubview(activityIndicator)
        activityIndicator.color = .black
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(self.mainTableView.snp.center)
        }
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    // MARK: - Business logic
    
    func parseData() {
        let urlString = "https://www.reddit.com/top.json"
        
        downloadManager?.loadJson(fromURLString: urlString) { (result) in
            switch result {
            case .success(let data):
                self.pageModel = self.downloadManager?.parse(jsonData: data)
                DispatchQueue.main.async {
                    self.mainTableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension MainPageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pageModel?.data.children.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  MainPageTableViewCell.cellIdentifier, for: indexPath) as! MainPageTableViewCell
        if let pageModel = pageModel {
            let viewModel = MainPageViewModel(with: pageModel.data.children[indexPath.row].data)
            cell.delegate = self
            cell.configure(with: viewModel)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainTableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MainPageViewController: UITableViewDataSource { }

// MARK: - VideoDeledate

extension MainPageViewController: VideoDeledate {
    func dismiss() {
        self.dismiss(animated: true)
    }
    
    func presentViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool) {
        self.present(viewControllerToPresent, animated: flag)
    }
    
    func presentVideo(with viewController: AVPlayerViewController) {
        self.present(viewController, animated: true)
        viewController.player?.play()
    }
}
