//
//  Requestable.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 17/07/2021.
//

import Foundation
import Combine

enum RequestMethods {
    case GET
    case POST
    
    var name: String {
        switch self {
        case .GET:
            return "GET"
        case .POST:
            return "POST"
        }
    }
}

enum ApplicationError: Error {
    case invalidData
    case invalidResponse
}

protocol Requestable {
    var session: URLSession { get set }
    
    func load <Model: Codable> (for model: Model.Type,
                                path: String,
                                queryItems: [URLQueryItem],
                                using method: RequestMethods
                                )
    -> AnyPublisher<Model, Error>
}

class Request: Requestable {
    
    private var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = AppConstants.requestScheme
        components.host = AppConstants.baseURL
        return components
    }
    
    var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func load <Model>(for model: Model.Type,
                      path: String,
                      queryItems: [URLQueryItem] = [],
                      using method: RequestMethods = .GET
                      )
    -> AnyPublisher<Model, Error> where Model : Decodable, Model : Encodable {
        
        var innerUrlComponents = urlComponents
        
        if !queryItems.isEmpty {
            innerUrlComponents.queryItems = queryItems
        }
        
        innerUrlComponents.path = innerUrlComponents.path + path
        
        guard let url = innerUrlComponents.url else {
            return Empty<Model, Error>().eraseToAnyPublisher()
        }
        
        
        print("API-PATHS")
        print("-----------")
        print(innerUrlComponents.path)
        print("-----------")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.name
        
        return session.dataTaskPublisher(for: urlRequest)
            .receive(on: RunLoop.main)
            .tryMap { (element) -> Data in
                guard let response = element.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    print("Invalid response")
                    throw ApplicationError.invalidResponse
                }
                
                return element.data
            }
            .decode(type: Model.self, decoder: JSONDecoder())
            .mapError({ (error)  in
                if let error = error as? ApplicationError {
                    return error
                } else {
                    print(error)
                    return ApplicationError.invalidData
                }
            })
            .eraseToAnyPublisher()
    }
    
}
