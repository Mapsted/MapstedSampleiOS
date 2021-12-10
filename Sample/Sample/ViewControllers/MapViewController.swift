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
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
			//Do some UI stuff
		setupUI()
		
			//Subscribe to notifications
		MNCoreNotificationManager.main.addObserver(type: .initialized, observer: self, selector: #selector(self.initialized(notification:)))
	}
	
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
	}
	
	
		//Handler for initialization notification
	@objc func initialized(notification: NSNotification) {
		let result = notification.userInfo?["result"] as? Bool
		if ( result == true ) {
			print("Initialize Succeeded!")
			
				//Some property within the licence
			let propertyId = 504
			
				//Start progress animation
			showSpinner()
			
				//Download Property data
			MapstedCoreApi.shared.downloadPropertyData(propertyId: propertyId,
													   progress: { p in
				print("Downloaded \(p * 100)%")
				
			}, completed: { success in
				if success {
						//if successful, draw property
					self.drawProperty(propertyId: propertyId)
				}
				else {
					print("Failed")
				}
			})
		} else {
			print("Initialize Failed!")
		}
	}
	
		//Helper method to draw property.
	func drawProperty(propertyId: Int) {
		print("Drawing")
		
		guard let propertyData = MapstedCoreApi.shared.propertyData(propertyId: propertyId) else {
			print("No property Data")
			self.hideSpinner()
			return
		}
		DispatchQueue.main.async {
			MapstedMapApi.shared.drawProperty(isSelected: true, propertyData: propertyData)
			if let propertyInfo = MNPropertyInfo(propertyId: propertyData.propertyId()) {
				MapstedMapApi.shared.mapView()?.moveToLocation(mercator: propertyInfo.centroid(), zoom: 18, duration: 0.2)
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
