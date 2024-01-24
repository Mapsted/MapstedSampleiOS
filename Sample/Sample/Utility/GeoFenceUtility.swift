//
//  GeoFenceUtility.swift
//  Mapsted Sample app
//
//  Created by Parth Bhatt on 23/01/2024.
//  Copyright © 2024 Mapsted. All rights reserved.
//

import Foundation
import MapstedCore
import MapstedGeofence


class GeoFenceUtility: NSObject {
    
    static let shared = GeoFenceUtility()

    private override init() {
        super.init()
    }
    
    // Create a Geofence for Entity
    func createGeofenceForEntity(propertyId: Int, entityId: Int, buildingId: Int, floorId: Int, geofenceId: String, delaySecond: Float = 5.0, stateChange: Bool = false, direction: ActivationDirection) -> GeofenceTrigger {
        
        let entityLocationCriteria = PoiVicinityLocationCriteria.Builder().addEntityZone(entityZone: MNEntityZone.init(propertyId: propertyId, buildingId: buildingId, floorId: floorId, entityId: entityId)).setTriggerDirection(direction: direction).setTriggerDelay(delayInSeconds: delaySecond, ignoreDelayedEventIfStateChanged: stateChange).build()

        let addEntityTrigger = GeofenceTrigger.Builder(propertyId: propertyId, geofenceId: geofenceId).setLocationCriteria(locationCriteria: entityLocationCriteria).build()
        
        return addEntityTrigger
    }

    // Create a Geofence for Property
    func createGeofenceForProperty(propertyId: Int, geofenceId: String, delaySecond: Float = 5.0, stateChange: Bool = false, direction: ActivationDirection) -> GeofenceTrigger {
        
        let propertyLocationCriteria = PropertyLocationCriteria.Builder(propertyId: propertyId).setTriggerDirection(direction: direction).setTriggerDelay(delayInSeconds: delaySecond, ignoreDelayedEventIfStateChanged: stateChange).build()

        let addPropertyTrigger = GeofenceTrigger.Builder(propertyId: propertyId, geofenceId: geofenceId).setLocationCriteria(locationCriteria: propertyLocationCriteria).build()

        return addPropertyTrigger
    }

    // Create a Geofence for Building
    func createGeofenceForBuilding(propertyId: Int, buildingId: Int, geofenceId: String, delaySecond: Float = 5.0, stateChange: Bool = false, direction: ActivationDirection) -> GeofenceTrigger {
        
        let buildingLocationCriteria = BuildingLocationCriteria.Builder(buildingId: buildingId).setTriggerDirection(direction: direction).setTriggerDelay(delayInSeconds: delaySecond, ignoreDelayedEventIfStateChanged: stateChange).build()

        let addBuildingTrigger = GeofenceTrigger.Builder(propertyId: propertyId, geofenceId: geofenceId).setLocationCriteria(locationCriteria: buildingLocationCriteria).build()
        
        return addBuildingTrigger
    }

    // Create a Geofence for Floor
    func createGeofenceForFloor(propertyId: Int, floorId: Int, geofenceId: String, delaySecond: Float = 5.0, stateChange: Bool = false, direction: ActivationDirection) -> GeofenceTrigger {
        
        let floorLocationCriteria = FloorLocationCriteria.Builder(floorId: floorId).setTriggerDirection(direction: direction).setTriggerDelay(delayInSeconds: delaySecond, ignoreDelayedEventIfStateChanged: stateChange).build()

        let addFloorTrigger = GeofenceTrigger.Builder(propertyId: propertyId, geofenceId: geofenceId).setLocationCriteria(locationCriteria: floorLocationCriteria).build()

        return addFloorTrigger
    }
}
