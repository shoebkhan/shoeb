//
//  PushNotificationAlertViewController.swift
//
//  Created by shoeb on 29/03/23.
//  Copyright © 2023 IDS All rights reserved.
//

import UIKit

class PlusAlert: UIViewController {
    var callback : ((Int) -> Void)?

    @IBOutlet var okayButton: UIButton!
    @IBOutlet var pastDueDateModalHeightConstraint: NSLayoutConstraint!

    var descriptionMessage: String = ""
    var arrayAction: [[String: () -> Void]]?
    var okButtonAct: (() ->())?
    @IBOutlet weak var viewContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }
    private func configureView() {


    }
    @IBAction func sendAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // your code here
            self.callback?(sender.tag)
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewContainer.layer.cornerRadius = 5.0
        viewContainer.layer.masksToBounds = true
  
    }

    // MARK: - IBAction Methods
    
    @IBAction func cancelButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true, completion: nil)
    }


    @IBAction func okayAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

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
