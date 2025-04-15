//
//  EditOrderItemCell.swift
//  UrCupCafe
//
//  Created by Rajshree Jaiswal on 17/08/22.
//

import AVKit
import AVFoundation
protocol VideoPlayingCellProtocol : NSObjectProtocol {
    func playVideoForCell(with indexPath : IndexPath, shouldPlay : Bool)
}
class PostListCell: UITableViewCell {
    @IBOutlet weak var playViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var likeImageView: UIImageView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var seenLabel: UILabel!
    @IBOutlet var profileButton: UIButton!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var likeLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    @IBOutlet var player: UIView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var blockButton: UIButton!
    @IBOutlet var playView: UIView!
    var playerController : AVPlayerViewController?
    var passedURL : URL! = nil
    var indexPath : IndexPath! = nil
    var delegate : VideoPlayingCellProtocol? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        playerController = AVPlayerViewController()

        //3. Adding subview
        self.player.addSubview(playerController!.view)
        //4. Custom frame set
        playerController?.view.frame = CGRectMake(0, 0, player.frame.width, player.frame.height)

        playViewTopConstraint.constant = (UIScreen.main.bounds.width/2) + 40
        // Initialization code
    }
    func configCell(with url : URL,shouldPlay : Bool, currentPlay:Bool) {
        //something like this
        self.passedURL = url
        if shouldPlay && currentPlay {
            let player = AVPlayer(url: url)
            if self.playerController == nil {
                playerController = AVPlayerViewController()
            }
            self.startButton.setImage(UIImage(named: "pause"), for: .normal)
            playerController?.player = player
            playerController?.showsPlaybackControls = true
            playerController?.player?.play()
            postImageView.isHidden = true
        }
        else {
            if self.playerController != nil {
                self.playerController?.player?.pause()
                self.playerController?.player = nil
                self.startButton.setImage(UIImage(named: "playVideo"), for: .normal)
               postImageView.isHidden = false
            }
            //show video thumbnail with play button on it.
        }
    }


    override func prepareForReuse() {
        //this way once user scrolls player will pause
        self.playerController?.player?.pause()
        self.playerController?.player = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
