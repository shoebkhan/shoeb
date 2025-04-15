//
//  PlayerView.swift
//  TuDime
//
//  Created by IDS Logic on 12/11/23.
//  Copyright © 2023 ObjectSol. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayerView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self;
    }

    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer;
    }

    var player: AVPlayer? {
        get {
            return playerLayer.player;
        }
        set {
            playerLayer.player = newValue;
        }
    }
}
