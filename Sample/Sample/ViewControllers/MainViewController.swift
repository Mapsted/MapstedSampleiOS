//
//  MainViewController.swift
//  Demo
//
//  Created by Mapsted on 2019-09-12.
//  Copyright © 2019 Mapsted. All rights reserved.
//

import UIKit
import MapstedCore
import MapstedMap
import MapstedMapUi

class MainViewController : UIViewController {
    
    private var containerVC: ContainerViewController?
    private var mapsVC: MapstedMapUiViewController?
    
    @IBOutlet weak var spinnerView: UIActivityIndicatorView!
    
    //MARK: -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let containerVC = segue.destination as? ContainerViewController, segue.identifier == "containerSegue" {
            self.containerVC = containerVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerView.startAnimating()
        //addMapView()
        
		MapstedMapApi.shared.setUp(prefetchProperties: false, callback: self)
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
    
    func displayProperty(propertyInfo: PropertyInfo) {
        //zoom to property
        DispatchQueue.main.async {
            self.mapsVC?.showLoadingSpinner(text: "Loading...")
            self.spinnerView.stopAnimating()
        }
        
		let propertyId = propertyInfo.getPropertyId()
        mapsVC?.selectAndDrawProperty(propertyId: propertyId, callback: {[weak self] status in
            DispatchQueue.main.async {
                self?.mapsVC?.hideLoadingSpinner()
                if status {
                    self?.mapsVC?.displayPropertyOnMap()
                }
                else {
                    print("Problem with status on select and draw")
                }
            }
        })
    }
    
	fileprivate func handleSuccess() {
        let propertyInfos = CoreApi.PropertyManager.getAll()
        if propertyInfos.count > 0 {
            let firstProperty = propertyInfos[0]
            self.displayProperty(propertyInfo: firstProperty)
        }
        else {
            print("No properties found")
        }
	}
}

extension MainViewController : CoreInitCallback {
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
        
    }
}


extension MainViewController : MNAlertDelegate {
    func showAlerts() {
    }
    
    func loadingAlerts() -> Bool {
        return false
    }
}

