//
//  PostDetailViewController.swift
//  TuDime
//
//  Created by IDS Logic on 22/10/23.
//  Copyright © 2023 ObjectSol. All rights reserved.
//

import UIKit
import SVProgressHUD
import Toast_Swift
import ObjectMapper
import ImageViewer_swift

class PostDetailViewController: UIViewController, VideoPlayingCellProtocol {
    var fromChat = false
    var bookmarkList:Array<PostList> = [PostList]()
    var imagesUrl : [URL] = []
    var currentlyPlayingIndexPath : IndexPath? = IndexPath(item: 0, section: 0)
    var replyID = ""
    var isPlay = true
    var downloadedUsers : [QBUUser] = []
    let dateFormatter = DateFormatter()
    var qbuserid :String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    var postList:Array<PostList> = [PostList]()
    var postLike:Array<PostLike> = [PostLike]()
    var postComment:Array<PostComment> = [PostComment]()
    let textView = FlexibleTextView()
    @IBOutlet weak var tableView: DFTableView!
    var customInputView: UIView!
    @IBOutlet weak var replyView: UIView!
    var sendButton: UIButton!
    var avatarView: CircleImageViewPost!
    @IBOutlet weak var replyUsername: UILabel!
    override var canBecomeFirstResponder: Bool {
        return true
    }
    var editID = ""
    var isEdit = false
    var isEditReply = false
    var isLike = false
    var postText = ""
    var userImage = ""
    var userID = ""
    var postQbuserID = ""
    @IBOutlet weak var replyViewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var replyText: UILabel!
    override var inputAccessoryView: UIView? {
        if customInputView == nil {
            customInputView = DFInputBar()
            customInputView.backgroundColor = .systemBackground
            textView.placeholderText = "Add a comment".localized
            textView.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: UIFont(name: "HelveticaNeue", size: 14.0)!)
            customInputView.autoresizingMask = .flexibleHeight

            customInputView.addSubview(textView)

            textView.maxHeight = 160

            sendButton = UIButton()
            sendButton.isEnabled = true
            sendButton.setImage(UIImage(named: "ic_sendchat"), for: .normal)
            sendButton.addTarget(self, action: #selector(self.send), for: .touchUpInside)
           //sendButton.contentEdgeInsets = .init(top: 5, left: 45, bottom: 5, right: 16)
            customInputView.addSubview(sendButton)

            avatarView = CircleImageViewPost()
            customInputView.addSubview(avatarView)

            let separator = UIView()
            separator.backgroundColor = .separator
            customInputView.addSubview(separator)

            separator.anchor(top: customInputView.topAnchor, leading: customInputView.leadingAnchor, bottom: nil, trailing: customInputView.trailingAnchor, size: .init(width: 1, height: 1))

            avatarView.leadingAnchor.constraint(equalTo: customInputView.leadingAnchor, constant: 16).isActive = true
            avatarView.bottomAnchor.constraint(equalTo: customInputView.bottomAnchor, constant: -8).isActive = true
            avatarView.topAnchor.constraint(greaterThanOrEqualTo: customInputView.topAnchor, constant: 8).isActive = true
            avatarView.withWidth(40)
            avatarView.withHeight(40)
            avatarView.sd_setImage(with:  URL(string:userImage), placeholderImage: UIImage(named: "default_user_image"), options: [], context: nil)
            textView.anchor(top: customInputView.topAnchor, leading: avatarView.trailingAnchor, bottom: customInputView.bottomAnchor, trailing: sendButton.leadingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8))

//            sendButton.anchor(top: nil, leading: nil, bottom: customInputView.bottomAnchor, trailing: customInputView.trailingAnchor)
//            sendButton.topAnchor.constraint(greaterThanOrEqualTo: customInputView.topAnchor).isActive = true
//            sendButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
//
//            sendButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
//            sendButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            sendButton.frame = CGRect(x: UIScreen.main.bounds.size.width - 40, y: 13, width: 30, height: 30)

            avatarView.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
            avatarView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: NSLayoutConstraint.Axis.horizontal)
        }
        return customInputView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // Do any additional setup after loading the view.

        setupUI()
        let button = UIButton(type: .custom)
        //set image for button
        button.setImage(UIImage(named: "edit_icon"), for: .normal)
        //add function for button
        button.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        if postQbuserID == qbuserid {
            self.navigationItem.rightBarButtonItem = barButton
        }
        registerForKeyboardNotifications()
        hideKeyboardWhenTappedAround()
    }
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
          //  if self.view.frame.origin.y == 0 {
               // self.view.frame.origin.y -= keyboardSize.height
                replyViewBottonConstraint.constant = keyboardSize.height
          //  }
        }

    }

    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
        //    if self.view.frame.origin.y != 0 {
              //  self.view.frame.origin.y += keyboardSize.height
                replyViewBottonConstraint.constant = keyboardSize.height
           // }
        }
    }

    @IBAction func replyViewHide(_ sender: Any) {
        replyView.isHidden = true
        view.endEditing(true)
        self.textView.resignFirstResponder()

    }
    override func viewWillAppear(_ animated: Bool) {
        getPostData()
        if fromChat{
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if fromChat{
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
        if self.isMovingFromParent {
            // Your code...
            NotificationCenter.default
                .post(name:           NSNotification.Name("updateApi"),
                      object: nil,
                      userInfo: nil)
        }
    }
    @objc func editButtonPressed() {
        let controller = CreatePostViewController(nibName: "CreatePostViewController", bundle: .main)
        let userImage = getImageUserById(value: Int(qbuserid)) ?? ""
        controller.userImage = userImage
        controller.isEdit = true
        controller.postID = userID
        controller.text = self.postText
        self.navigationController?.pushViewController(controller, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {

        self.sendButton.isEnabled = true
        self.textView.isEditable = true
    }
    func setupUI() {
        // TableView
        tableView.setFreeCellSize()
        tableView.separatorStyle = .none
        tableView.register(cellClassOfNib: PostListCell.self)
        tableView.register(cellClassOfNib: DFCommentTableViewCell.self)
        tableView.register(cellClassOfNib: ReplyCommentTableViewCell.self)
        tableView.keyboardDismissMode = .interactive
        self.becomeFirstResponder()
        self.title = "Post".localized
        self.navigationController?.navigationBar.tintColor = UIColor.white

    }
    @IBAction func send() {
        if isEdit {
            self.sendEditCommentAction()
        } else if isEditReply {
            self.sendEditReplyCommentAction()
        } else {
            if !replyView.isHidden {
                sendReplyAction(commentID: replyID)
            } else {
                sendAction()
            }
        }

    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
extension PostDetailViewController {

    enum Sections: Int, CaseIterable {

        case userInfo
        case comments

        static var count: Int = allCases.count
    }

}


extension PostDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if postList.count > 0 {
            return self.postComment.count + 1
        }
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.postComment[section - 1].commentReply.count + 1
        }

    }
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbNailImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {

        case 0:
            let cell = tableView.dequeueReusableCell(PostListCell.self, for: indexPath)
            let object = self.postList[indexPath.row]
            let comment = object.title.decodeUrl()?.replacingOccurrences(of: "+", with: " ")
            cell.descriptionLabel.text = comment
            let userImage = getImageUserById(value: Int(object.user)) ?? ""
            cell.userImageView.sd_setImage(with:  URL(string: userImage), placeholderImage: UIImage(named: "default_user_image"), options: [], context: nil)
            cell.postImageView.isHidden = false
            cell.player.isHidden = true
            cell.postImageView.isHidden = true
            cell.playView.isHidden = true
            if ( url.fileName + object.wow_img).fileExtension() == "mp4" {
                if let videourl = NSURL(string: ( url.fileName + object.wow_img)) {
                    cell.player.isHidden = false
                    cell.playView.isHidden = false
                    print( url.fileName + object.wow_img)
                    //delegate setting here which u missed
                    cell.delegate = self
                    //let the cell know its indexPath
                    cell.indexPath = indexPath
                    cell.startButton.tag = indexPath.row
                    cell.startButton.addTarget(self, action: #selector(playOrPauseVideo(button:)), for: .touchUpInside)
                    cell.configCell(with: videourl as URL, shouldPlay: self.currentlyPlayingIndexPath == indexPath, currentPlay: isPlay)

                        //cell.postImageView.isHidden = true
                        self.getThumbnailImageFromVideoUrl(url: videourl as URL) { (thumbNailImage) in
                            cell.postImageView.image = thumbNailImage
                        }
                }
            } else {
                cell.postImageView.isHidden = false
                cell.postImageView.sd_setImage(with:  URL(string:( url.fileName + object.wow_img)), placeholderImage: UIImage(named: "picture"), options: [], context: nil)
            }
            var userName = object.QB_User[safe: 0]?.name
            if userName == "" || userName == nil {
                userName = getUserNameById(value: Int(object.user))
            }
            cell.nameLabel.text = userName
            cell.likeLabel.text = object.likes
            cell.seenLabel.text = object.views
            cell.commentLabel.text = object.comments
            if let date = dateFormatter.date(from: object.wow_date ) {
                cell.dateLabel.text = date.getElapsedInterval()
            }
            cell.likeButton.addTarget(self, action: #selector(likeTapped(button:)), for: .touchUpInside)
            cell.likeButton.tag = indexPath.row
            cell.commentButton.tag = indexPath.row
            if isLike {
                cell.likeImageView.image = UIImage(named: "heart")
            }
            cell.deleteButton.isHidden = true
            if object.user == qbuserid {
                cell.deleteButton.isHidden = false
                cell.deleteButton.addTarget(self, action: #selector(deleteTapped(button:)), for: .touchUpInside)
                cell.blockButton.isHidden = true

            } else {
                cell.blockButton.addTarget(self, action: #selector(blockTapped(button:)), for: .touchUpInside)
                cell.blockButton.isHidden = false
            }
            cell.blockButton.tag = indexPath.row
            cell.postImageView.setupImageViewer(
                urls:  self.imagesUrl,
                initialIndex: indexPath.item,
                options: [
                    .theme(.dark),
                    .rightNavItemTitle("", onTap: { i in
                        print("TAPPED", i)
                        self.view.endEditing(true)
                        self.textView.resignFirstResponder()
                    })
                ],
                from: self)
            if bookmarkList.contains(where: { name in name.wow_id == object.id }) {
                print("1 exists in the array")
                cell.bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
            } else {
                print("1 does not exists in the array")
                cell.bookmarkButton.setImage(UIImage(named: "bookmarkBlank"), for: .normal)
            }
            cell.bookmarkButton.addTarget(self, action: #selector(bookmarkTapped(button:)), for: .touchUpInside)
            cell.forwardButton.addTarget(self, action: #selector(forwardTapped(button:)), for: .touchUpInside)
            cell.forwardButton.tag = indexPath.row
            cell.bookmarkButton.tag = indexPath.row
            return cell

        default:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(DFCommentTableViewCell.self, for: indexPath)
                let object = self.postComment[indexPath.section - 1]
                let userImage = getImageUserById(value: Int(object.user)) ?? ""
                cell.avatarView.sd_setImage(with:  URL(string: userImage), placeholderImage: UIImage(named: "default_user_image"), options: [], context: nil)
                let userName = getUserNameById(value: Int(object.user)) ?? ""
                cell.nameLabel.text = userName
                if let date = dateFormatter.date(from: object.com_date ) {
                    cell.timeLabel.text = date.getElapsedInterval()
                }
                let comment = object.comment.decodeUrl()?.replacingOccurrences(of: "+", with: " ")
                cell.commentLabel.text = comment
                cell.replyButton.addTarget(self, action: #selector(replyTapped(button:)), for: .touchUpInside)
                cell.replyButton.tag = indexPath.section - 1
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(ReplyCommentTableViewCell.self, for: indexPath)
                let object = self.postComment[indexPath.section - 1].commentReply[indexPath.row - 1]
                let userImage = getImageUserById(value: Int(object.user_id)) ?? ""
                cell.avatarView.sd_setImage(with:  URL(string: userImage), placeholderImage: UIImage(named: "default_user_image"), options: [], context: nil)
                let userName = getUserNameById(value: Int(object.user_id)) ?? ""
                cell.nameLabel.text = userName
                if let date = dateFormatter.date(from: object.rep_date ) {
                    cell.timeLabel.text = date.getElapsedInterval()
                }
                let comment = object.reply.decodeUrl()?.replacingOccurrences(of: "+", with: " ")
                cell.commentLabel.text = comment

                return cell
            }

        }
    }
    @objc func blockTapped(button: UIButton) {
        if let cell = tableView.cellForRow(at: IndexPath(row: button.tag, section: 0)) as? PostListCell {
            let popupVC = CheckListPopupView(nibName: "CheckListPopupView", bundle: nil)
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.modalTransitionStyle = .crossDissolve
            let object = self.postList[button.tag]
            var userName = object.QB_User[safe: 0]?.name
            if userName == "" {
                userName = getUserNameById(value: Int(object.user))
            }
            popupVC.buttonHandler = { [self] isDissmiss in
                reportUser(message: isDissmiss.rawValue, name: userName ?? "", id: object.user)

            }
            self.present(popupVC, animated: false, completion: nil)
        }
    }
    func playVideoForCell(with indexPath: IndexPath, shouldPlay: Bool) {

        self.currentlyPlayingIndexPath = indexPath
        //reload tableView
        self.isPlay = shouldPlay
        self.tableView.reloadRows(at: self.tableView.indexPathsForVisibleRows!, with: .none)
    }
    @objc func playOrPauseVideo(button: UIButton) {
        if let cell = tableView.cellForRow(at: IndexPath(row: button.tag, section: 0)) as? PostListCell {
            // do stuff here
            if let btnImage = button.image(for: .normal),
               let Image = UIImage(named: "playVideo.png"), btnImage.pngData() == Image.pngData()
            {
                button.setImage(UIImage(named:"pause.png"), for: .normal)
                playVideoForCell(with: IndexPath(row: button.tag, section: 0), shouldPlay: true )
                button.setImage(UIImage(named: "pause"), for: .normal)
            }
            else
            {
                button.setImage( UIImage(named:"playVideo.png"), for: .normal)
                cell.playerController?.player?.pause()
                cell.playerController?.player = nil
                playVideoForCell(with: IndexPath(row: button.tag, section: 0), shouldPlay: false )
                return
            }

        }

    }
    @objc func replyTapped(button: UIButton) {
        let object = self.postComment[button.tag]
        let comment = object.comment.decodeUrl()?.replacingOccurrences(of: "+", with: " ")
        replyText.text = comment
        let userName = getUserNameById(value: Int(object.user)) ?? ""
        replyID = object.id
        replyUsername.text = userName
        replyView.isHidden = false
    }
    @objc func forwardTapped(button: UIButton) {
        let object = self.postList[button.tag]
        guard let comment = object.title.decodeUrl()?.replacingOccurrences(of: "+", with: " ") else { return  }
        sendAttachment(url: ( url.fileName + object.wow_img), message: comment, urlImage: ( url.fileName + object.wow_img), urlLink: ( url.fileName + object.wow_img), senderId: UInt(object.user) ?? 0, wow: object.id)

    }
    @objc func bookmarkTapped(button: UIButton) {
        let object = self.postList[button.tag]
        if bookmarkList.contains(where: { name in name.wow_id == object.id }) {
            bookmarkDelete(bookmarkID: object.id)
        } else {
            bookmark(bookmarkID: object.id, wowImage: object.wow_img, title: object.title, opponenet_id: object.user)
        }

    }
    @objc func deleteTapped(button: UIButton) {
        let object = self.postList[button.tag]
        deleteAction(deleteId: object.id)

    }
   func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       if indexPath.section == 0 {
           return false
       } else {
           if indexPath.row == 0 {
               let object = self.postComment[indexPath.section - 1]
               if object.user == qbuserid {
                   return true
               } else {
                   return false
               }
           } else {
               let object = self.postComment[indexPath.section - 1].commentReply[indexPath.row - 1]
               if object.user_id == qbuserid {
                   return true
               } else {
                   return false
               }
           }
       }
//        guard let section = Sections(rawValue: indexPath.section) else {
//            fatalError()
//        }
//
//
//        switch section {
//
//        case .userInfo:
//            return false
//        case .comments:
//            let object = self.postComment[indexPath.row]
//            if object.user == qbuserid {
//                return true
//            } else {
//                return false
//            }
//        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if indexPath.row == 0 {
            let object = self.postComment[indexPath.section - 1]
            let delete = UIContextualAction(style: .destructive, title: "Delete".localized) { (action, sourceView, completionHandler) in
                print("index path of delete: \(indexPath)")
                self.deleteCommentAction(deleteId: object.id)
                completionHandler(true)
            }

            let rename = UIContextualAction(style: .normal, title: "Edit".localized) { (action, sourceView, completionHandler) in
                print("index path of edit: \(indexPath)")
                self.isEdit = true
                self.editID = object.id
                self.textView.text = object.comment
                self.textView.becomeFirstResponder()

                completionHandler(true)
            }
            let swipeActionConfig = UISwipeActionsConfiguration(actions: [rename, delete])
            swipeActionConfig.performsFirstActionWithFullSwipe = false
            return swipeActionConfig
        } else {
            let object = self.postComment[indexPath.section - 1].commentReply[indexPath.row - 1]
            let delete = UIContextualAction(style: .destructive, title: "Delete".localized) { (action, sourceView, completionHandler) in
                print("index path of delete: \(indexPath)")
                self.replyDelete(replyID: object.id)
                completionHandler(true)
            }

            let rename = UIContextualAction(style: .normal, title: "Edit".localized) { (action, sourceView, completionHandler) in
                print("index path of edit: \(indexPath)")
                self.isEditReply = true
                self.editID = object.id
                self.textView.text = object.reply
                self.textView.becomeFirstResponder()

                completionHandler(true)
            }
            let swipeActionConfig = UISwipeActionsConfiguration(actions: [rename, delete])
            swipeActionConfig.performsFirstActionWithFullSwipe = false
            return swipeActionConfig

        }



    }
    @objc func likeTapped(button: UIButton) {
        let object = self.postList[button.tag]
        likeAction(likeId: object.id)

    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Sections(rawValue: section) else { return nil }

        //        if section == .comments {
        //            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: LabelTableHeader.identifier) as! LabelTableHeader
        //            header.whiteView.backgroundColor = UIColor(named: "lightSystemDarkSecondBackground")
        //            header.titleLabel.text = String(format: "Comments (%d)", viewModel.post.comments)
        //            return header
        //        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //        guard let section = Sections(rawValue: section) else { return 0 }
        //        if section == .comments {
        //            return 52
        //        }
        return 0
    }
}

extension PostDetailViewController {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        if scrollView === tableView {
        //            hideShowGradientLayer(scrollView.contentOffset.y <= 0)
        //        }
    }
}
extension PostDetailViewController {

    func getPostData(from:Int? = 0) {
        let params : [String : String] = ["wow_id" : userID]
        print("Param--->",params)
        if from == 0 {
            SVProgressHUD.show()
        }

        Just2.post(url.getPostDetail, params: params){(r) in

            if !r.ok {
                self.view.makeToast(r.msg)
                SVProgressHUD.dismiss()
                return
            }

            if r.ok{
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    SVProgressHUD.dismiss()
                    if !response!.dataMain.isEmpty {

                        self.postList = response!.dataMain
                        self.postLike = response!.dataLike
                        self.postComment = response!.dataComment
                        if let firstSuchElement = self.postLike.first(where: { $0.user == qbuserid }) {
                            print(firstSuchElement) // 4
                            isLike = true
                            // ...
                        }
                        if self.postList.count > 0 && self.imagesUrl.count == 0 {
                            let object = self.postList[0]
                            self.imagesUrl.append(URL(string:( url.fileName + object.wow_img))! )
                            self.postText = object.title
                        }
                        if self.postList.count > 0 {
                            let object = self.postList[0]
                            self.postText = object.title
                        }
                        self.getBookmarkData()
                        self.tableView.reloadData()
                    }
                }

            }
        }
    }
    func likeAction(likeId:String) {
        let params : [String : String] = ["user" : qbuserid, "wow_id" : likeId]
        print("Param--->",params)
        Just2.post(url.likePost, params: params){(r) in

            if !r.ok {
                self.view.makeToast(r.msg)
                SVProgressHUD.dismiss()
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    if response?.success_message == "Insert successfull." {
                        self.getPostData(from: 1)
                        self.view.makeToast(response?.success_message)
                    }
                }

            }
        }
    }
    private func getImageUserById(value: Int?) -> String?  {
        guard let index = (self.downloadedUsers.firstIndex { $0.id == value ?? 0 }) else { return "" }
        let userImage = self.downloadedUsers[index].website
        return userImage
    }
    private func getUserNameById(value: Int?) -> String?  {
        guard let index = (self.downloadedUsers.firstIndex { $0.id == value ?? 0 }) else { return "" }
        let userName = self.downloadedUsers[index].fullName ?? ""
        return userName
    }
    func sendAction() {
        guard let text = textView.text?.trimString(), text.isNotEmpty else {
            textView.becomeFirstResponder()
            return
        }

        textView.isEditable = false
        sendButton.isEnabled = false
        let params : [String : String] = ["user" : qbuserid, "wow_id" : userID, "wow_comment" : text]
        print("Param--->",params)
        Just2.post(url.commentPost, params: params){(r) in

            if !r.ok {
                self.view.makeToast(r.msg)
                SVProgressHUD.dismiss()
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    if response?.success_message == "Insert successfull." {
                        self.textView.text = ""
                        self.textView.isEditable = true
                        self.sendButton.isEnabled = true
                        self.getPostData(from: 1)
                    }
                }

            }
        }
    }
    func deleteCommentAction(deleteId:String) {
        let params : [String : String] = [ "wow_id" : deleteId]
        print("Param--->",params)
        Just2.post(url.deleteComment, params: params){(r) in

            if !r.ok {
                self.view.makeToast(r.msg)
                SVProgressHUD.dismiss()
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    if response?.status == "success" {
                        self.getPostData(from: 1)
                        self.view.makeToast(response?.success_message)
                    }
                }

            }
        }
    }
    func deleteAction(deleteId:String) {
        let params : [String : String] = ["user" : qbuserid, "wow_id" : deleteId]
        print("Param--->",params)
        Just2.post(url.deletePost, params: params){(r) in

            if !r.ok {
                self.view.makeToast(r.msg)
                SVProgressHUD.dismiss()
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    if response?.status == "success" {
                        self.navigationController?.popViewController(animated: true)
                        NotificationCenter.default
                            .post(name:           NSNotification.Name("updateApi"),
                                  object: nil,
                                  userInfo: nil)
                        self.view.makeToast(response?.status)
                    }
                }

            }
        }
    }

    func sendEditCommentAction() {
        guard let text = textView.text?.trimString(), text.isNotEmpty else {
            textView.becomeFirstResponder()
            self.isEdit = false
            self.editID = ""
            return
        }

        textView.isEditable = false
        sendButton.isEnabled = false
        let params : [String : String] = ["wow_id" : editID, "title" : text, "User" : qbuserid]
        print("Param--->",params)
        Just2.post(url.editComment, params: params){(r) in

            if !r.ok {
                self.view.makeToast(r.msg)
                SVProgressHUD.dismiss()
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    if response?.status == "success" {
                        self.textView.text = ""
                        self.textView.isEditable = true
                        self.sendButton.isEnabled = true
                        self.isEdit = false
                        self.editID = ""
                        self.getPostData(from: 1)
                    }
                }

            }
        }
    }
    func sendEditReplyCommentAction() {
        guard let text = textView.text?.trimString(), text.isNotEmpty else {
            textView.becomeFirstResponder()
            self.isEditReply = false
            self.editID = ""
            return
        }

        textView.isEditable = false
        sendButton.isEnabled = false
        let params : [String : String] = ["wow_id" : editID, "title" : text, "User" : qbuserid]
        print("Param--->",params)
        Just2.post(url.editReply, params: params){(r) in

            if !r.ok {
                self.view.makeToast(r.msg)
                SVProgressHUD.dismiss()
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    if response?.status == "success" {
                        self.textView.text = ""
                        self.textView.isEditable = true
                        self.sendButton.isEnabled = true
                        self.isEditReply = false
                        self.editID = ""
                        self.getPostData(from: 1)
                    }
                }

            }
        }
    }

    func bookmark(bookmarkID:String, wowImage:String, title:String, opponenet_id:String) {
        let params : [String : String] = ["user" : qbuserid, "wow_id" : bookmarkID, "wow_img" : wowImage, "title" : title, "opponenet_id" : opponenet_id]
        print("Param--->",params)
        Just2.post(url.bookmark, params: params){(r) in

            if !r.ok {
                DispatchQueue.main.async{ [self] in
                    self.view.makeToast(r.msg)
                    SVProgressHUD.dismiss()
                }
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in

                    self.getBookmarkData()
                    self.view.makeToast(response?.success_message)
                }

            }
        }
    }
    func getBookmarkData() {

        let params : [String : String] = ["user" : qbuserid]
        print("Param--->",params)

        Just2.post(url.getBookmark, params: params){(r) in

            if !r.ok {
                DispatchQueue.main.async{ [self] in
                    self.view.makeToast(r.msg)
                    self.bookmarkList.removeAll()
                    SVProgressHUD.dismiss()
                }
                return
            }

            if r.ok{
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    SVProgressHUD.dismiss()
                    if !response!.data.isEmpty {

                        self.bookmarkList = response!.data
                        self.tableView.reloadData()
                    } else {
                        self.bookmarkList.removeAll()
                        self.tableView.reloadData()
                    }
                }

            }
        }
    }
    func bookmarkDelete(bookmarkID:String) {
        let params : [String : String] = ["user" : qbuserid, "wow_id" : bookmarkID]
        print("Param--->",params)
        Just2.post(url.deleteBookmark, params: params){(r) in

            if !r.ok {
                DispatchQueue.main.async{ [self] in
                    self.view.makeToast(r.msg)
                    SVProgressHUD.dismiss()
                }
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in

                    self.getBookmarkData()
                    self.view.makeToast(response?.success_message)
                }

            }
        }
    }

    func sendReplyAction(commentID:String) {
        guard let text = textView.text?.trimString(), text.isNotEmpty else {
            textView.becomeFirstResponder()
            return
        }

        textView.isEditable = false
        sendButton.isEnabled = false
        let params : [String : String] = ["user" : qbuserid, "comment_id" : commentID, "reply" : text]
        print("Param--->",params)
        Just2.post(url.reply, params: params){(r) in

            if !r.ok {
                self.view.makeToast(r.msg)
                SVProgressHUD.dismiss()
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    if response?.success_message == "Insert successfull." {
                        self.textView.text = ""
                        self.textView.isEditable = true
                        self.sendButton.isEnabled = true
                        self.getPostData(from: 1)
                        self.replyID = ""
                        self.replyView.isHidden = true
                    }
                }

            }
        }
    }
    func replyDelete(replyID:String) {
        let params : [String : String] = ["user" : qbuserid, "wow_id" : replyID]
        print("Param--->",params)
        Just2.post(url.deleteReply, params: params){(r) in

            if !r.ok {
                DispatchQueue.main.async{ [self] in
                    self.view.makeToast(r.msg)
                    SVProgressHUD.dismiss()
                }
                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in

                    self.getPostData(from: 1)
                    self.view.makeToast(response?.success_message)
                }

            }
        }
    }
    func sendAttachment(url:String, message:String,urlImage:String, urlLink:String, senderId:UInt, wow:String) {
        SVProgressHUD.show()
        let url = URL(string: url)
        FileDownloader.loadFileAsync(url: url!) { (path, error) in
            print("PDF File downloaded to : \(path!)")
            self.fileUpload(url: path ?? "", messageText: message, urlImage: urlImage, urlLink: urlLink, senderId: senderId, wow: wow)
        }

    }
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    func fileUpload(url:String, messageText:String,urlImage:String, urlLink:String, senderId:UInt, wow:String) {
        let url = URL(fileURLWithPath:url)
        if  urlLink.fileExtension() == "mp4" {
            var name = String(format: "%@.mp4", randomString(length: 10))

            DispatchQueue.main.async(execute: {

                QBRequest.uploadFile(with: url, fileName: name, contentType: "video/mp4", isPublic: true,
                                     successBlock: { [weak self] (response: QBResponse, uploadedBlob: QBCBlob) -> Void in
                    guard let self = self else {
                        return
                    }
                    let attachment = QBChatAttachment()
                    attachment.id = uploadedBlob.uid
                    attachment.name = uploadedBlob.name
                    attachment.type = "video"
                    attachment["size"] = "\(uploadedBlob.size)"

                    let message = QBChatMessage.markable()
                    message.text = messageText.base64Encoded()
                    message.customParameters["save_to_history"] = true
                    message.customParameters["emoji"] = true
                    message.customParameters["TYPE"] = "STICKER"
                    message.customParameters["url"] = urlImage
                    message.customParameters["wow"] = wow
                    message.customParameters["urlLink"] = urlLink
                    var user = UInt(self.qbuserid) ?? 0
                    message.senderID = user
                    // message.dialogID = self.dialogID
                    message.deliveredIDs = [(NSNumber(value: user))]
                    message.readIDs = [(NSNumber(value: user))]
                    message.dateSent = Date()
                    //Set attachment
                    message.attachments = [attachment]
                    self.forwardMessage(chat: message)

                }, statusBlock: { [weak self] (request : QBRequest?, status : QBRequestStatus?) -> Void in
                    if let status = status {

                    }
                }) { [weak self] (response : QBResponse) -> Void in
                    guard let self = self else {
                        return
                    }
                }
            })

        } else {
            //for image
            var name = String(format: "%@.png", randomString(length: 10))
            QBRequest.uploadFile(with: url, fileName: name, contentType: "image/png", isPublic: true, successBlock: { (response, uploadedBlob) in
                
                let attachment = QBChatAttachment()
                attachment.id = uploadedBlob.uid
                attachment.name = uploadedBlob.name
                //for image
                attachment.type = "image"
                attachment.url = uploadedBlob.publicUrl()
                let decodedTextValue = messageText.base64Decoded()
                let message = QBChatMessage.markable()
                message.text = messageText.base64Encoded()
                message.customParameters["save_to_history"] = true
                message.customParameters["emoji"] = true
                message.customParameters["TYPE"] = "STICKER"
                message.customParameters["url"] = urlImage
                message.customParameters["urlLink"] = urlLink
                message.customParameters["wow"] = wow
                message.senderID = senderId
                // message.dialogID = self.dialogID
                message.deliveredIDs = [(NSNumber(value: senderId))]
                message.readIDs = [(NSNumber(value: senderId))]
                message.dateSent = Date()
                //Set attachment
                message.attachments = [attachment]
                self.forwardMessage(chat: message)
                
                
            }, statusBlock: { (request, status)  in
                //Update UI with upload progress
            }, errorBlock: { (response) in
                //show upload error
            })
        }
    }

    private func forwardMessage(chat:QBChatMessage) {
        SVProgressHUD.dismiss()
        let storyboard = UIStoryboard(name: "Dialogs", bundle: nil)
        if let dialogsSelection = storyboard.instantiateViewController(withIdentifier: "DialogsSelectionVC") as? DialogsSelectionVC {
            dialogsSelection.action = ChatActions.Forward
            dialogsSelection.message = chat

            let navVC = UINavigationController(rootViewController: dialogsSelection)
            navVC.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
            navVC.navigationBar.barStyle = .black
            navVC.navigationBar.shadowImage = UIImage(named: "navbar-shadow")
            navVC.navigationBar.isTranslucent = false
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: false)
        }
    }
    func reportUser(message:String, name:String, id:String) {
        var urlvalue = String(format: "%@&useid=%@&message=%@&name=%@", url.report,qbuserid, message, name)
        urlvalue = urlvalue.replacingOccurrences(of: " ", with: "%20")

        print("Param--->",urlvalue)

        Just2.get(urlvalue){(r) in
            if !r.ok {
                DispatchQueue.main.async{ [self] in
                    self.view.makeToast(r.msg)
                    SVProgressHUD.dismiss()
                }

                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<Post>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async{ [self] in
                    if response?.status == "success" {
                        var selectedUserIDs = self.getSelectedUserIDs()
                        selectedUserIDs.append(id)
                        saveSelectedUserIDs(selectedUserIDs)
                        self.getPostData(from: 1)
                        self.view.makeToast(response?.status)
                    }
                }

            }
        }
    }
    func saveSelectedUserIDs(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: "selectedUserIDs")
    }

    // Retrieve selected IDs from UserDefaults
    func getSelectedUserIDs() -> [String] {
        return UserDefaults.standard.array(forKey: "selectedUserIDs") as? [String] ?? []
    }
}
