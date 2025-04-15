//
//  ShareViewController.swift
//  TuDimeShareExtension
//
//  Created by Vikas Sharma on 15/11/22.
//  Copyright © 2022 ObjectSol. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Kingfisher
import SwiftLinkPreview

class ShareViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView?

    //MARK: - Variables
    let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: DispatchQueue.main, cache: DisabledCache.instance)
    var imagesToShare = [UIImage]()

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleSharedFile()
    }

    //MARK: - Helper Methods
    private func handleSharedFile() {
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if (provider as AnyObject).hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var weakImageView = self.imageView
                    (provider as AnyObject).loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (imageURL, error) in
                        OperationQueue.main.addOperation {
                            if let strongImageView = weakImageView {
                                if let imageURL = imageURL as? URL {
                                    if let image = UIImage(data: try! Data(contentsOf: imageURL)) {
                                        strongImageView.image = image
                                        self.imagesToShare.append(image)
                                    }
                                } else if let image = imageURL as? UIImage {
                                    strongImageView.image = image
                                    self.imagesToShare.append(image)
                                } else if let imageData = imageURL as? Data, let image = UIImage(data: imageData) {
                                    strongImageView.image = image
                                    self.imagesToShare.append(image)
                                }
                            }
                        }
                    })

                    imageFound = true
                    break
                } else if (provider as AnyObject).hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                    (provider as AnyObject).loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (item, error) in
                        if error == nil {
                            if let url = item as? URL {
                                DispatchQueue.main.async {
                                    self.getImageFromURL(url)
                                }
                            }
                        }
                    }
                }
            }

            if (imageFound) {
                break
            }
        }
    }

    func getImageFromURL(_ url: URL) {

        let processor = DownsamplingImageProcessor(size: imageView?.bounds.size ?? CGSize(width: 200, height: 200))
        |> RoundCornerImageProcessor(cornerRadius: 20)
        imageView?.kf.indicatorType = .activity
        imageView?.kf.setImage(
            with: url,
            placeholder: UIImage(named: "tudime"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
                if let image = self.imageView?.image {
                    self.imagesToShare.append(image)
                }
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }

//        imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        imageView?.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
//            if error == nil {
//                self.imageView?.image = image
////                self.createMediaInfo(image: image!, imageURL: imageURL!)
//            } else {
//                self.imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                let preview = self.slp.preview(url.absoluteString) { (response) in
//                    if let imagePath = response.image {
//                        self.imageView?.sd_setImage(with: URL(string: imagePath), placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
//                            if error == nil, let image = image {
//                                self.imageView?.image = image
//                                self.imagesToShare.append(image)
////                                self.createMediaInfo(image: image!, imageURL: imageURL!)
//                            } else {
//                                if let iconPath = response.icon {
//                                    self.imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                                    self.imageView?.sd_setImage(with: URL(string: iconPath), placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), completed: { image, error, cacheType, imageURL in
//                                        if error == nil, let image = image {
//                                            self.imageView?.image = image
//                                            self.imagesToShare.append(image)
////                                            self.createMediaInfo(image: image!, imageURL: imageURL!)
//                                        }
//                                    })
//                                }
//                            }
//                        })
//                    }
//                } onError: { (error) in
//
//                }
//            }
//        })
    }

    // MARK: - Button Action Methods
    @IBAction func actionButtonClose(_ sender: UIButton) {
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}
