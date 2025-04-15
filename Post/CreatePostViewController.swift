//
//  CreatePostViewController.swift
//  TuDime
//
//  Created by IDS Logic on 22/10/23.
//  Copyright © 2023 ObjectSol. All rights reserved.
//
import SVProgressHUD
import Toast_Swift
import UIKit
import Just
import Alamofire
import Photos
import AVKit
import Foundation

class CreatePostViewController: UIViewController {
    var isImage = false
    var AudioURl: URL!
    var videoData: Data!
    @IBOutlet weak var postView: UIView!
    var qbuserid :String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var postImageView: CircleImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var userImageView: CircleImageView!
    var userImage = ""
    var postImage : UIImage!
    var uploadImage : UIImage!
    var isEdit = false
    var postID = ""
    var text = ""
    private lazy var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        return pickerController
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Post".localized
        self.navigationController?.navigationBar.tintColor = UIColor.white
        userImageView.sd_setImage(with:  URL(string:userImage), placeholderImage: UIImage(named: "default_user_image"), options: [], context: nil)
        textView.backgroundColor = .clear
        postImageView.layer.borderWidth = 1
        postImageView.layer.borderColor = UIColor.lightGray.cgColor
        // Do any additional setup after loading the view.
        if isEdit {
            submitButton.setTitle("Edit Post".localized, for: .normal)
            postView.isHidden = true
            textView.text = text
        }
    }

    @IBAction func selectpostImage(_ sender: Any) {
        let alert = UIAlertController(title: "Choose photo from...".localized, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { _ in
            self.openCamera(false)
        }))
        alert.addAction(UIAlertAction(title: "Gallery".localized, style: .default, handler: { _ in
            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera(_ video:Bool)
    {

        if UIImagePickerController.isSourceTypeAvailable(.camera) {

            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.videoMaximumDuration = TimeInterval(60.0)
            imagePicker.mediaTypes =  ["public.image", "public.movie"]
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning".localized, message: "You don't have camera".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func openGallary() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes =  ["public.image", "public.movie"]
        self.present(imagePicker, animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

    @IBAction func createPost(_ sender: Any) {
        updatePost()
    }
}
extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        

        let info1 = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let videoURL = info1[UIImagePickerController.InfoKey.mediaURL.rawValue] as? URL {
            isImage = false
            AudioURl = videoURL
            DispatchQueue.main.async {
                do {

                    let asset = AVURLAsset(url: videoURL, options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    self.postImageView.image = thumbnail

                } catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
                    picker.dismiss(animated: true, completion: nil)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }

        if let image = info1[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            isImage = true
            postImageView.image = image
            postImage = image
        }
    }

    // Helper function.
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})}

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension CreatePostViewController {
    func updatePost() {
        SVProgressHUD.show()
        let randomInt = Int.random(in: 100000..<999999)
        DispatchQueue.main.async {

            guard let textValue = self.textView.text?.trimString(), textValue.isNotEmpty else {
                self.textView.becomeFirstResponder()
                self.view.makeToast("Please add text".localized)
                SVProgressHUD.dismiss()
                return
            }
            if !self.isEdit {
                if self.isImage {
                    guard let image = self.postImage else {
                        self.view.makeToast("\(Credentials.imageNotAvailable)")
                        SVProgressHUD.dismiss()
                        return
                    }
                    self.uploadImage = image
                } else {
                    guard let imgData = try? Data(contentsOf: self.AudioURl) else {
                        print("There was an error!")
                        // return or break
                        return
                    }

                    self.videoData = imgData
                }
            }
            let headers: HTTPHeaders = [
                "Content-type": "multipart/form-data"
            ]

            AF.upload(
                multipartFormData: { multipartFormData in

                    if self.isEdit {
                        multipartFormData.append(self.postID.data(using: .utf8)!, withName: "wow_id")

                    } else {
                        if self.isImage {
                            multipartFormData.append(self.uploadImage.jpegData(compressionQuality: 0.8)!, withName: "wow_image" , fileName: "wow_image\(randomInt).jpeg", mimeType: "image/jpeg")

                        } else {
                            let currentFileName = String(format: "%d.mp4" ,randomInt)
                            multipartFormData.append(self.videoData, withName: "wow_image", fileName: currentFileName, mimeType: "video/mp4")
                        }

                    }

                    multipartFormData.append(textValue.data(using: .utf8)!, withName: "title")
                    multipartFormData.append(self.qbuserid.data(using: .utf8)!, withName: "user")
                },
                to: self.isEdit ? url.editPost : url.createPost, method: .post , headers: headers)

            .response { response in
                print(response.result)
                let str = "{\"names\": [\"Bob\", \"Tim\", \"Tina\"]}"
                let data = Data(str.utf8)
                do
                {
                    SVProgressHUD.dismiss()
                    if let json = try JSONSerialization.jsonObject(with: response.data ?? data, options: []) as? [NSString: Any] {
                        // try to read out a string array
                        print(json)
                        if let msg = json["success_message"] as? String {
                            print(msg)
                            self.view.makeToast(msg)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }  else if let msg = json["success"] as? String {
                            print(msg)
                            self.view.makeToast(msg)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else if let msg = json["status"] as? String {
                            if msg == "success" {
                                print(msg)
                                self.view.makeToast(msg)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }

                        }
                    }
                }
                catch let error as NSError {
                    SVProgressHUD.dismiss()
                    print("Failed to load: \(error.localizedDescription)")
                }

            }

        }
    }
}
