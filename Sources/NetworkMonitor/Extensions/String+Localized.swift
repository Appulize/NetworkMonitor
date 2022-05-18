//
//  File.swift
//  
//
//  Created by Maciej Świć on 2022-05-16.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: Bundle.module, value: "", comment: "")
    }
}
