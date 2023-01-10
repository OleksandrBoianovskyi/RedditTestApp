//
//  CommentViewController.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 03.01.2023.
//

import UIKit
import AVKit
import AVFoundation
import SafariServices

class CommentViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var authorFullName: UILabel!
    @IBOutlet weak var hourAgoCreated: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var pageText: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var score: UIButton!
    @IBOutlet weak var addCommentTextField: UITextField!
    @IBOutlet weak var media: UIImageView! {
        didSet {
            let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnMedia))
            media.addGestureRecognizer(imageTapGestureRecognizer)
            media.isUserInteractionEnabled = true
        }
    }
    
    var viewModel: MainPageViewModel?
    let factory = ButtonsActionFactory.defaultFactory
    var downloadManager: DownloadManager?
    
    // Refactor this
    var vidStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    func setupUI() {
        addCommentTextField.layer.borderWidth = 0.01
        addCommentTextField.layer.cornerRadius = 17.0
        addCommentTextField.clipsToBounds = true
    }
    
    func setup(with viewModel: MainPageViewModel) {
        downloadManager = DownloadManager(pageViewModel: nil, mainPageViewModel: viewModel)
        self.viewModel = viewModel
        setupData(with: viewModel)
    }
    
    // MARK: - Business logic
    
    private func validateCount(count: Int) -> String {
        let num = Double(count)
        let newCountInDouble = Double(Int(num / 100)) / 10
        if newCountInDouble.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(newCountInDouble)) + "k"
        } else {
            return String(newCountInDouble) + "k"
        }
    }
    
    private func createUserName(with viewModel: MainPageViewModel) -> NSAttributedString {
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.gray]
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.gray]
        
        let attributedString1 = NSMutableAttributedString(string: "r/", attributes: attrs1)
        let attributedString2 = NSMutableAttributedString(string: viewModel.data.subreddit, attributes: attrs2)
        
        attributedString1.append(attributedString2)
        
        return attributedString1
    }
    
    private func setupData(with viewModel: MainPageViewModel) {
        userName.attributedText = createUserName(with: viewModel)
        hourAgoCreated.text = "· 10" + "h"
        pageText.text = viewModel.data.title
        score.setTitle(validateCount(count: viewModel.data.score), for: .normal)
        authorFullName.text = "u/" + viewModel.data.authorFullname
        if let video = viewModel.data.media?.redditVideo {
            self.vidStr = video.fallbackURL
        }
        
        if !(viewModel.data.isVideo), let url = URL(string: viewModel.data.url),
           UIApplication.shared.canOpenURL(url),
           !(viewModel.data.thumbnail.isEmpty) {
            downloadImage(from: url, type: .pagemedia)
            
        } else if viewModel.data.isVideo, let url = URL(string: (viewModel.data.media?.redditVideo!.fallbackURL)!)  {
            
            downloadManager?.getVideoFromURL(from: url) { (thumbImage) in
                self.media.image = thumbImage
            }
        } else {
            media.isHidden = true
            
        }
        
        if !(viewModel.data.allAwardings.isEmpty),
           let iconStringUrl = viewModel.data.allAwardings.first?.iconURL,
           let url = URL(string: iconStringUrl),
           UIApplication.shared.canOpenURL(url) {
            
            downloadImage(from: url, type: .icon)
        } else {
            icon.isHidden = true
        }
    }
    
    private func downloadImage(from url: URL, type: UrlType) {
        downloadManager?.getData(from: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async() { [weak self] in
                    switch type {
                    case .icon:
                        self?.icon.image = UIImage(data: data)
                    case .pagemedia:
                        self?.media.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    private func makeAlertForComments() {
        let alert = UIAlertController(title: "The opportunity is blocked", message: "If you want to add a comment, you can do so on the web version of Reddit. Do you want to open the page?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            guard let urlString = self.viewModel?.data.url,
                  let url: URL = URL(string: urlString) else { return }
            
            let safari: SFSafariViewController = SFSafariViewController(url: url)
            self.present(safari, animated: true)
            }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (_) in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    @objc func tapOnMedia() { }
    
    // MARK: - IBActions
    
    @IBAction func closeCommentView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapOnUpVote(_ sender: Any) {
        factory.createButtonAction(with: .upVote, upVoteButton: upVoteButton, downVoteButton: downVoteButton, scoreButton: score)
    }
    
    @IBAction func tapOnDownVote(_ sender: Any) {
        factory.createButtonAction(with: .downVote, upVoteButton: upVoteButton, downVoteButton: downVoteButton, scoreButton: score)
    }
    
    @IBAction func tapOnScoreButton(_ sender: Any) {
        factory.createButtonAction(with: .score, upVoteButton: upVoteButton, downVoteButton: downVoteButton, scoreButton: score)
    }
    
    @IBAction func tapOnSettingButton(_ sender: Any) {
        let viewController = SettingViewController(nibName: "SettingViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        viewController.viewModel = viewModel
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in
                return viewController.view.frame.height
            })]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.selectedDetentIdentifier = .medium
        }
        
        self.present(navController, animated: true)
        
    }
    
    @IBAction func tapOnMoreComments(_ sender: Any) {
        makeAlertForComments()
    }
    
    @IBAction func tapOnAddCommentTextField(_ sender: Any) {
        makeAlertForComments()
    }
}

// MARK: - Extensions

extension UIScrollView {
   func scrollToBottom(animated: Bool) {
     if self.contentSize.height < self.bounds.size.height { return }
     let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
     self.setContentOffset(bottomOffset, animated: animated)
  }
}
