//
//  MainPageTableViewCell.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 06.09.2022.
//

import UIKit
import SnapKit
import AVKit
import AVFoundation

class MainPageTableViewCell: UITableViewCell {
    
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
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var media: UIImageView! {
        didSet {
            let imageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnMedia))
            media.addGestureRecognizer(imageTapGestureRecognizer)
            media.isUserInteractionEnabled = true
        }
    }
    
    static let cellIdentifier = "MainPageTableViewCell"
    var playerViewController = AVPlayerViewController()
    var playerView = AVPlayer()
    let factory = ButtonsActionFactory.defaultFactory
    var delegate: VideoDeledate?
    var downloadManager: DownloadManager?
    
    // Refactor this
    var vidStr: String?
    var viewModell: MainPageViewModel?
    var image: UIImage!
    var previewMedia: UIImageView!
    
    // MARK: - Cell methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playImage.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        vidStr = ""
        playImage.isHidden = true
        image = nil
        previewMedia = nil
    }
    
    static func nib() -> UINib {
        UINib(nibName: "MainPageTableViewCell", bundle: nil)
    }
    
    // MARK: - Setup UI methods
    
    private func setupUI() {
        pageText.setContentCompressionResistancePriority(.required, for: .vertical)
        hourAgoCreated.textColor = .gray
        authorFullName.textColor = .gray
        if media.isHidden {
            upVoteButton.snp.makeConstraints { make in
                make.top.equalTo(self.pageText.snp.bottom).offset(5)
            }
        }
    }
    
    func makeCustomBarButton() -> UIBarButtonItem {
        let arrowImage = UIImage(systemName: "xmark")
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(arrowImage, for: [])
        button.addTarget(self, action: #selector(dismissFullscreenImage), for: .touchUpInside)
        button.sizeToFit()
        let barButton = UIBarButtonItem(customView: button)
        
        return barButton
    }
        
    // MARK: - IBActions
    
    @IBAction func tapOnUpVote(_ sender: Any) {
        factory.createButtonAction(with: .upVote, upVoteButton: upVoteButton, downVoteButton: downVoteButton, scoreButton: score)
    }
    
    @IBAction func tapOnDownVote(_ sender: Any) {
        factory.createButtonAction(with: .downVote, upVoteButton: upVoteButton, downVoteButton: downVoteButton, scoreButton: score)
    }
    
    @IBAction func tapOnScoreButton(_ sender: Any) {
        factory.createButtonAction(with: .score, upVoteButton: upVoteButton, downVoteButton: downVoteButton, scoreButton: score)
    }
    
    @IBAction func tapOnCommentButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        vc.modalPresentationStyle = .fullScreen
        
        delegate?.presentViewController(vc, animated: true)
        if let viewModel = viewModell {
            vc.setup(with: viewModel)
        }
    }
    
    @IBAction func tapOnShareButton(_ sender: Any) {
        if let viewModell = viewModell {
            factory.createShareButtonAction(with: viewModell, delegate: delegate, sender: sender, nil)
        }
    }
    
    @IBAction func tapOnSettingButton(_ sender: Any) {
        if let viewModell = viewModell {
            factory.createSettingButtonAction(with: viewModell, delegate: delegate)
        }
    }
    
    // MARK: - @objc methods
    
    @objc func tapOnMedia() {
        if let videoString = vidStr, !videoString.isEmpty {
            playVideo(videoString: videoString)
        } else {
            
            let navigationController = UINavigationController()
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.view.backgroundColor = .black
            let previewImageVC = PreviewImageVC()
            previewImageVC.view.backgroundColor = .black
            
            previewImageVC.view.addSubview(previewMedia)
            
            let ratio = image.size.width / image.size.height
            let newHeight = self.frame.width / ratio
            self.previewMedia.snp.makeConstraints({ make in
                make.height.equalTo(newHeight)
                make.right.left.lessThanOrEqualToSuperview()
                make.center.equalTo(previewImageVC.view.snp.center)
                self.layoutIfNeeded()
            })
            
            previewImageVC.navigationItem.leftBarButtonItem = makeCustomBarButton()
            previewImageVC.navigationItem.title = "Reddit App"
            previewImageVC.tabBarItem.badgeColor = .brown
            navigationController.pushViewController(previewImageVC, animated: false)
            
            delegate?.presentViewController(navigationController, animated: true)
        }
    }
    
    @objc func dismissFullscreenImage() {
        delegate?.dismiss()
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
    
    private func downloadImage(from url: URL, type: UrlType) {
        downloadManager?.getData(from: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async() { [weak self] in
                    switch type {
                    case .icon:
                        self?.icon.image = UIImage(data: data)
                    case .pagemedia:
                        self?.media.image = UIImage(data: data)
                        self?.image = UIImage(data: data)
                        self?.previewMedia.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    func playVideo(videoString: String) {
        guard let url = URL(string: videoString) else { return }
        playerView = AVPlayer(url: url)
        playerViewController.player = playerView
        
        delegate?.presentVideo(with: playerViewController)
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
        self.viewModell = viewModel
        
        userName.attributedText = createUserName(with: viewModel)
        hourAgoCreated.text = "· 10" + "h"
        pageText.text = viewModel.data.title
        commentButton.setTitle(String(viewModel.data.numComments), for: .normal)
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
    
    public func configure(with viewModel: MainPageViewModel) {
        downloadManager = DownloadManager(pageViewModel: nil, mainPageViewModel: viewModel)
        image = UIImage()
        previewMedia = UIImageView()
        if viewModel.data.isVideo {
            playImage.isHidden = false
        }
        setupData(with: viewModel)
        setupUI()
    }
}

// MARK: - UrlType enum

enum UrlType {
    case icon, pagemedia
}

// MARK: - PreviewImageVC

class PreviewImageVC: UIViewController { }

// MARK: - VideoDeledate

protocol VideoDeledate {
    func presentVideo(with viewController: AVPlayerViewController)
    func presentViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool)
    func dismiss()
}
