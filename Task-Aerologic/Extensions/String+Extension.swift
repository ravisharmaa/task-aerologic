//
//  String+Extension.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 18/07/2021.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
