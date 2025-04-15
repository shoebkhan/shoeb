//
//  QRCodeVC.swift
//  TuDime
//
//  Created by Shoeb on 30/11/21.
//  Copyright © 2021 ObjectSol. All rights reserved.
//

import UIKit

class QRCodeVC: UIViewController {

    @IBOutlet weak var qrImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        qrImage.image = Global.qrCode
        // Do any additional setup after loading the view.
    }

    @IBAction func shareAction(_ sender: Any) {
        let image = UIImage(named: "Image")
               
               // set up activity view controller
               let imageToShare = [  qrImage.image ]
               let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
               activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
               
               // exclude some activity types from the list (optional)
               activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
               
               // present the view controller
               self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
