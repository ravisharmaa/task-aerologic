//
//  MigrationService.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 17/07/2021.
//

import Foundation
import GRDB

final class Migration {
    
    var connection: DatabasePool
    
    init(connection: DatabasePool) {
        self.connection = connection
    }
    
    func run() {
        do {
            try createEmployeesTable()
        } catch let error {
            print(error, "while creating table")
        }
    }
    
    private func createEmployeesTable() throws {
        try connection.write { database in
            try database.create(table: "employees", ifNotExists: true) { (definition) in
                definition.column("uuid", .text).primaryKey()
                definition.column("firstname", .text)
                definition.column("lastname", .text)
                definition.column("age", .integer)
                definition.column("gender", .text)
                definition.column("picture", .text)
                definition.column("job", .text)
                definition.column("education", .text)
            }
        }
    }
    
    
}
