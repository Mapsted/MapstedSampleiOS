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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let containerVC = segue.destination as? ContainerViewController, segue.identifier == "containerSegue" {
            self.containerVC = containerVC
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerView.startAnimating()
        addMapView()
        
		MapstedMapApi.shared.setUp(prefetchProperties: false, callback: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addMapView() {
        if mapsVC == nil {
            if let mapsVC = MapstedMapUiViewController.shared as? MapstedMapUiViewController {
                mapsVC.setAlertDelegate(alertDelegate: self)
                self.mapsVC = mapsVC
                containerVC?.addController(controller: mapsVC, yOffset: 0, isNew: false)
            }
        }
    }
    
    func displayProperty(propertyInfo: PropertyInfo) {
        //zoom to property
        mapsVC?.showLoadingSpinner(text: "Loading...")
		let propertyId = propertyInfo.getPropertyId()
        MapstedMapApi.shared.removeProperty(propertyId: propertyId)
        mapsVC?.selectAndDrawProperty(propertyId: propertyId, callback: {status in
            DispatchQueue.main.async {
                if status {
                    DispatchQueue.main.async {
                        self.mapsVC?.hideLoadingSpinner()
                        self.mapsVC?.displayPropertyOnMap()
                    }
                }
            }
        })
    }
    
	fileprivate func handleSuccess() {
		DispatchQueue.main.async {
			let propertyInfos = CoreApi.PropertyManager.getAll()
			print(("##DT Found \(propertyInfos.count) properties"))
			if propertyInfos.count > 0 {
				let firstProperty = propertyInfos[0]
				self.mapsVC?.selectAndDrawProperty(propertyId: firstProperty.getPropertyId(), callback: {[weak self] status in
					DispatchQueue.main.async {
						self?.spinnerView.stopAnimating()
						if status {
							self?.displayProperty(propertyInfo: firstProperty)
						}
					}
					
				})
			}
		}
	}
	
}

extension MainViewController : CoreInitCallback {
    func onSuccess() {
        self.handleSuccess()
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

