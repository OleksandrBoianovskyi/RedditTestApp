//
//  SettingViewController.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 04.01.2023.
//

import UIKit
import SafariServices

class SettingViewController: UIViewController {

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var copyTextButton: UIButton!
    @IBOutlet weak var blockAccountButton: UIButton!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var openInWebButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel: MainPageViewModel?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
    }
    
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
        let firstActivityItem = "Description you want.."
        
        guard let url = viewModel?.data.url else { return }
        let secondActivityItem : NSURL = NSURL(string: url)!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
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
