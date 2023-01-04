//
//  CommentViewController.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 03.01.2023.
//

import UIKit
import AVKit
import AVFoundation

class CommentViewController: UIViewController {
    
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
    @IBOutlet weak var addCommentTextField: UITextField!
    
    var vidStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        addCommentTextField.layer.borderWidth = 0.01
        addCommentTextField.layer.cornerRadius = 17.0
        addCommentTextField.clipsToBounds = true
    }
    
    func setup(with viewModel: MainPageViewModel) {
        setupData(with: viewModel)
    }
     
    @IBAction func closeCommentView(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
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
            
//            let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnMedia))
//            media.isUserInteractionEnabled = true
//            media.addGestureRecognizer(tap)
            
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
    
    @IBAction func tapOnMoreComments(_ sender: Any) {
    }
    @IBAction func tapOnAddCommentTextField(_ sender: Any) {
    }
}

extension UIScrollView {
   func scrollToBottom(animated: Bool) {
     if self.contentSize.height < self.bounds.size.height { return }
     let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
     self.setContentOffset(bottomOffset, animated: animated)
  }
}
