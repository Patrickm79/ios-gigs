//
//  GigDetailViewController.swift
//  iOS-Gigs
//
//  Created by Patrick Millet on 12/5/19.
//  Copyright © 2019 Patrick Millet. All rights reserved.
//

import UIKit

class GigDetailViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var gig: Gig?
    var apiController: GigController?

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()

    }

    func updateViews() {
        guard let gig = gig else {
            return }
        saveButton.isEnabled = false
        titleTextField.text = gig.title
        descriptionTextView.text = gig.description
        datePicker.date = gig.dueDate

    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if let title = titleTextField.text,
            let description = descriptionTextView.text,
            !title.isEmpty,
            !description.isEmpty {
            let date = datePicker.date
            let newGig = Gig(title: title, description: description, dueDate: date)

            apiController?.add(gig: newGig, completion: { error in
                if let error = error {
                    print("Error adding a new gig \(error)")
                }
            })
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
