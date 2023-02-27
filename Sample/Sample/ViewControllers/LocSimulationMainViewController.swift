//
//  LocSimulationMainViewController.swift
//  Demo
//
//  Created by Mapsted on 2019-09-12.
//  Copyright © 2019 Mapsted. All rights reserved.
//

import UIKit
import MapstedCore
import MapstedMap
import MapstedMapUi
import LocationMarketing
import MapKit

enum SimulatorPath {
    case LevelOne_ToFido
    case LevelOne_LevelTwo_ToFootLocker
}

struct LatLong {
    var lat: Double
    var long: Double
}

class LocSimulationMainViewController : UIViewController {

    private var containerVC: ContainerViewController?
    private var mapsVC: MapstedMapUiViewController?
    
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    private var simulatorPath: SimulatorPath = .LevelOne_LevelTwo_ToFootLocker
    private var simulatorWalkSpeedModifier: Float = 2.0

    //MARK: - Segue Handler
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let containerVC = segue.destination as? ContainerViewController, segue.identifier == "containerSegue" {
            self.containerVC = containerVC
        }
    }
    
    //MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerView.startAnimating()

        //Code to enable the location simulation mode and provide the simulator path and walking speed
        let userPath = self.getLocationSimulatorPath(simulatorPath: simulatorPath)
        MNSettingUtils.shared.setLocationSimulationDetails(speed: simulatorWalkSpeedModifier, Userpath: userPath) { status in
            if status {
                print("#Simulator Mode set successfully")
                var destinationName = ""
                switch simulatorPath {
                case .LevelOne_LevelTwo_ToFootLocker:
                    destinationName = "Foot Locker"
                    break
                case .LevelOne_ToFido:
                    destinationName = "Fido"
                    break
                }
                
                if destinationName != "" {
                    self.showToast(message: "To test routing, please request a route to: \(destinationName)", delayInSec: 5.0, duration: 5.0, preferredStyle: .alert)
                }

                
            }
        }

        //Initialize the SDK if it is not initialized already.
        if CoreApi.hasInit() {
            handleSuccess()
        }
        else {
            MapstedMapApi.shared.setUp(prefetchProperties: false, callback: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: - Intialize and add MapView and display property
    
    func addMapView() {
        if mapsVC == nil {
            if let mapsVC = MapstedMapUiViewController.shared as? MapstedMapUiViewController {
                mapsVC.setAlertDelegate(alertDelegate: self)
                self.mapsVC = mapsVC
                containerVC?.addController(controller: mapsVC, yOffset: 0, isNew: false)
            }
        }
        
        self.handleSuccess()
    }
    
    func displayProperty(propertyInfo: PropertyInfo, completion: (() -> ())? = nil) {
        //zoom to property
            self.mapsVC?.showLoadingSpinner(text: "Loading...")
            self.spinnerView.stopAnimating()
        
        let propertyId = propertyInfo.getPropertyId()
        mapsVC?.selectAndDrawProperty(propertyId: propertyId, callback: {[weak self] status in
            DispatchQueue.main.async {
                self?.mapsVC?.hideLoadingSpinner()
                if status {
                    self?.mapsVC?.displayPropertyOnMap {
                        completion?()
                    }
                }
                else {
                    print("Problem with status on select and draw")
                }
            }
        })
    }
    
    //Method to handle success scenario after SDK initialized
    fileprivate func handleSuccess() {
        let propertyInfos = CoreApi.PropertyManager.getAll()
        if propertyInfos.count > 0 {
            let firstProperty = propertyInfos[0]
            self.displayProperty(propertyInfo: firstProperty) {
                print("Property is displayed")
            }
        }
        else {
            print("No properties found")
        }
    }
}

//MARK: - Location Simulator Methods
extension LocSimulationMainViewController {
    
    func showToast(message: String, delayInSec: Double = 0.0, duration: Double, preferredStyle: UIAlertController.Style) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSec) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: preferredStyle)
            self.present(alert, animated: true)
                
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
                alert.dismiss(animated: true)
            }
        }
    }

    func getLocationSimulatorPath(simulatorPath: SimulatorPath) -> [MNMercatorZone] {
        switch (simulatorPath) {
            case .LevelOne_ToFido:
                return self.getLocationSimulatorPath_LevelOne_ToFido();
            case .LevelOne_LevelTwo_ToFootLocker:
                return self.getLocationSimulatorPath_LevelOne_LevelTwo_ToFootLocker();
        }
    }

    func getLocationSimulatorPath_LevelOne_ToFido() -> [MNMercatorZone] {
        let levelOneLatLngs: [LatLong] = [
            LatLong(lat: 43.59270591410157, long: -79.64468396358342),
            LatLong(lat: 43.59275554576186, long: -79.64405625196909),
            LatLong(lat: 43.59293620465817, long: -79.64386985725366),
            LatLong(lat: 43.59302554127498, long: -79.64237869953212),
            LatLong(lat: 43.59312480402684, long: -79.64235677074178),
            LatLong(lat: 43.5931704648377, long: -79.64221149250811),
            LatLong(lat: 43.593152597568235, long: -79.6420333210891),
            LatLong(lat: 43.59316116651411, long: -79.64169529771698),
            LatLong(lat: 43.593177048529554, long: -79.64133621378046),
            LatLong(lat: 43.59336167665214, long: -79.64134443707688),
            LatLong(lat: 43.59344307166634, long: -79.6413142849905)]

        var simulatorPath:[MNMercatorZone] = [MNMercatorZone]()
        _ = levelOneLatLngs.map { LatLong in
            simulatorPath.append(MNMercatorZone.init(zone: MNZone(propertyId: 504, buildingId: 504, floorId: 941), andMercator: MNMercator.init(lat: LatLong.lat, lng: LatLong.long)))
        }
        //print("# Location Simulator: \(simulatorPath)")
        return simulatorPath;
    }

    func getLocationSimulatorPath_LevelOne_LevelTwo_ToFootLocker() -> [MNMercatorZone] {
        let levelOneLatLngs: [LatLong] = [
            LatLong(lat: 43.59270506141888, long: -79.64467918464558),
            LatLong(lat: 43.59274299108304, long: -79.64407554834054),
            LatLong(lat: 43.59284979290362, long: -79.6439460008228),
            LatLong(lat: 43.59286875769334, long: -79.64355460194005),
            LatLong(lat: 43.59291567056778, long: -79.64341265093671),
            LatLong(lat: 43.59290777113583, long: -79.64330951843408)]

        let levelTwoLatLngs: [LatLong]  = [
            LatLong(lat: 43.59290777113583, long: -79.64330951843408),
            LatLong(lat: 43.59291305771916, long: -79.64321462730396),
            LatLong(lat: 43.59354343449601, long: -79.64326847002535),
            LatLong(lat: 43.59363085147197, long: -79.64315247246824),
            LatLong(lat: 43.59367739812217, long: -79.6420787112964),
            LatLong(lat: 43.59363085147197, long: -79.64207400869265)]

        var simulatorPath:[MNMercatorZone] = [MNMercatorZone]()

        _ = levelOneLatLngs.map { LatLong in
            simulatorPath.append(MNMercatorZone.init(zone: MNZone(propertyId: 504, buildingId: 504, floorId: 941), andMercator: MNMercator.init(lat: LatLong.lat, lng: LatLong.long)))
        }

        _ = levelTwoLatLngs.map { LatLong in
            simulatorPath.append(MNMercatorZone.init(zone: MNZone(propertyId: 504, buildingId: 504, floorId: 942), andMercator: MNMercator.init(lat: LatLong.lat, lng: LatLong.long)))
        }
        //print("# Location Simulator: \(simulatorPath)")
        return simulatorPath;
    }

}

//MARK: - Core Init Callback methods
extension LocSimulationMainViewController : CoreInitCallback {
    func onSuccess() {
        //Once the Map API Setup is complete, Setup the Mapview
        DispatchQueue.main.async {
            self.addMapView()
        }
    }
    
    func onFailure(errorCode: Int, errorMessage: String) {
        print("Failed with \(errorCode) - \(errorMessage)")
    }
    
    func onStatusMessage(messageType: StatusMessageType) {
        print("On StatusMessage: \(messageType)")
    }
}

//MARK: - MN Alert Delegate methods
extension LocSimulationMainViewController : MNAlertDelegate {
    func showAlerts() {
    }
    
    func loadingAlerts() -> Bool {
        return false
    }
}
