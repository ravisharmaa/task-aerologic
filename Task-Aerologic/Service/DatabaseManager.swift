//
//  DatabaseManager.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 17/07/2021.
//

import Foundation
import GRDB

// swiftlint: disable
final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    var connection: DatabasePool? {
        do {
            let connection = try DatabasePool(path: prepareFilePath())
            return connection
        } catch  _ {
            print("error in connection")
        }
        
        return nil
    }
   
    private init () {}
    
    func prepareConnection() -> DatabasePool? {
        
        let path = prepareFilePath()
        
        do {
            if fileExists(at: path) {
                print(path)
                return try DatabasePool(path: path)
                
            } else {
                guard let createdPath = createFile() else { fatalError() }
                print(path)
                return try DatabasePool(path: createdPath)
                
            }
        } catch let error {
            print("Failed initialzng database,\(error.localizedDescription)")
        }
        
        return nil
        
    }
    
    
    fileprivate func prepareFilePath() -> String {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        let url = NSURL(fileURLWithPath: path)
        
        guard let filePath = url.appendingPathComponent("database")?.appendingPathExtension("sqlite").path else { fatalError()}
        
        return filePath
        
    }
    
    fileprivate func fileExists(at filePath: String) -> Bool {
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    fileprivate func createFile() -> String? {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent("database").appendingPathExtension("sqlite")
            
            return fileURL.path
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
