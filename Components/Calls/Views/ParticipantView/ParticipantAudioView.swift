//
//  ParticipantAudioView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 08.06.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

struct ParticipantViewConstant {
    static let stateColor = #colorLiteral(red: 0.700391233, green: 0.7436676621, blue: 0.8309402466, alpha: 1)
}

class ParticipantAudioView: UIView {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var userView: UIView!
    @IBOutlet weak var userAvatarLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabelCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var callingToLabelHeight: NSLayoutConstraint!

    
    //MARK: - Properties
    var name = "" {
        didSet {
            nameLabel.text = name
            userAvatarLabel.text = String(name.capitalized.first ?? Character("Q"))
        }
    }
    var direction = "" {
        didSet {
            
        }
    }
    var duration = "" {
        didSet {
            
        }
    }
   // self.object = CallUserModel(ID: Int(self.callInfo.callId)!, name: name, date: self.getDateTime(), duration: "0.00", type: "Audio",direction: dir)
   
    
    override var tag: Int {
        didSet {
            userAvatarLabel.backgroundColor = UInt(tag).generateColor()
        }
    }
    func getDateTime() -> String
    {
        let currentDateTime = Date()

        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium

        // get the date time String from the date object
        let time = formatter.string(from: currentDateTime)
        return time
    }
    
    
    var connectionState: QBRTCConnectionState = .connecting {
        didSet {
            switch connectionState {
            case .new, .pending, .unknown: stateLabel.text = ""
            case .connected:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = ""
                callingToLabelHeight.constant = 0.0
                stateLabel.isHidden = true
            case .closed:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Closed".localized
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
                saveCallUser(ID: tag, name: name, date: self.getDateTime(), duration: duration, type: "ic_call_grey",direction: direction)
            case .failed:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Failed".localized
                callingToLabelHeight.constant = 0.0
                stateLabel.isHidden = false
              
                saveCallUser(ID: tag, name: name, date: self.getDateTime(), duration: duration, type: "ic_call_grey",direction: direction)
            case .hangUp:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Hung Up".localized
                stateLabel.isHidden = false
              saveCallUser(ID: tag, name: name, date: self.getDateTime(), duration: duration, type: "ic_call_grey",direction: direction)
            case .rejected:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Rejected".localized
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
                saveCallUser(ID: tag, name: name, date: self.getDateTime(), duration: duration, type: "ic_call_grey",direction: direction)
            case .noAnswer:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "No Answer".localized
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
                saveCallUser(ID: tag, name: name, date: self.getDateTime(), duration: duration, type: "ic_call_grey",direction: direction)
            case .disconnectTimeout:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Time out".localized
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
                saveCallUser(ID: tag, name: name, date: self.getDateTime(), duration: duration, type: "ic_call_grey",direction: direction)
            case .disconnected:
                stateLabel.textColor = ParticipantViewConstant.stateColor
                stateLabel.text = "Disconnected".localized
                stateLabel.isHidden = false
                callingToLabelHeight.constant = 0.0
                saveCallUser(ID: tag, name: name, date: self.getDateTime(), duration: duration, type: "ic_call_grey",direction: direction)
            default: stateLabel.text = ""
            }
        }
    }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        containerView.backgroundColor = #colorLiteral(red: 0.1960526407, green: 0.1960932612, blue: 0.1960500479, alpha: 1)
        userAvatarLabel.setRoundedLabel(cornerRadius: 30.0)
        userAvatarImageView.setRoundedView(cornerRadius: 30.0)
        userAvatarImageView.isHidden = true
        nameLabelCenterXConstraint.constant = 0.0
        callingToLabelHeight.constant = 28.0
    }
}
