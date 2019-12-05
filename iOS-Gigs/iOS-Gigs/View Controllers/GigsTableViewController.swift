//
//  GigsTableViewController.swift
//  iOS-Gigs
//
//  Created by Patrick Millet on 12/4/19.
//  Copyright © 2019 Patrick Millet. All rights reserved.
//

import UIKit

class GigsTableViewController: UITableViewController {

    //MARK: - Properties
    
    private var gigNames: [String] = []
    let apiController = GigController()

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if apiController.bearer == nil {
            performSegue(withIdentifier: "LoginSegue", sender: self)
        } else {
            apiController.fetchGigs { (result) in
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiController.gigs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GigCell", for: indexPath)
        
        let gig =  apiController.gigs[indexPath.row]
        let date = gig.dueDate
        
        cell.textLabel?.text = gig.title
        cell.detailTextLabel?.text = date.toString(dateFormat: "dd-MM-YYYY")
        return cell
    }
    // I realize that we haven't covered DELETE requests but I wanted to add this delete method anyway for practice since in a real App I would use this
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.apiController.gigs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "LoginSegue":
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.apiController = apiController
            }
        case "AddGigShowSegue":
            if let loginVC = segue.destination as? GigDetailViewController {
                loginVC.apiController = apiController
            }
        case "GigDetailShowSegue":
            if let loginVC = segue.destination as? GigDetailViewController {
                loginVC.apiController = apiController
            }
        default:
            return
        }
    }

}
