//
//  MainPageTableViewCell.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 06.09.2022.
//

import UIKit

class MainPageTableViewCell: UITableViewCell {

    
    static let cellIdentifier = "MainPageTableViewCell"
    @IBOutlet var userName: UILabel!
    @IBOutlet var hoursAgoCreated: UILabel!
    @IBOutlet var pageText: UILabel!
    @IBOutlet var media: UIImageView!
    @IBOutlet var commentsButton: UIButton!
    @IBOutlet var voteButton: UIButton!
    @IBOutlet var settingButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setupUI()
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    private func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.media.image = UIImage(data: data)
            }
        }
    }
    
    private func setupUI() {
        pageText.numberOfLines = 0
        pageText.setContentCompressionResistancePriority(.required, for: .vertical)
        commentsButton.backgroundColor = .clear
        commentsButton.layer.cornerRadius = 18
        commentsButton.layer.borderWidth = 0.25
        commentsButton.layer.borderColor = UIColor.gray.cgColor
        voteButton.layer.cornerRadius = 18
        voteButton.layer.borderWidth = 0.5
        voteButton.layer.borderColor = UIColor.gray.cgColor
        voteButton.titleLabel?.textColor = .gray
        commentsButton.titleLabel?.textColor = .gray
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
        commentsButton.titleLabel?.text = validateCount(count: viewModel.data.numComments)
        voteButton.titleLabel?.text = validateCount(count: viewModel.data.score)
        if let urlString = viewModel.data.preview?.images.first?.source.url {
            if let url = URL(string: urlString) {
                downloadImage(from: url)
            }
        }
    }
}
