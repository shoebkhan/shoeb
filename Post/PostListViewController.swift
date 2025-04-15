//
//  PostListViewController.swift
//  TuDime
//
//  Created by IDS Logic on 18/10/23.
//  Copyright © 2023 ObjectSol. All rights reserved.
//
import SVProgressHUD
import Toast_Swift
import ObjectMapper
import UIKit
import XLPagerTabStrip
import Quickblox
import Refreshable

class PostListViewController: UIViewController,IndicatorInfoProvider, VideoPlayingCellProtocol {
    @IBOutlet weak var segmentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var segment: UISegmentedControl!
    var page = "0,20"
    var pageStart = 0
    var pageEnd = 20
    var isPlay = false
    var currentlyPlayingIndexPath : IndexPath? = nil
    let dateFormatter = DateFormatter()
    var postList:Array<PostList> = [PostList]()
    var bookmarkList:Array<PostList> = [PostList]()
    private var currentFetchPage: UInt = 1
    private var cancelFetch = false
    var fromMenu = false
    private let chatManager = ChatManager.instance
    var pageInfo : IndicatorInfo = ""
    var qbuserid :String = UserDefaults.standard.string(forKey: "user_id") ?? ""
    @IBOutlet weak private var tableView: UITableView!
    private var downloadedUsers : [QBUUser] = []
    var segmentSelecetd = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        fetchUsers()
        registerCell()
        segmentHeightConstraint.constant = 0
        segment.isHidden = true
        if fromMenu {
            self.title = "My Post".localized
            self.navigationController?.navigationBar.tintColor = UIColor.white
            segmentHeightConstraint.constant = 31
            segment.isHidden = false
        }
        // Do any additional setup after loading the view.
        tableView.addLoadMore(action: { [weak self] in
            self?.pageStart = self?.pageEnd ?? 0
            self?.pageEnd = (self?.pageStart ?? 0) + 20
            self?.page = "\(self?.pageStart ?? 0),\(self?.pageEnd ?? 0)"
            self?.getPostData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

                self?.tableView.stopLoadMore()
            }
        })
        getPostData()
        NotificationCenter.default
            .addObserver(self,
                         selector:#selector(updateSuccess(_:)),
                         name: NSNotification.Name ("updateApi"),                                           object: nil)
    }
    @objc func updateSuccess(_ notification: Notification) {
        //.... code process
        self.getPostData(from: 1)
    }
    private func registerCell() {
        tableView.register(cellClassOfNib: PostListCell.self)
        
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return pageInfo
    }
    override func viewWillAppear(_ animated: Bool) {

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
        let controller = CreatePostViewController(nibName: "CreatePostViewController", bundle: .main)
        let userImage = getImageUserById(value: Int(qbuserid)) ?? ""
        controller.userImage = userImage
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentSelecetd == 1 {
            return self.bookmarkList.count
        }
        return self.postList.count
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
        let cell = tableView.dequeueReusableCell(PostListCell.self, for: indexPath)
        let object = segmentSelecetd == 1 ? self.bookmarkList[indexPath.row] : self.postList[indexPath.row]
        let comment = object.title.decodeUrl()?.replacingOccurrences(of: "+", with: " ")
        cell.descriptionLabel.text = comment
        //qbuserid
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
                //delegate setting here which u missed
                cell.delegate = self
                //let the cell know its indexPath
                cell.indexPath = indexPath

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
        if userName == "" {
            userName = getUserNameById(value: Int(object.user))
        }
        cell.nameLabel.text = userName
        cell.likeLabel.text = object.likes
        cell.seenLabel.text = object.views
        cell.commentLabel.text = object.comments
        if let date = dateFormatter.date(from: object.wow_date ) {
            cell.dateLabel.text = date.getElapsedInterval()
        }
        cell.startButton.tag = indexPath.row
        cell.startButton.addTarget(self, action: #selector(playOrPauseVideo(button:)), for: .touchUpInside)
        cell.likeButton.addTarget(self, action: #selector(likeTapped(button:)), for: .touchUpInside)
        cell.blockButton.addTarget(self, action: #selector(blockTapped(button:)), for: .touchUpInside)

        cell.likeButton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row
        cell.profileButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: #selector(commentTapped(button:)), for: .touchUpInside)
        cell.profileButton.addTarget(self, action: #selector(profileTapped(button:)), for: .touchUpInside)
        
        cell.deleteButton.isHidden = true
        cell.blockButton.tag = indexPath.row
        if object.user == qbuserid {
            cell.deleteButton.isHidden = false
            cell.deleteButton.addTarget(self, action: #selector(deleteTapped(button:)), for: .touchUpInside)
            cell.blockButton.isHidden = true
        } else {
            cell.blockButton.addTarget(self, action: #selector(blockTapped(button:)), for: .touchUpInside)
            cell.blockButton.isHidden = false
        }
        if segmentSelecetd == 1 {
            cell.bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
        } else {
            if bookmarkList.contains(where: { name in name.wow_id == object.id }) {
                print("1 exists in the array")
                cell.bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
            } else {
                print("1 does not exists in the array")
                cell.bookmarkButton.setImage(UIImage(named: "bookmarkBlank"), for: .normal)
            }
            cell.bookmarkButton.addTarget(self, action: #selector(bookmarkTapped(button:)), for: .touchUpInside)

        }
        cell.forwardButton.addTarget(self, action: #selector(forwardTapped(button:)), for: .touchUpInside)
        cell.bookmarkButton.tag = indexPath.row
        cell.forwardButton.tag = indexPath.row
        cell.likeImageView.image = UIImage(named: "like")
        if let firstSuchElement = object.likeUsers.first(where: { $0.user == qbuserid }) {
            print(firstSuchElement) // 4
            cell.likeImageView.image = UIImage(named: "heart")
        }

        return cell
    }

    @objc func blockTapped(button: UIButton) {
        if let cell = tableView.cellForRow(at: IndexPath(row: button.tag, section: 0)) as? PostListCell {
            let popupVC = CheckListPopupView(nibName: "CheckListPopupView", bundle: nil)
            popupVC.modalPresentationStyle = .overFullScreen
            popupVC.modalTransitionStyle = .crossDissolve
            let object = segmentSelecetd == 1 ? self.bookmarkList[button.tag] : self.postList[button.tag]
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
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerPoint = view.convert(tableView.center, to: tableView)

        if let indexPath = tableView.indexPathForRow(at: centerPoint),
           indexPath != currentlyPlayingIndexPath {
            let object = segmentSelecetd == 1 ? self.bookmarkList[indexPath.row] : self.postList[indexPath.row]

            if ( url.fileName + object.wow_img).fileExtension() == "mp4" {
                if let videourl = NSURL(string: ( url.fileName + object.wow_img)) {

                    // Stop the currently playing cell
                    if let playingIndexPath = currentlyPlayingIndexPath,
                       let playingCell = tableView.cellForRow(at: playingIndexPath) as? PostListCell {
                        playingCell.startButton.setImage( UIImage(named:"playVideo.png"), for: .normal)
                        playingCell.playerController?.player?.pause()
                        playingCell.playerController?.player = nil
                        playVideoForCell(with: IndexPath(row: playingCell.startButton.tag, section: 0), shouldPlay: false )
                    }

                    // Start the video in the focused cell
                    if let cell = tableView.cellForRow(at: indexPath) as? PostListCell {
                        //cell.playVideo()
                        currentlyPlayingIndexPath = indexPath
                        playVideoForCell(with: IndexPath(row: cell.startButton.tag, section: 0), shouldPlay: true )
                        cell.startButton.setImage(UIImage(named: "pause"), for: .normal)
                    }

                }
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Stop the video if the scrolling stops and no cell is in the center
        if currentlyPlayingIndexPath == nil {
            if let playingIndexPath = currentlyPlayingIndexPath,
               let playingCell = tableView.cellForRow(at: playingIndexPath) as? PostListCell {
                let object = segmentSelecetd == 1 ? self.bookmarkList[currentlyPlayingIndexPath?.row ?? 0] : self.postList[currentlyPlayingIndexPath?.row ?? 0]

                if ( url.fileName + object.wow_img).fileExtension() == "mp4" {
                    if let videourl = NSURL(string: ( url.fileName + object.wow_img)) {
                        currentlyPlayingIndexPath = nil
                        playingCell.startButton.setImage( UIImage(named:"playVideo.png"), for: .normal)
                        playingCell.playerController?.player?.pause()
                        playingCell.playerController?.player = nil
                        playVideoForCell(with: IndexPath(row: playingCell.startButton.tag, section: 0), shouldPlay: false )
                    }
                }

            }
        }
    }
    @IBAction func segmentControllClick(_ sender: Any) {
        switch segment.selectedSegmentIndex {
        case 0:
            segmentSelecetd = 0
            self.title = "My Post".localized
            self.tableView.reloadData()
        case 1 :
            segmentSelecetd = 1
            self.title = "My Bookmark".localized
            self.tableView.reloadData()
        default:
            break
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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = (cell as? PostListCell) else { return };
        let visibleCells = tableView.visibleCells
        let minIndex = visibleCells.startIndex
        if tableView.visibleCells.firstIndex(of: cell) == minIndex {
//            if (videoCell.playerView.player != nil) {
////                videoCell.playerView.player?.play()
//            }

        }
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let videoCell = cell as? PostListCell else { return };
//        if (videoCell.playerView.player != nil) {
//            videoCell.playerView.player?.pause();
//            videoCell.playerView.player = nil;
//        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       // let object = self.postList[indexPath.row]
        let object = segmentSelecetd == 1 ? self.bookmarkList[indexPath.row] : self.postList[indexPath.row]
        if object.user == qbuserid {
            return true
        } else {
            return false
        }
    }
    func alertShow(id:String) {
        let dialogMessage = UIAlertController(title: "Confirm".localized, message: "Are you sure you want to delete this?".localized, preferredStyle: .alert)
        // Create OK button with action handler
        let ok = UIAlertAction(title: "Ok".localized, style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
            self.deleteAction(deleteId: id)
        })
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        //Add OK and Cancel button to an Alert object
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        // Present alert message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let object = segmentSelecetd == 1 ? self.bookmarkList[indexPath.row] : self.postList[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete".localized) { (action, sourceView, completionHandler) in
            print("index path of delete: \(indexPath)")
            self.deleteAction(deleteId: object.id)
            completionHandler(true)
        }

        let rename = UIContextualAction(style: .normal, title: "Edit".localized) { (action, sourceView, completionHandler) in
            print("index path of edit: \(indexPath)")
           // self.editID = object.id
            let controller = CreatePostViewController(nibName: "CreatePostViewController", bundle: .main)
            let userImage = self.getImageUserById(value: Int(self.qbuserid)) ?? ""
            controller.userImage = userImage
            controller.isEdit = true
            controller.postID = object.id
            controller.text = object.title
            self.navigationController?.pushViewController(controller, animated: true)
            completionHandler(true)
        }
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [rename, delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig

    }
    @objc func bookmarkTapped(button: UIButton) {
        //let object = self.postList[button.tag]
        let object = segmentSelecetd == 1 ? self.bookmarkList[button.tag] : self.postList[button.tag]
        if bookmarkList.contains(where: { name in name.wow_id == object.id }) {
            bookmarkDelete(bookmarkID: object.id)
        } else {
            bookmark(bookmarkID: object.id, wowImage: object.wow_img, title: object.title, opponenet_id: object.user)
        }

    }
    @objc func forwardTapped(button: UIButton) {
        let object = segmentSelecetd == 1 ? self.bookmarkList[button.tag] : self.postList[button.tag]
        guard let comment = object.title.decodeUrl()?.replacingOccurrences(of: "+", with: " ") else { return  }
        sendAttachment(url: ( url.fileName + object.wow_img), message: comment, urlImage: ( url.fileName + object.wow_img), urlLink: ( url.fileName + object.wow_img), senderId: UInt(object.user) ?? 0, wow: object.id)

    }
    @objc func profileTapped(button: UIButton) {
        let object = segmentSelecetd == 1 ? self.bookmarkList[button.tag] : self.postList[button.tag]
        if object.user != qbuserid {
            let vc = StoryBoardId.menu.instantiateViewController(withIdentifier: "ProfileViewVC") as! ProfileViewVC
            vc.userId = UInt(object.user)
            vc.isFromPost = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @objc func likeTapped(button: UIButton) {
        let object = segmentSelecetd == 1 ? self.bookmarkList[button.tag] : self.postList[button.tag]
        likeAction(likeId: object.id)
        
    }
    @objc func deleteTapped(button: UIButton) {
        let object = segmentSelecetd == 1 ? self.bookmarkList[button.tag] : self.postList[button.tag]
        alertShow(id: object.id)

        
    }
    @objc func commentTapped(button: UIButton) {
        let object = segmentSelecetd == 1 ? self.bookmarkList[button.tag] : self.postList[button.tag]
        let userImage = getImageUserById(value: Int(qbuserid)) ?? ""
        let controller = PostDetailViewController(nibName: "PostDetailViewController", bundle: .main)
        controller.userImage = userImage
        controller.userID = object.id
        controller.downloadedUsers = downloadedUsers
        controller.postQbuserID = object.user
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = segmentSelecetd == 1 ? self.bookmarkList[indexPath.row] : self.postList[indexPath.row]
        let userImage = getImageUserById(value: Int(qbuserid)) ?? ""
        let controller = PostDetailViewController(nibName: "PostDetailViewController", bundle: .main)
        controller.userImage = userImage
        controller.userID = object.id
        controller.downloadedUsers = downloadedUsers
        controller.postQbuserID = object.user
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension PostListViewController {
    
    func getPostData(from:Int? = 0) {
        if from == 0 {
            SVProgressHUD.show()

        } else {
            let array = self.page.components(separatedBy: ",")
            let string1 = array[safe:1]
            self.page = "\(0),\(string1 ?? "0") "
        }
        let params : [String : String] = ["user" : qbuserid, "page": page]
        print("Param--->",params)
        Just2.post(fromMenu ? url.getMyPost:  url.getPost, params: params){(r) in
            
            if !r.ok {
                DispatchQueue.main.async{ [self] in
                    self.view.makeToast(r.msg)
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
                        if from != 0 {
                            self.postList.removeAll()
                        }
                        self.postList.append(contentsOf: response!.data)
                        self.postList = self.filterItems(self.postList)
                        self.getBookmarkData()
                        self.tableView.reloadData()
                    } else {
                        self.postList.removeAll()
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
    func deleteAction(deleteId:String) {
        let params : [String : String] = ["user" : qbuserid, "wow_id" : deleteId]
        print("Param--->",params)
        Just2.post(url.deletePost, params: params){(r) in
            
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
                        self.getPostData(from: 1)
                        self.view.makeToast(response?.status)
                    }
                }
                
            }
        }
    }
    
    @objc private func fetchUsers() {
        SVProgressHUD.show()
        chatManager.fetchUsers(currentPage: currentFetchPage, perPage: CreateNewDialogConstant.perPage) { [weak self] response, users, cancel in
            if let responseError = response {
                self?.showAlertView(nil, message: responseError.error?.error?.localizedDescription)
                return
            }
            SVProgressHUD.dismiss()
            self?.cancelFetch = cancel
            if cancel == false {
                self?.currentFetchPage += 1
            }
            self?.downloadedUsers = users
            self?.tableView.reloadData()
        }
    }
    func bookmark(bookmarkID:String, wowImage:String, title:String, opponenet_id:String) {
        let params : [String : String] = ["user" : qbuserid, "wow_id" : bookmarkID, "wow_img" : wowImage, "title" : title, "opponent_id" : opponenet_id]
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
        //for image
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
            var name = String(format: "%@.png", randomString(length: 10))
            QBRequest.uploadFile(with: url, fileName: name, contentType: "image/png", isPublic: true, successBlock: { (response, uploadedBlob) in

                let attachment = QBChatAttachment()
                attachment.id = uploadedBlob.uid
                attachment.name = uploadedBlob.name
                //for image
                attachment.type = "image"
                attachment.url = uploadedBlob.publicUrl()
                let message = QBChatMessage.markable()
                message.text = messageText.base64Encoded()
                message.customParameters["save_to_history"] = true
                message.customParameters["emoji"] = true
                message.customParameters["TYPE"] = "STICKER"
                message.customParameters["url"] = urlImage
                message.customParameters["wow"] = wow
                message.customParameters["urlLink"] = urlLink
                let user = UInt(self.qbuserid) ?? 0
                message.senderID = user
                // message.dialogID = self.dialogID
                message.deliveredIDs = [(NSNumber(value: user))]
                message.readIDs = [(NSNumber(value: user))]
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

    func saveSelectedUserIDs(_ ids: [String]) {
        UserDefaults.standard.set(ids, forKey: "selectedUserIDs")
    }

    // Retrieve selected IDs from UserDefaults
    func getSelectedUserIDs() -> [String] {
        return UserDefaults.standard.array(forKey: "selectedUserIDs") as? [String] ?? []
    }
    func filterItems(_ items: [PostList]) -> [PostList] {
        let selectedIDs = getSelectedUserIDs()
        return items.filter { !selectedIDs.contains($0.user) }
    }
}

