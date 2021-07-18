//
//  QueueService.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 17/07/2021.
//

import Foundation

struct QueueService {
    static let backgroundQueue: DispatchQueue = DispatchQueue(label: "com.gcd.background", qos: .background)
}
