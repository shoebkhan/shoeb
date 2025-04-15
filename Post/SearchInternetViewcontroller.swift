//
//  SubscriptionWarningVC.swift
//  TuDime
//
//  Created by Ayan Jana on 28/10/20.
//  Copyright © 2020 ObjectSol. All rights reserved.
//

import UIKit
import Toast_Swift
import Toaster
import Alamofire
import ObjectMapper
import SVProgressHUD

class SearchInternetViewcontroller: customView, UITableViewDataSource, UITableViewDelegate {
    typealias AddedCompletionBlock = ( _ title: String, _ image:String, _ urlImage: String, _ urlLink:String) -> Void
    var searchArray:Array<itemList> = [itemList]()
    var completionBlock: AddedCompletionBlock? = nil
    private var currentSearchPage: Int = 1
    var profileCreateDt: Date!
    private var cancel = false
    private var loadStart = false
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fullMessageLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    private var isSearch = false
    private var searchText = ""
    fileprivate var activityIndicator: LoadMoreActivityIndicator!
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()

    }

    func setView() {
        //subscribeBtn.backgroundColor = color.colorPrimary
        contentView.layer.cornerRadius = 5
        closeBtn.layer.cornerRadius = 5
        closeBtn.setImage(UIImage(named: "crop__ic_cancel")?.tint(with: .red), for: .normal)
        closeBtn.addTarget(self, action: #selector(self.closeApp), for: .touchUpInside)
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField, let clearButton = searchTextField.value(forKey: "_clearButton")as? UIButton {
            searchTextField.font = .systemFont(ofSize: 12.0, weight: .regular)
            clearButton.addTarget(self, action: #selector(cancelSearchButtonTapped), for: .touchUpInside)

        }
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        tableView.tableFooterView = UIView()
        activityIndicator = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 60)
    }
    @objc func cancelSearchButtonTapped() {
        // cancelSearchButton.isHidden = true
        searchBar.text = ""
        searchBar.resignFirstResponder()
       
    }

    @objc func closeApp() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func openSubscription() {
      //  self.completionBlock?(true)
        self.dismiss(animated: false, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InternetCell", for: indexPath) as! InternetCell
        let object = self.searchArray[indexPath.row]
        cell.webImage.sd_setImage(with:  URL(string:( object.thumbnailLink)), placeholderImage: UIImage(named: "picture"), options: [], context: nil)
        cell.titlelabel.text = object.title
        cell.linkLabel.text = object.contextLink
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return  UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.searchArray[indexPath.row]
        self.completionBlock?(object.title, object.contextLink, object.link,object.contextLink)
        
    }
    func getList(show:Bool = true) {
        if show {
            SVProgressHUD.show()
        }
        loadStart = true
        var geturl = String(format: "https://www.googleapis.com/customsearch/v1?key=AIzaSyCoH2nPsqLSRciQwgm2yw2PuLC7_Wq_vZY&cx=7621857416aa44f70&q=%@&searchType=image&fileType=jpg&imgSize=xlarge&alt=json&start=%d", searchText,self.currentSearchPage)

        geturl = geturl.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
        print(geturl)
        AF.request(geturl, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: nil).responseJSON { [self]
            response in
            SVProgressHUD.dismiss()
            loadStart = false
            switch (response.result) {
            case .failure( _):
                print("")
            case .success(_):
                let str = String(decoding: response.data!, as: UTF8.self)
                print(str)
                var internetResponse : InternetResponse? = nil

                internetResponse = Mapper<InternetResponse>().map(JSONString : str)
                if let itemList = internetResponse?.items {
                    self.searchArray.append(contentsOf: itemList)
                }
                if (internetResponse?.request.count ?? 0) > 0 {
                    self.currentSearchPage = internetResponse?.request[0].startIndex ?? 0

                }
//                notesList = notes?.data ?? []
                self.tableView.reloadData()

            }


        }

    }
}

extension SearchInternetViewcontroller: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        self.searchText = searchText
//        if searchText.count > 2 {
//            isSearch = true
//            currentSearchPage = 1
//            cancel = false
//            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: nil)
//            let delay = 1.0
//            perform(#selector(self.performSearch), with: nil, afterDelay: delay)
//        }
//        if searchText.count == 0 {
//            isSearch = false
//            cancel = false
//            //setupUsers(downloadedUsers)
//        }
    }
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar) {
        self.searchText = searchBar.text ?? ""
        if searchText.count > 0 {
            isSearch = true
            currentSearchPage = 1
            cancel = false
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.performSearch), object: nil)
            let delay = 1.0
            perform(#selector(self.performSearch), with: nil, afterDelay: delay)
        }
        if searchText.count == 0 {
            isSearch = false
            cancel = false
            //setupUsers(downloadedUsers)
        }
        self.view.endEditing(true)
    }
    @objc func performSearch() {
          getList()
       // timeLineCall(text: self.searchText)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //cancelSearchButton.isHidden = false
    }
  
}

extension SearchInternetViewcontroller {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        activityIndicator.start {
            DispatchQueue.global(qos: .utility).async {
                if !self.loadStart {
                    self.getList(show: false)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.activityIndicator.stop()
                }
            }
        }
    }
}
