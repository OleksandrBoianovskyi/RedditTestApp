//
//  MainPageTableViewCell.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 06.09.2022.
//

import UIKit
import SnapKit

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
    
    // MARK: - Cell methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellPrepare()
        makeContrains()
        setupUI()
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
    }
    
    static func nib() -> UINib {
        UINib(nibName: "MainPageTableViewCell", bundle: nil)
    }
    
    
    // MARK: - Setup UI methods
    
    func cellPrepare() {
        self.addSubview(userName)
        self.addSubview(hoursAgoCreated)
        self.addSubview(pageText)
        self.addSubview(commentsButton)
        self.addSubview(voteButton)
        self.addSubview(settingButton)
    }
    
    func makeContrains() {
        userName.sizeToFit()
        hoursAgoCreated.sizeToFit()
        settingButton.sizeToFit()
        voteButton.titleLabel?.textAlignment = .center
        commentsButton.titleLabel?.textAlignment = .center
        
        userName.snp.makeConstraints { make in
            make.top.equalTo(10)
            if let icon = icon {
                make.left.equalTo(icon.snp.right).offset(5)
            }
        }
        
        hoursAgoCreated.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(self.userName.snp.right).offset(5)
            if !(media.isHidden) {
                make.right.lessThanOrEqualTo(media.snp.left).offset(-5)
            } else {
                make.right.lessThanOrEqualToSuperview().offset(5)
            }
        }
        
        pageText.snp.makeConstraints { make in
            make.top.equalTo(self.userName.snp.bottom).offset(8)
            make.leading.equalTo(15)
            if !(media.isHidden) {
                make.right.lessThanOrEqualTo(media.snp.left).offset(-10)
            } else {
                make.right.lessThanOrEqualToSuperview().offset(-5)
            }
        }
        
        // TODO: for future / vote butt
//        voteButton.addTarget(self, action: #selector(tapVoteButton), for: .touchUpInside)
        voteButton.snp.makeConstraints { make in
            make.top.equalTo(self.pageText.snp.bottom).offset(8)
            make.bottom.equalTo(-10)
            make.leading.equalTo(15)
            
            if let title = voteButton.titleLabel {
                make.width.equalTo(title.snp.width).offset(16)
            }
        }
        
        commentsButton.snp.makeConstraints { make in
            make.top.equalTo(self.pageText.snp.bottom).offset(8)
            make.left.equalTo(self.voteButton.snp.right).offset(8)
            
            if let title = commentsButton.titleLabel {
                make.width.equalTo(title.snp.width).offset(16)
            }
        }
    }
    
    private func setupMedia() {
        media = UIImageView()
        self.addSubview(media)
        media.layer.masksToBounds = true
        media.layer.cornerRadius = 5
        media.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.right.equalTo(-15)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
            make.height.equalTo(75)
            make.width.equalTo(95)
        }
        
        self.layoutIfNeeded()
    }
    
    private func setupIcon() {
        icon = UIImageView()
        self.addSubview(icon)
        icon.layer.masksToBounds = true
        icon.layer.cornerRadius = 5
        icon.snp.makeConstraints { make in
            make.top.equalTo(14)
            make.leading.equalTo(15)
            make.height.equalTo(15)
            make.width.equalTo(15)
        }
        
        self.layoutIfNeeded()
    }
    
    private func setupUI() {
        pageText.numberOfLines = 0
        pageText.setContentCompressionResistancePriority(.required, for: .vertical)
        commentsButton.backgroundColor = .clear
        commentsButton.layer.cornerRadius = 18
        commentsButton.layer.borderWidth = 0.5
        commentsButton.layer.borderColor = UIColor.gray.cgColor
        voteButton.layer.cornerRadius = 18
        voteButton.layer.borderWidth = 0.5
        voteButton.layer.borderColor = UIColor.gray.cgColor
        voteButton.setTitleColor(.gray, for: .normal)
        commentsButton.setTitleColor(.gray, for: .normal)
        hoursAgoCreated.textColor = .gray
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
    
    private func createItems() {
        voteButton = UIButton()
        hoursAgoCreated = UILabel()
        pageText = UILabel()
        commentsButton = UIButton()
        userName = UILabel()
        settingButton = UIButton()
        icon = UIImageView()
        media = UIImageView()
    }
    
    public func configure(with viewModel: MainPageViewModel) {
        if userName == nil {
            createItems()
        }
        
        userName.text = viewModel.data.subredditNamePrefixed
        hoursAgoCreated.text = "· 10" + "h"
        pageText.text = viewModel.data.title
        commentsButton.setTitle(validateCount(count: viewModel.data.numComments), for: .normal)
        voteButton.setTitle(validateCount(count: viewModel.data.score), for: .normal)
        
        if let url = URL(string: viewModel.data.thumbnail),
            UIApplication.shared.canOpenURL(url) {
            setupMedia()
            downloadImage(from: url, type: .pagemedia)
        } else {
            media.isHidden = true
        }
        
        if !(viewModel.data.allAwardings.isEmpty),
            let iconStringUrl = viewModel.data.allAwardings.first?.iconURL,
            let url = URL(string: iconStringUrl),
            UIApplication.shared.canOpenURL(url) {
            setupIcon()
            downloadImage(from: url, type: .icon)
        } else {
            icon.isHidden = true
        }
        
        self.layoutIfNeeded()
    }
}

// MARK: - UrlType enum

enum UrlType {
    case icon, pagemedia
}
