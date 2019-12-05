//
//  Gig.swift
//  iOS-Gigs
//
//  Created by Patrick Millet on 12/5/19.
//  Copyright © 2019 Patrick Millet. All rights reserved.
//

import Foundation

struct Gig: Codable {
    let title: String
    let description: String
    let dueDate: Date
}
