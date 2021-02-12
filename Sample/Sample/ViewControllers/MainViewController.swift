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

#error(" A Mapsted license file is required in order to run the sample app. If you do not have a license, please contact https://mapsted.com/contact-us to get the license first.")

class MainViewController : UIViewController {
    
    private var containerVC: ContainerViewController?
    private var mapsVC: MapstedMapUiViewController?
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var labelHtConstraint: NSLayoutConstraint!
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
        closeBtn.layer.cornerRadius = 12
        closeBtn.layer.masksToBounds = true
        
        MNCoreNotificationManager.main.addObserver(type: .initialized, observer: self, selector: #selector(self.initialized(notification:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        labelHtConstraint.constant = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let bannerText = mapsVC?.connectWifiBluetoothBannerText() {
            infoLabel.text = bannerText
            UIView.animate(withDuration: 0.2) {
                self.labelHtConstraint.constant = 48
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func addMapView() {
        if mapsVC == nil {
            if let mapsVC = MapstedMapUiViewController.shared as? MapstedMapUiViewController {
                self.mapsVC = mapsVC
                containerVC?.addController(controller: mapsVC, yOffset: 0, isNew: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.mapsVC?.zoomTo(level: 2)
                }
            }
        }
    }
    
    func displayProperty(propertyInfo: MNPropertyInfo) {
        //zoom to property
        mapsVC?.showLoadingSpinner(text: "Loading...")
        MapstedMapApi.shared.removeProperty(propertyId: propertyInfo.propertyId())
        mapsVC?.selectAndDrawProperty(propertyId: propertyInfo.propertyId(), callback: {status in
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
    
    @objc func initialized(notification: NSNotification) {
        let result = notification.userInfo?["result"] as? Bool
        if ( result == true ) {
            print("Initialize Succeeded!")
            DispatchQueue.main.async {
                let propertyInfos = MapstedCoreApi.shared.propertyInfos()
                if propertyInfos.count > 0 {
                    self.mapsVC?.selectAndDrawProperty(propertyId: propertyInfos[0].propertyId(), callback: {[weak self] status in
                        DispatchQueue.main.async {
                            self?.spinnerView.stopAnimating()
                            if status {
                                self?.displayProperty(propertyInfo: propertyInfos[0])
                            }
                        }
                        
                    })
                }
            }
        } else {
            print("Initialize Failed!")
        }
    }
}
