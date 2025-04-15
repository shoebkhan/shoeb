//
//  IntrestViewController.swift
//  TuDime
//
//  Created by IDS Logic on 29/10/24.
//  Copyright © 2024 ObjectSol. All rights reserved.
//
import UIKit
import Toast_Swift
import Just
import Alamofire
import SVProgressHUD
import ObjectMapper
import UIKit
import iOSDropDown

class IntrestViewController: UIViewController, TagListViewDelegate {
    var profile_UserId :String = UserDefaults.standard.string(forKey: "user_id")!
    var handler: ((_ value: String) -> ())?
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var dropDown : DropDown!
    var array: [String] = []
    var nameArray: [String] = []
    var idArray: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        getInterest()
        // Do any additional setup after loading the view.
        dropDown.didSelect{(selectedText , index ,id) in
            self.tagListView.addTag(selectedText)
            self.array.append(selectedText)
        }
        tagListView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    @IBAction func saveAction(_ sender: Any) {
        setInterest()

    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: TagListViewDelegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
    }

    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
        self.array.remove(at: sender.tag)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func getInterest() {
        SVProgressHUD.show()
        Just2.get(url.getInterest){(r) in
            if !r.ok {
                DispatchQueue.main.async{ [self] in
                    self.view.makeToast(r.msg)
                    SVProgressHUD.dismiss()
                }

                return
            }

            if r.ok {
                print(r.text!)
                let response = Mapper<InterestResponse>().map(JSONString : r.text ?? "")
                DispatchQueue.main.async { [self] in
                    SVProgressHUD.dismiss()
                    if response?.status == "1" {
                        for i in 0..<(response?.message.count ?? 0) {
                            self.nameArray.append(response?.message[i].name ?? "")
                            self.idArray.append(response?.message[i].id ?? "")
                        }
                        self.dropDown.optionArray = self.nameArray
                    }
                }

            }
        }
    }

    func setInterest() {
        let stringFromIntArray = array.map { String($0) }.joined(separator: ", ")
        var urlvalue = String(format: "%@qb_id=%@&interests=%@", url.setInterest,profile_UserId, stringFromIntArray)
        urlvalue = urlvalue.replacingOccurrences(of: " ", with: "%20")
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
                        let stringFromIntArray = array.map { String($0) }.joined(separator: ", ")
                        self.handler?(stringFromIntArray)
                        self.navigationController?.popViewController(animated: true)
                    }
                }

            }
        }
    }
}
