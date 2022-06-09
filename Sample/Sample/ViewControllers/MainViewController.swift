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
        DispatchQueue.main.async {
            self.mapsVC?.showLoadingSpinner(text: "Loading...")
            self.spinnerView.stopAnimating()
        }
        
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
                self.findAllEntities(propertyId: firstProperty.propertyId)
            }
        }
        else {
            print("No properties found")
        }
	}
    
    //How to search for entities by name from CoreApi
    fileprivate func findAllEntities(propertyId: Int) {
        let matchedEntities = CoreApi.PropertyManager.getSearchEntities(propertyId: propertyId)
        print("Getting all search entities in \(propertyId)")
        for match in matchedEntities {
            print("##Found \(match.displayName) = \(match.entityId) in \(propertyId)")
        }
    }
    
    //How to request a list of nearby entities from CoreApi
    fileprivate func findNearbyEntities() {
        CoreApi.LocationManager.getNearbyEntities { listOfEntities in
            for entity in listOfEntities {
                print("Found \(entity.entityId) - \(entity.displayName)")
            }
            
        }
    }
    
    //How to search for entities by name from CoreApi
    fileprivate func findEntityByName(name: String, propertyId: Int) {
        let matchedEntities = CoreApi.PropertyManager.findEntityByName(name: name, propertyId: propertyId)
        print("Matched \(matchedEntities.count) for \(name) in \(propertyId)")
        for match in matchedEntities {
            print("Match \(match.displayName) = \(match.entityId)")
        }
    }
    
    //How to request estimated distance from current user location using CoreApi
    fileprivate func estimateDistanceFromCurrentLocation(propertyId: Int) {
        let entities = CoreApi.PropertyManager.findEntityByName(name: "Appl", propertyId: propertyId)
        if let destination = entities.first as? MNSearchEntity {
            let useStairs = false
            let routeOptions = MNRouteOptions(useStairs,
                                              escalators: true,
                                              elevators: true,
                                              current: true,
                                              optimized: true)
            
            CoreApi.RoutingManager.requestEstimateFromCurrentLocation(destination: destination,
                                                                      routeOptions: routeOptions,
                                                                      completion: { distTime in
                
                if let distanceTime = distTime {
                    print("Estimated distance is \(distanceTime.distanceInMeters)")
                    print("Estimated time is \(distanceTime.timeInMinutes)")
                }
            })
        }
    }
    
    
    //How to request estimated distance from CoreApi
    fileprivate func estimateDistance(propertyId: Int) {
        let entities = CoreApi.PropertyManager.findEntityByName(name: "an", propertyId: propertyId)
        if let from = entities.first as? MNSearchEntity, let to = entities[1...].randomElement() as? MNSearchEntity {
            let useStairs = false
            let routeOptions = MNRouteOptions(useStairs,
                                              escalators: true,
                                              elevators: true,
                                              current: false,
                                              optimized: true)
            print("Estimating distance from \(from.displayName) to \(to.displayName)")
            CoreApi.RoutingManager.requestEstimate(start: from,
                                                   destination: to,
                                                   routeOptions: routeOptions,
                                                   completion: { distTime in
                if let distanceTime = distTime {
                    print("Estimated distance is \(distanceTime.distanceInMeters) meter(s)")
                    print("Estimated time is \(distanceTime.timeInMinutes) minute(s)")
                }
            })
        }
    }
    
    fileprivate func allEntities(propertyId: Int) {
        let entities = CoreApi.PropertyManager.getSearchEntities(propertyId: propertyId)
        for entity in entities {
            print("#Entity: \(entity.entityId) = \(entity.displayName)")
        }
    }
    
    
    fileprivate func selectEntities(propertyId: Int) {
        let entities = CoreApi.PropertyManager.findEntityByName(name: "Apple", propertyId: propertyId)
        if let firstMatch = entities.first {
            print("Selecting ... \(firstMatch.entityId) = \(firstMatch.displayName)")
            MapstedMapApi.shared.selectEntity(entity: firstMatch)
        }
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
            print("Deselecting ....")
            MapstedMapApi.shared.deselectEntity()
        }
         */
    }
    fileprivate func makeRouteRequests(propertyId: Int) {
        let entities = CoreApi.PropertyManager.findEntityByName(name: "Appl", propertyId: propertyId)
        let otherEntities = CoreApi.PropertyManager.getSearchEntities(propertyId: propertyId)
        if let firstMatch = entities.first,
            let randomDestination1 = otherEntities.randomElement(),
            let randomDestination2 = otherEntities.randomElement(){
            
            
            self.makeRouteRequest(start: firstMatch,
                                  fromCurrentLocation: false,
                                  destinations: [randomDestination1, randomDestination2])
            
        }
        
        
    }
    
    fileprivate func makeRouteRequest(start: ISearchable?, fromCurrentLocation: Bool, destinations: [ISearchable]) {
        let optimizedRoute = true
        let useStairs = false
        let useEscalators = true
        let useElevators = true
        
        let routeOptions = MNRouteOptions(useStairs,
                                          escalators: useEscalators,
                                          elevators: useElevators,
                                          current: fromCurrentLocation,
                                          optimized: optimizedRoute)
        
        let start = start as? MNSearchEntity
        let pois = destinations.compactMap({$0 as? MNSearchEntity})
        
                
            //Build a route request
        var routeRequest: MNRouteRequest?
        routeRequest = MNRouteRequest(routeOptions: routeOptions,
                                      destinations:pois,
                                      startEntity: fromCurrentLocation ? nil : start)
        
        
        if let routeRequest = routeRequest {
            
                //@Daniel: Let's put this in async queue
            DispatchQueue.global(qos: .userInteractive).async {
                CoreApi.RoutingManager.requestRoute(request: routeRequest, routingRequestCallback: self)
            }
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

extension MainViewController: RoutingRequestCallback {
    func onSuccess(routeResponse: MNRouteResponse) {
        MapstedMapApi.shared.handleRouteResponse(routeResponse: routeResponse)
    }
    
    func onError(errorCode: Int, errorMessage: String, alertIds: [String]) {
        MapstedMapApi.shared.handleRouteError(errorCode: errorCode, errorMessage: errorMessage, alertIds: alertIds)
    }
    
    
}


extension MainViewController : MNAlertDelegate {
    func showAlerts() {
    }
    
    func loadingAlerts() -> Bool {
        return false
    }
}

