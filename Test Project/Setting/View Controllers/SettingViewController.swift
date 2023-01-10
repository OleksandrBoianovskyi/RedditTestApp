//
//  SettingViewController.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 04.01.2023.
//

import UIKit
import SafariServices

class SettingViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var copyTextButton: UIButton!
    @IBOutlet weak var blockAccountButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var openInWebButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel: MainPageViewModel?
    var image: UIImage?
    let factory = ButtonsActionFactory.defaultFactory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
    }
    
    // MARK: - SetupUI
    
    private func setupButtons() {
        shareButton.contentHorizontalAlignment = .left
        copyTextButton.contentHorizontalAlignment = .left
        blockAccountButton.contentHorizontalAlignment = .left
        hideButton.contentHorizontalAlignment = .left
        openInWebButton.contentHorizontalAlignment = .left
        closeButton.layer.cornerRadius = 17.0
    }
    
    // MARK: - IBActions

    @IBAction func tapOnShareButton(_ sender: Any) {
        if let viewModel = viewModel {
            factory.createShareButtonAction(with: viewModel, delegate: nil, sender: sender, self)
        }
    }
    
    @IBAction func tapONCopyTextButton(_ sender: Any) {
        let textToCopy = viewModel?.data.title
        UIPasteboard.general.string = textToCopy
        self.dismiss(animated: true)
    }
    
    @IBAction func tapOnHideButton(_ sender: Any) {
        // TODO: need DB
    }
    
    @IBAction func tapOnBlockAcButton(_ sender: Any) {
        // TODO: need DB
    }
    
    @IBAction func tapOnOpenInBrowsButton(_ sender: Any) {
        guard let urlString = viewModel?.data.url,
              let url: URL = URL(string: urlString) else { return }
        
        let safari: SFSafariViewController = SFSafariViewController(url: url)
        self.present(safari, animated: true)
        // TODO: fix bug with sheet height
//        self.dismiss(animated: true)
    }

    @IBAction func closeSettingView(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
