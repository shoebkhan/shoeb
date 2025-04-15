//
//  LanguageVC.swift
//  EyeNak
//
//  Created by Sueb on 30/09/19.
//  Copyright © 2019 Sueb. All rights reserved.
//
import ObjectMapper
import SemiModalViewController
import UIKit
import Alamofire
import SVProgressHUD

class StickerListVC: UIViewController{
    var objectArray:Array<StikerList> = [StikerList]()
    var profile_UserId :String = UserDefaults.standard.string(forKey: "profile_user_id") ?? ""
    var stickId = ""
    var walletAmount = ""
    var amount = ""
    var catId = ""
    @IBOutlet weak var collectionView: UICollectionView!
    typealias AddedCompletionBlock = ( _ image: UIImage) -> Void
    var completionBlock: AddedCompletionBlock? = nil
    
    typealias AddedCompletionBlockTheme = ( _ object: SearchList) -> Void
    var completionBlockTheme: AddedCompletionBlockTheme? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(
            DoodleCell.nib,
            forCellWithReuseIdentifier: "DoodleCell"
        )
        getTheams()
        getWallet()
        // Do any additional setup after loading the view.
    }
    @IBAction func crossTappedDoodle(_ sender: UIButton) {
        self.dismiss(animated: true)
     
    }
    func validation() -> Bool
    {
        let balance : String = UserDefaults.standard.string(forKey: "balance") ?? ""
        let fvalue = Float(balance)
        if fvalue! > Float(amount)!{
            self.view.makeToast("You have no credit recharge please!".localized)
            print("You have no credit recharge please!")
            return false
        }
        
        return true
    }
    
   
    
}
extension StickerListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
            return objectArray.count
    
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DoodleCell", for: indexPath) as! DoodleCell
            
        cell.lbl.isHidden = true
      
        if self.objectArray[indexPath.row].cat_img.fileExtension() == ".gif" {
            let url = URL(string: self.objectArray[indexPath.row].url )
            let loader = UIActivityIndicatorView(style: .white)
            cell.imgVw.setGifFromURL(url!, customLoader: loader)
        }
        else{
            let url = URL(string: self.objectArray[indexPath.row].url )

            cell.imgVw.sd_setImage(with: url, placeholderImage: UIImage(named: "tudime"), options: [], context: nil)
        }
      
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   
            return CGSize(width: (UIScreen.main.bounds.size.width / 3) - 30, height:(UIScreen.main.bounds.size.width / 3) - 30)
       
          
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    
      
    }
    @IBAction func getSticker(_ sender: UIButton)
    {
        if validation() == true
        {
            verifySubscription(amount: amount)
        }
    }
}
extension StickerListVC {
func getTheams(){
   
   
    //appStickerList
    var geturl = String(format: "%@%@", url.appStickerList,stickId)
 
    geturl = geturl.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
    print(geturl)
    AF.request(geturl, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: nil).responseJSON { [self]
        response in
           
        switch (response.result) {
        case .failure( _):
           print("")
        case .success(let json):
            let str = String(decoding: response.data!, as: UTF8.self)
            var StikerList : StickerResponse? = nil
          
            StikerList = Mapper<StickerResponse>().map(JSONString : str)
            self.objectArray = StikerList!.data
            self.collectionView.reloadData()
//                for value in 0 ..< (themeData?.data.count)! {
//
//                    if verifyUrl(urlString: themeData?.themeList[value].images){
//                        let url = URL(string: (themeData?.themeList[value].images)!)!
//                        themesUrl.append(url)
//
//                    }
//
//                }
//                self.themeList.reloadData()
           
          //  print(json as? [String : Any])
           // completion(json as? [String : Any], nil)
        }
            
            
        }
    
}
    func getWallet()
    {
       
       
        let user_id = profile_UserId
        let params : [String : String] = ["useid" : user_id]
        print("Param--->",params)
       
        Just2.post(url.getUserBalance, params: params){(r) in
           
            if !r.ok{
                self.view.makeToast(r.msg)
                return
            }

            if r.ok{
                let response = Mapper<GetBalance>().map(JSONString : r.text!)
    //                print(response!.data[0].userid)
                DispatchQueue.main.async{
                    if !(response?.data.isEmpty)!
                        {
                        UserDefaults.standard.set(response?.data[0].plan_price, forKey: "balance")
                        self.walletAmount = (response?.data[0].plan_price)!
                        }
                        else
                        {
                            UserDefaults.standard.set("0", forKey: "balance")
                            self.walletAmount = "0"
                        }
                    
                    }
                }
                
            }
        }
    func verifySubscription(amount: String)
    {
        
        let params : [String : String] = ["useid":profile_UserId, "plan_name":"Credit DebitMoney", "plan_price":amount, "Payment_Referance_no": "debitMoney"]
        print("Param--->",params)
       
        Just2.post(url.buyWalletSub, params: params){(r) in
           
            if !r.ok{
                //self.view.makeToast(r.msg)
                return
            }

            if r.ok{
                let response = Mapper<CommonModel>().map(JSONString : r.text!)
                print("res-->",response!.data)
                print(response!.success_message)
                DispatchQueue.main.async {
                   
                    self.updateServer()
                    
                }
            }
                
        }
    }

    func updateServer()
    {
       
       
        //appStickerList
        var geturl = String(format: "%@&use_id=%@&cat_id=%@&cost=%@&trans_id=%@",url.buySticker, profile_UserId,catId,amount,Date.getCurrentDate())
     
        geturl = geturl.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)!
        print(geturl)
        AF.request(geturl, method: .get, parameters: nil,encoding: JSONEncoding.default, headers: nil).responseJSON { [self]
            response in
               
            switch (response.result) {
            case .failure( _):
               print("")
            case .success(let json):
                let str = String(decoding: response.data!, as: UTF8.self)
               
                DispatchQueue.main.async {
                    self.getWallet()
                    self.dismiss(animated: true)
                }
            }
                
                
            }
        
    }
}
