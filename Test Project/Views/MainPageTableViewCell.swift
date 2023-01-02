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
}

class MainPageTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let cellIdentifier = "MainPageTableViewCell"
    var userName: UILabel!
    var hoursAgoCreated: UILabel!
    var pageText: UILabel!
    var commentsButton: UIButton!
    var voteButton: UIButton!
    var settingButton: UIButton!
    var media: UIImageView!
    var icon: UIImageView!
    var authorFullName: UILabel!
    var playButt: UIButton?
    
    var playerViewController = AVPlayerViewController()
    var playerView = AVPlayer()
    var delegate: VideoDeledate?
    var vidStr: String?
    
    // MARK: - Cell methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        media.removeFromSuperview()
        voteButton.removeFromSuperview()
        icon.removeFromSuperview()
        userName.removeFromSuperview()
        hoursAgoCreated.removeFromSuperview()
        commentsButton.removeFromSuperview()
        settingButton.removeFromSuperview()
        authorFullName.removeFromSuperview()
        playButt?.removeFromSuperview()
        vidStr = ""
    }
    
    static func nib() -> UINib {
        UINib(nibName: "MainPageTableViewCell", bundle: nil)
    }
    
    
    // MARK: - Setup UI methods
    // TODO: need to refactor this
    func cellPrepare() {
        self.addSubview(userName)
        self.addSubview(hoursAgoCreated)
        self.addSubview(pageText)
        self.addSubview(commentsButton)
        self.addSubview(voteButton)
        self.addSubview(settingButton)
        self.addSubview(icon)
        self.addSubview(media)
        self.addSubview(authorFullName)
    }
    
    func makeContrains(with viewModel: MainPageViewModel) {
        voteButton.titleLabel?.textAlignment = .center
        commentsButton.titleLabel?.textAlignment = .center
        
        media.layer.masksToBounds = true
        media.layer.cornerRadius = 5
        media.snp.makeConstraints { make in
            make.top.equalTo(self.pageText.snp.bottom).offset(5)
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(400)
            make.width.equalTo(391)
        }
        media.addSubview(playButt!)
        
        if viewModel.data.isVideo {
            playButt?.isHidden = false
            playButt?.snp.makeConstraints({ make in
                make.center.equalTo(self.media.snp.center)
                make.width.equalTo(80)
                make.height.equalTo(80)
            })
            playButt?.setTitle("play", for: .normal)
        } else {
            playButt?.isHidden = true
        }
        
        
        icon.layer.masksToBounds = true
        icon.layer.cornerRadius = 5
        icon.snp.makeConstraints { make in
            make.top.equalTo(14)
            make.leading.equalTo(15)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        userName.snp.makeConstraints { make in
            make.top.equalTo(10)
            if !(icon.isHidden) {
                make.left.equalTo(icon.snp.right).offset(5)
            } else {
                make.left.equalToSuperview().offset(35)
            }
        }
        
        authorFullName.snp.makeConstraints { make in
            make.top.equalTo(self.userName.snp.bottom).offset(2)
            if !(icon.isHidden) {
                make.left.equalTo(icon.snp.right).offset(5)
            } else {
                make.left.equalToSuperview().offset(35)
            }
            if let title = voteButton.titleLabel {
                make.width.equalTo(title.snp.width).offset(16)
            }
        }
        
        hoursAgoCreated.snp.makeConstraints { make in
            make.top.equalTo(self.authorFullName.snp.top)
            make.left.equalTo(self.authorFullName.snp.right).offset(5)
            make.right.lessThanOrEqualToSuperview().offset(5)
        }
        
        pageText.snp.makeConstraints { make in
            make.top.equalTo(self.authorFullName.snp.bottom).offset(8)
            make.leading.equalTo(15)
            make.right.lessThanOrEqualToSuperview().offset(-5)
        }
        
        // TODO: for future / vote butt
        //        voteButton.addTarget(self, action: #selector(tapVoteButton), for: .touchUpInside)
        voteButton.snp.makeConstraints { make in
            
            make.bottom.equalTo(-10)
            make.left.equalTo(15)
            
            if !(media.isHidden) {
                make.top.equalTo(self.media.snp.bottom).offset(8)
            } else {
                make.top.equalTo(self.pageText.snp.bottom).offset(8)
            }
            
            if let title = voteButton.titleLabel {
                make.width.equalTo(title.snp.width).offset(16)
            }
        }
        
        commentsButton.snp.makeConstraints { make in
            make.top.equalTo(self.voteButton.snp.top)
            make.left.equalTo(self.voteButton.snp.right).offset(8)
            
            if let title = commentsButton.titleLabel {
                make.width.equalTo(title.snp.width).offset(16)
            }
        }
        
        self.layoutIfNeeded()
    }
    
    @objc func tapOnMedia() {
        if let videoString = vidStr {
            playVideo(videoString: videoString)
        }
    }
    
    private func setupUI() {
        pageText.numberOfLines = 0
        pageText.font = UIFont.boldSystemFont(ofSize: 15.0)
        pageText.setContentCompressionResistancePriority(.required, for: .vertical)
        commentsButton.backgroundColor = .clear
        voteButton.setTitleColor(.gray, for: .normal)
        commentsButton.setTitleColor(.gray, for: .normal)
        userName.textColor = .gray
        userName.font = UIFont.systemFont(ofSize: 12)
        hoursAgoCreated.font = UIFont.systemFont(ofSize: 12)
        authorFullName.font = UIFont.systemFont(ofSize: 12)
        hoursAgoCreated.textColor = .gray
        authorFullName.textColor = .gray
    }
    
    // TODO: for future / vote butt
    
    //    @objc func tapVoteButton(sender: UIButton!) {
    //        voteButton.backgroundColor = .systemBlue
    //        voteButton.setTitleColor(.white, for: .normal)
    //    }
    
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
    
    private func createItems() {
        media = UIImageView()
        icon = UIImageView()
        playButt = UIButton()
        voteButton = UIButton()
        hoursAgoCreated = UILabel()
        pageText = UILabel()
        commentsButton = UIButton()
        userName = UILabel()
        settingButton = UIButton()
        icon = UIImageView()
        media = UIImageView()
        authorFullName = UILabel()
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
        hoursAgoCreated.text = "· 10" + "h"
        pageText.text = viewModel.data.title
        commentsButton.setTitle(String(viewModel.data.numComments), for: .normal)
        voteButton.setTitle(validateCount(count: viewModel.data.score), for: .normal)
        authorFullName.text = "u/" + viewModel.data.authorFullname
        if let video = viewModel.data.media?.redditVideo {
            self.vidStr = video.fallbackURL
        }
        
        if !(viewModel.data.isVideo), let url = URL(string: viewModel.data.url),
           UIApplication.shared.canOpenURL(url) {
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
        if userName == nil {
            createItems()
        }
        
        cellPrepare()
        makeContrains(with: viewModel)
        setupUI()
        setupData(with: viewModel)
        
        self.layoutIfNeeded()
    }
}

// MARK: - UrlType enum

enum UrlType {
    case icon, pagemedia
}
