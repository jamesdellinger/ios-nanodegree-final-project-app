//
//  GrandCentralDispatchPerformUpdates.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/8/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
