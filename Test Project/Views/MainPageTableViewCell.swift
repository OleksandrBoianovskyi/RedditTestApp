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

protocol VideoDeledate {
    func presentVideo(with viewController: AVPlayerViewController)
    func presentViewController(_ viewControllerToPresent: UIViewController, animated flag: Bool)
}

class MainPageTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let cellIdentifier = "MainPageTableViewCell"
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var authorFullName: UILabel!
    @IBOutlet weak var hourAgoCreated: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var media: UIImageView!
    @IBOutlet weak var pageText: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var score: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var playImage: UIImageView!
    
    var playerViewController = AVPlayerViewController()
    var playerView = AVPlayer()
    var delegate: VideoDeledate?
    var vidStr: String?
    var viewModell: MainPageViewModel?
    
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
    
    // TODO: for future / vote butt
    
    @IBAction func tapOnUpVote(_ sender: Any) {
        upVoteButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        upVoteButton.tintColor = .orange
        score.setTitleColor(.orange, for: .normal)
        downVoteButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        downVoteButton.tintColor = .darkGray
    }
    
    @IBAction func tapOnDownVote(_ sender: Any) {
        downVoteButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        downVoteButton.tintColor = .purple
        score.setTitleColor(.purple, for: .normal)
        upVoteButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        upVoteButton.tintColor = .darkGray
    }
    
    @IBAction func tapOnScoreButton(_ sender: Any) {
        upVoteButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        upVoteButton.tintColor = .darkGray
        downVoteButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        downVoteButton.tintColor = .darkGray
        score.setTitleColor(.gray, for: .normal)
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
    
    @IBAction func tapOnSettingButton(_ sender: Any) {
        let viewController = SettingViewController(nibName: "SettingViewController", bundle: nil)
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .formSheet
        viewController.viewModel = viewModell
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in
                return viewController.view.frame.height
            })]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.selectedDetentIdentifier = .medium
        }
        
        delegate?.presentViewController(navController, animated: true)
    }
    
    @objc func tapOnMedia() {
        if let videoString = vidStr {
            playVideo(videoString: videoString)
        }
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
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func downloadImage(from url: URL, type: UrlType) {
        getData(from: url) { data, response, error in
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
    
    func getVideoFromURL(from url: URL, completion: @escaping ((UIImage?)) -> ()) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumblailTime = CMTimeMake(value: 2, timescale: 2)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumblailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
                
            } catch {
                print(error.localizedDescription)
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
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnMedia))
            media.isUserInteractionEnabled = true
            media.addGestureRecognizer(tap)
            
            getVideoFromURL(from: url) { (thumbImage) in
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
