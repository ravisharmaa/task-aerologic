//
//  JSONLoaderUtility.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 18/07/2021.
//

import Foundation

enum FileExtensions: CustomStringConvertible {
    case json
    
    var description: String {
        switch self {
        case .json:
            return "json"
        }
    }
}

struct Utilities {
    
    static func loadJsonFrom <Model: Codable> (_ filePath: String, model: Model.Type) -> Model? {
       
        guard let url = Bundle.main.url(forResource: filePath, withExtension: FileExtensions.json.description) else {
            fatalError()
        }
        
        guard let data = try? Data(contentsOf: url) else { fatalError() }
        
        do {
            let model = try JSONDecoder().decode(Model.self, from: data)
            return model
        } catch let error {
            print(error)
        }
        
        return nil
    }
}
