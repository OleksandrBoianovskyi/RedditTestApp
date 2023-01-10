//
//  ButtonsActionFactory.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 09.01.2023.
//

import Foundation
import UIKit

enum ButtonsAction {
    case upVote, downVote, score
}

class ButtonsActionFactory {
    
    public static let defaultFactory = ButtonsActionFactory()
    
    func createButtonAction(with type: ButtonsAction, upVoteButton: UIButton, downVoteButton: UIButton, scoreButton: UIButton) {
        switch type {
        case .upVote:
            upVoteButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            upVoteButton.tintColor = .orange
            scoreButton.setTitleColor(.orange, for: .normal)
            downVoteButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            downVoteButton.tintColor = .darkGray
        case .downVote:
            downVoteButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
            downVoteButton.tintColor = .purple
            scoreButton.setTitleColor(.purple, for: .normal)
            upVoteButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            upVoteButton.tintColor = .darkGray
        case .score:
            upVoteButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            upVoteButton.tintColor = .darkGray
            downVoteButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            downVoteButton.tintColor = .darkGray
            scoreButton.setTitleColor(.gray, for: .normal)
        }
    }
    
    func createShareButtonAction(with viewModel: MainPageViewModel, delegate: VideoDeledate?, sender: Any,_ viewController: UIViewController?) {
        let firstActivityItem = "Description you want.."
        
        let url = viewModel.data.url
        let secondActivityItem: NSURL = NSURL(string: url)!
        
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
        delegate?.presentViewController(activityViewController, animated: true)
        viewController?.present(activityViewController, animated: true)
    }
    
    func createSettingButtonAction(with viewModel: MainPageViewModel, delegate: VideoDeledate?) {
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
        
        delegate?.presentViewController(navController, animated: true)
    }
}
