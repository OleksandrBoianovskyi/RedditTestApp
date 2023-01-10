//
//  DownloadManager.swift
//  Test Project
//
//  Created by Oleksandr Boianovskyi on 10.01.2023.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class DownloadManager {
    
    // MARK: - Properties
    
    var pageViewModel: PageModel?
    var mainPageViewModel: MainPageViewModel?
    
    // MARK: - Init
    
    init(pageViewModel: PageModel?, mainPageViewModel: MainPageViewModel?) {
        self.pageViewModel = pageViewModel
        self.mainPageViewModel = mainPageViewModel
    }
    
    // MARK: - Business logic
    
    func parse(jsonData: Data) -> PageModel? {
        do {
            self.pageViewModel = try JSONDecoder().decode(PageModel.self,
                                                     from: jsonData)
            return pageViewModel
        } catch {
            print("Parse fail with error: \(error)")
        }
        return pageViewModel
    }
    
    func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            
            urlSession.resume()
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
