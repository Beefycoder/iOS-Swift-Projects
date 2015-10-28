//
//  Note.swift
//  NoteTaker
//
//  Created by Pat Butler on 2015-10-01.
//  Copyright © 2015 RPG Ventures. All rights reserved.
//

import Foundation
import CoreData

class Note: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var name: String

}
