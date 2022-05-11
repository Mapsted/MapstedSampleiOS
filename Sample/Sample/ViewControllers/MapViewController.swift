	//
	//  MapViewController.swift
	//  Sample
	//
	//  Created by Daniel on 2021-12-09.
	//  Copyright © 2021 Mapsted. All rights reserved.
	//

import UIKit
import MapstedCore
import MapstedMap

class MapViewController : UIViewController {
	
	@IBOutlet weak var spinnerView: UIActivityIndicatorView!
	@IBOutlet weak var mapPlaceholderView: UIView!
	
		//View controller in charge of map view
	private let mapViewController = MNMapViewController()
    
    //MARK: -
	
	public override func viewDidLoad() {
		super.viewDidLoad()
        showSpinner()
		MapstedMapApi.shared.setUp(prefetchProperties: false, callback: self)
	}
	
    //MARK: - Show & Hide Spinner
	
		//Start progress indicator
	func showSpinner() {
		DispatchQueue.main.async {
			self.spinnerView?.startAnimating()
		}
	}
	
		//Stop progress indicator
	func hideSpinner() {
		DispatchQueue.main.async {
			self.spinnerView?.stopAnimating()
		}
	}
    
    //MARK: - Setup UI
	
		//Method to do UI setup
	func setupUI() {
			//Whether or not you want to show compass
		MapstedMapMeta.showCompass = true
		
			//UI Stuff
		addChild(mapViewController)
		mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
		mapPlaceholderView.addSubview(mapViewController.view)
		addParentsConstraints(view: mapViewController.view)
		mapViewController.didMove(toParent: self)
        
        //Added handleSuccess once MapView is ready to avoid any plotting issues.
        self.handleSuccess()
	}
	
    //MARK: - Download Property and Draw Property on Success
		//Handler for initialization notification
	fileprivate func handleSuccess() {
			//Some property within the licence
		let propertyId = 504
		
			//Start progress animation
		
		
		CoreApi.PropertyManager.startDownload(propertyId: propertyId, propertyDownloadListener: self)
		
	}
	
		//Helper method to draw property.
	func drawProperty(propertyId: Int) {
		
		guard let propertyData = CoreApi.PropertyManager.getCached(propertyId: propertyId) else {
			print("No property Data")
			self.hideSpinner()
			return
		}
		DispatchQueue.main.async {
			MapstedMapApi.shared.drawProperty(isSelected: true, propertyData: propertyData)
			if let propertyInfo = PropertyInfo(propertyId: propertyId) {
				MapstedMapApi.shared.mapView()?.moveToLocation(mercator: propertyInfo.getCentroid(), zoom: 18, duration: 0.2)
			}
			self.hideSpinner()
		}
	}
}

extension MapViewController {
		//Helper method
	func addParentsConstraints(view: UIView?) {
		guard let superview = view?.superview else {
			return
		}
		
		guard let view = view else {return}
		
		view.translatesAutoresizingMaskIntoConstraints = false
		
		let viewDict: [String: Any] = Dictionary(dictionaryLiteral: ("self", view))
		let horizontalLayout = NSLayoutConstraint.constraints(
			withVisualFormat: "|[self]|", options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing, metrics: nil, views: viewDict)
		let verticalLayout = NSLayoutConstraint.constraints(
			withVisualFormat: "V:|[self]|", options: NSLayoutConstraint.FormatOptions.directionLeadingToTrailing, metrics: nil, views: viewDict)
		superview.addConstraints(horizontalLayout)
		superview.addConstraints(verticalLayout)
	}
}

extension MapViewController : CoreInitCallback {
    func onSuccess() {
        //Once the Map API Setup is complete, Setup the Mapview
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    func onFailure(errorCode: Int, errorMessage: String) {
        print("Failed to initialize with error: \(errorCode) - \(errorMessage)")
    }
    
    func onStatusMessage(messageType: StatusMessageType) {
        //Handle message
    }
}

extension MapViewController : PropertyDownloadListener {
	func onSuccess(propertyId: Int) {
		self.drawProperty(propertyId: propertyId)
	}
	
	func onSuccess(propertyId: Int, buildingId: Int) {
		print("Successfully downloaded \(propertyId) - \(buildingId)")
	}
	
	func onFailureWithProperty(propertyId: Int) {
		print("Failed to download \(propertyId)")
	}
	
	func onFailureWithBuilding(propertyId: Int, buildingId: Int) {
		print("Failed to download \(propertyId) - \(buildingId)")
	}
	
	func onProgress(propertyId: Int, percentage: Float) {
		print("Downloaded \(percentage * 100)% of \(propertyId)")
	}
	
	
	
}
