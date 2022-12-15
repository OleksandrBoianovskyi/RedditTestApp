//
//  MainPageTableViewCell.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 06.09.2022.
//

import UIKit
import SnapKit

class MainPageTableViewCell: UITableViewCell {

    
    static let cellIdentifier = "MainPageTableViewCell"
    var userName = UILabel()
    var hoursAgoCreated = UILabel()
    var pageText = UILabel()
    var commentsButton = UIButton()
    var voteButton = UIButton()
    var settingButton = UIButton()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        cellPrepare()
        makeContrains()
        setupUI()
        
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

//    private func downloadImage(from url: URL) {
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            // always update the UI from the main thread
//            DispatchQueue.main.async() { [weak self] in
//                self?.media.image = UIImage(data: data)
//            }
//        }
//    }
    
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
        pageText.sizeToFit()
        settingButton.sizeToFit()
        voteButton.titleLabel?.textAlignment = .center
        commentsButton.titleLabel?.textAlignment = .center
        
        userName.snp.makeConstraints { make in
            make.top.leading.equalTo(10)
        }
        
        hoursAgoCreated.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(self.userName.snp.right).offset(5)
        }
        
        pageText.snp.makeConstraints { make in
            make.top.equalTo(self.userName.snp.bottom).offset(8)
            make.leading.equalTo(10)
            make.width.lessThanOrEqualToSuperview()
        }
        
        voteButton.snp.makeConstraints { make in
            make.top.equalTo(self.pageText.snp.bottom).offset(8)
            make.bottom.equalTo(-10)
            make.leading.equalTo(10)
            
            if let title = voteButton.titleLabel {
                make.width.equalTo(title.snp.width).offset(16)
            }
        }
        
        commentsButton.snp.makeConstraints { make in
            make.top.equalTo(self.pageText.snp.bottom).offset(8)
            make.left.equalTo(self.voteButton.snp.right).offset(8)
            make.bottom.equalTo(-10)
            
            if let title = commentsButton.titleLabel {
                make.width.equalTo(title.snp.width).offset(16)
            }
        }
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
    
    private func validateCount(count: Int) -> String {
        let num = Double(count)
        let newCountInDouble = Double(Int(num / 100)) / 10
        if newCountInDouble.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(newCountInDouble)) + "k"
        } else {
            return String(newCountInDouble) + "k"
        }
    }
    
    static func nib() -> UINib {
        UINib(nibName: "MainPageTableViewCell", bundle: nil)
    }
    
    public func configure(with viewModel: MainPageViewModel) {
        userName.text = viewModel.data.subredditNamePrefixed
        hoursAgoCreated.text = "· 10" + "h"
        pageText.text = viewModel.data.title
        commentsButton.setTitle(validateCount(count: viewModel.data.numComments), for: .normal)
        voteButton.setTitle(validateCount(count: viewModel.data.score), for: .normal)
        
//        if let urlString = viewModel.data.preview?.images.first?.source.url {
//            if let url = URL(string: urlString) {
//                downloadImage(from: url)
//            }
//        }
    }
}
