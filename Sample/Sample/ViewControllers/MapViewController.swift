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
        if CoreApi.hasInit() {
            self.onSuccess()
        }
        else {
            MapstedMapApi.shared.setUp(prefetchProperties: false, callback: self)
        }
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
        let propertyId = 504
        self.startDownload(propertyId: propertyId)
	}
    
    func startDownload(propertyId: Int) {
        CoreApi.PropertyManager.startDownload(propertyId: propertyId, propertyDownloadListener: self)
    }
	
    //MARK: - Download Property and Draw Property on Success
		//Handler for initialization notification
	fileprivate func handleSuccess() {
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
		
	}
	
		//Helper method to draw property.
    func drawProperty(propertyId: Int, completion: @escaping (() -> Void)) {
		
		guard let propertyData = CoreApi.PropertyManager.getCached(propertyId: propertyId) else {
			print("No property Data")
			self.hideSpinner()
			return
		}
		DispatchQueue.main.async {
			MapstedMapApi.shared.drawProperty(isSelected: true, propertyData: propertyData)
			if let propertyInfo = PropertyInfo(propertyId: propertyId) {
				MapstedMapApi.shared.mapView()?.moveToLocation(mercator: propertyInfo.getCentroid(), zoom: 18, duration: 0.2)
                completion();
			}
			self.hideSpinner()
		}
	}
    
    //MARK: - Utility Method
    
    //How to search for entities by name from CoreApi
    fileprivate func findEntityByName(name: String, propertyId: Int) {
        let matchedEntities = CoreApi.PropertyManager.findEntityByName(name: name, propertyId: propertyId)
        print("Matched \(matchedEntities.count) for \(name) in \(propertyId)")
        for match in matchedEntities {
            print("Match \(match.displayName) = \(match.entityId)")
        }
    }
}

//MARK: - UI Constraints Helper method
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

//MARK: - Core Init Callback methods
extension MapViewController : CoreInitCallback {
    func onSuccess() {
        //Once the Map API Setup is complete, Setup the Mapview
        self.handleSuccess()
    }
    
    func onFailure(errorCode: EnumSdkError) {
        print("Failed with \(errorCode)")
    }
    
    func onStatusUpdate(update: EnumSdkUpdate) {
        print("OnStatusUpdate: \(update)")
    }
    
    func onStatusMessage(messageType: StatusMessageType) {
        //Handle message
    }
}

//MARK: - Property Download Listener Callback methods
extension MapViewController : PropertyDownloadListener {
	func onSuccess(propertyId: Int) {
        self.drawProperty(propertyId: propertyId, completion: {
            self.findEntityByName(name: "ar", propertyId: propertyId)
        })
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

extension MapViewController: MNMapVectorElementListenerDelegate {
    func onPolygonTapped(polygon: MNMapPolygon, tapType: MapstedMap.MapstedMapApi.TapType, tapPos: MNMercator) {
    }
    
    func onEntityTapped(entity: MNMapEntity, tapType: MapstedMap.MapstedMapApi.TapType, tapPos: MNMercator) {
        print("onEntityTapped: \(entity.name) - entityId: \(entity.entityId())")
        MapstedMapApi.shared.selectSearchEntity(entity: entity, showPopup: false)
    }
    
    func onBalloonClicked(searchEntity: MNSearchEntity) {
    }
    
    func onMarkerTapped(markerName: String, markerType: String) {
    }
}

extension MapViewController: MNMapVectorTileEventListenerDelegate {
    public func onTileBalloonClicked(searchEntity: MNSearchEntity) {
        self.onBalloonClicked(searchEntity: searchEntity)
    }
    
    public func onTileMarkerTapped(markerName: String, markerType: String) {
        self.onMarkerTapped(markerName: markerName, markerType: markerType)
    }

    public func onTileEntityTapped(entity: MNMapEntity, tapType: MapstedMapApi.TapType, tapPos: MNMercator) {
        self.onEntityTapped(entity: entity, tapType: tapType, tapPos: tapPos)
    }
    
    public func onTilePolygonTapped(polygon: MNMapPolygon, tapType: MapstedMapApi.TapType, tapPos: MNMercator) {
        self.onPolygonTapped(polygon: polygon, tapType: tapType, tapPos: tapPos)
    }
}


extension MapViewController: MNMapListenerDelegate {
    func onMapMoved() {
    }
    
    func onMapStable() {
    }
    
    func onMapIdle() {
    }
    
    func onMapInteraction() {
    }
    
    func outsideBuildingTapped(tapPos: MNMercator, tapType: MapstedMap.MapstedMapApi.TapType) {
    }
}
