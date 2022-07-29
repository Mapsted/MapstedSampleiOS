//
//  ListTableViewController.swift
//  Sample
//
//  Created by Daniel on 2022-07-27.
//  Copyright © 2022 Mapsted. All rights reserved.
//

import UIKit
import MapstedCore
import MapstedMap
class ListTableViewController: UITableViewController {
    
    struct Identifier {
        static let SEGUE = "ID_VIEW_PROPERTY"
        static let TABLE_VIEW_CELL = "CELL_PROPERTY"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MainViewController,
            segue.identifier == Identifier.SEGUE,
            let property = sender as? PropertyInfo {
            destination.selectedProperty = property
        }
    }

    var propertyInfos = [PropertyInfo]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifier.TABLE_VIEW_CELL)

        if CoreApi.hasInit() {
            handleSuccess()
        }
        else {
            MapstedMapApi.shared.setUp(prefetchProperties: false, callback: self)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return propertyInfos.count
    }

    func getItemAt(indexPath: IndexPath) -> PropertyInfo? {
        guard indexPath.row < propertyInfos.count else { return nil }
        return propertyInfos[indexPath.row]
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: Identifier.TABLE_VIEW_CELL, for: indexPath)
        guard let thisProperty = getItemAt(indexPath: indexPath) else {
            return cell
        }
        
        
        cell.textLabel?.text = thisProperty.displayName
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let thisProperty = getItemAt(indexPath: indexPath) else { return }
        performSegue(withIdentifier: Identifier.SEGUE, sender: thisProperty)
    }
   

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ListTableViewController : CoreInitCallback {
    fileprivate func handleSuccess() {
        self.propertyInfos = CoreApi.PropertyManager.getAll().sorted(by: { p1, p2 in
            return p1.displayName < p2.displayName
        })
        DispatchQueue.main.async {
            self.title = "Properties Found: \(self.propertyInfos.count) "
            self.tableView.reloadData()
        }
        
    }
    
    func onSuccess() {
        
        handleSuccess()
    }
    
    func onFailure(errorCode: Int, errorMessage: String) {
        print("Failed with \(errorCode) - \(errorMessage)")
    }
    
    func onStatusMessage(messageType: StatusMessageType) {
        
    }
}
