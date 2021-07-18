//
//  Person.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 17/07/2021.
//

import Foundation
import GRDB

struct Person: Codable, Hashable, Identifiable {
    
    let id: UUID = UUID()
    let firstName: String?
    let lastName: String?
    let age: Int?
    let gender: String?
    let pictureURL: String?
    let job: [Job]?
    let education: [Education]?
    var isExpanded: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "firstname"
        case lastName = "lastname"
        case gender = "gender"
        case pictureURL = "picture"
        case age
        case job
        case education
    }
}

struct Job: Codable, Hashable {
    let role: String
    let exp: Int
    let organization: String
}

struct Education: Codable, Hashable {
    let degree: String
    let institution: String
}

extension Person: FetchableRecord, PersistableRecord {
    
    static var databaseTableName: String {
        return "employees"
    }
}
