//
//  LocationViewController.swift
//  TuDime
//
//  Created by IDS Logic on 29/03/24.
//  Copyright © 2024 ObjectSol. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class LocationViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var callback : ((String, String, Int, String) -> Void)?
    var dialogId: String!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var mapView: MKMapView!
    var placesClient: GMSPlacesClient!
    var likeHoodList: GMSPlaceLikelihoodList?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var bottomText: UILabel!
    var url = ""
    var timeStamp = 0
    var location:CLLocation?
    let cellReuseIdentifier = "cell"
    var time = ""
    var type = ""
    @IBOutlet private var timeSelectButton: [UIButton]!
    var currentLatitude: CLLocationDegrees!
    var currentLongitude: CLLocationDegrees!
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        DispatchQueue.main.async {
            self.showCurrentLocationOnMap()
        }

        self.nearbyPlaces()
        // Do any additional setup after loading the view.
    }
    func nearbyPlaces() {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }

            if let placeLikelihoodList = placeLikelihoodList {
                self.likeHoodList = placeLikelihoodList
                self.tableView.reloadData()
            }
        })
    }
    @IBAction func selectTimeTapped(sender:UIButton) {
        for (_, imageView) in timeSelectButton.enumerated() {
            if sender.tag ==  imageView.tag {
                imageView.superview?.backgroundColor = UIColor(hex: 0x0E87BB)
            } else {
                imageView.superview?.backgroundColor = .white

            }
            if sender.tag == 0 {
                time = "Location share time to set 15 minutes"
                bottomText.text = "Location share time to set 15 minutes"
                timeStamp = 15
            } else if sender.tag == 1 {
                time = "Location share time to set 1 hour"
                bottomText.text = "Location share time to set 1 hour"
                timeStamp = 60
            } else if sender.tag == 2 {
                time = "Location share time to set 8 hours"
                bottomText.text = "Location share time to set 8 hours"
                timeStamp = 480
            }

        }
    }
    @IBAction func sendTapped(sender:UIButton) {
        self.callback?(type, time, timeStamp, url)
        if type == "live location" {
            showCurrentLocationOnMap()
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.shouldBackground = true
                appDelegate.registerBackgroundTask(Double(15))

            }
        }
        self.navigationController?.popViewController(animated: true)

    }
    @IBAction func sendLiveLocationTapped(sender:UIButton) {
        bottomView.isHidden = false
        type = "live location"
    }
    @IBAction func sendLocationTapped(sender:UIButton) {
        bottomView.isHidden = true
        url = "http://maps.apple.com/?daddr=\(currentLatitude.description),\(currentLongitude.description)"
        type = "current location"
        sendTapped(sender: UIButton())
    }
    @IBAction func backbtnTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func autocompleteClicked() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) |
                                                                   UInt(GMSPlaceField.placeID.rawValue)))
        autocompleteController.placeFields = fields

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    func showCurrentLocationOnMap() {

        LocationManager.shared.getLocation { [weak self] location, error in

            if let error = error {
               // self?.alertMessage(message: error.localizedDescription, buttonText: "OK", completionHandler: nil)
                return
            }

            guard let location = location else {
                return
            }
            self?.location = location
            //Setting Region
            let center = CLLocationCoordinate2D(latitude: (location.coordinate.latitude), longitude: (location.coordinate.longitude))
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self?.currentLatitude = location.coordinate.latitude
            self?.currentLongitude = location.coordinate.longitude
            self?.mapView.setRegion(region, animated: true)
            self?.addPin()
        }
    }
    private func addPin() {
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "My Location"
        self.mapView.addAnnotation(objectAnnotation)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let likeHoodList = likeHoodList {
            return likeHoodList.likelihoods.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell? else { return UITableViewCell() }
        let place = likeHoodList?.likelihoods[indexPath.row].place //this is a GMSPlace object
        //https://developers.google.com/places/ios-api/reference/interface_g_m_s_place
        cell.textLabel?.text = place?.name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = likeHoodList?.likelihoods[indexPath.row].place //this is a GMSPlace object
        bottomView.isHidden = true
        url = "http://maps.apple.com/?daddr=\(place?.coordinate.latitude.description),\(place?.coordinate.longitude.description)"
        type = "current location"
        sendTapped(sender: UIButton())
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
extension LocationViewController: GMSAutocompleteViewControllerDelegate {

    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.bottomView.isHidden = true
            self.url = "http://maps.apple.com/?daddr=\(place.coordinate.latitude.description),\(place.coordinate.longitude.description)"
            self.type = "current location"
            self.sendTapped(sender: UIButton())
        }
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}
extension UIViewController {

    func alertMessage(message:String, buttonText:String, completionHandler: (()->())?) {
        let alert = UIAlertController(title: "Location", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonText, style: .default) { (action:UIAlertAction) in
            completionHandler?()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
