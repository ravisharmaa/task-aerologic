//
//  PersonViewModel.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 17/07/2021.
//

import Foundation
import Combine

enum HudTexts: CustomStringConvertible {
    case online
    case offline
    
    var description: String {
        switch self {
        case .online:
            return "Loading From Internet...."
        default:
            return "Loading From Local Storage...."
        }
    }
}

class PersonListViewModel: Hashable {
    
    static func == (lhs: PersonListViewModel, rhs: PersonListViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    let person: Person
    
    let id: UUID = UUID()
    
    var name: String {
        if let lastName = person.lastName, let firstName = person.firstName {
            return firstName + " " + lastName
        }
        return "N/A"
    }
    
    var imageURL: URL {
        if let url = person.pictureURL {
            return URL(string: url)!
        }
        return URL(string: "https://google.com")!
    }
    
    var age: String {
        if let age = person.age {
            return age.description
        }
        
        return "N/A"
    }
    
    var gender: String {
        if let gender = person.gender {
            return gender.capitalizingFirstLetter()
        }
        
        return "N/A"
    }
    
    var jobs: String {
        if let job = person.job {
            let role = job.map({$0.role})
            return role.joined(separator: ",")
        }
        return String()
    }
    
    var education: String {
        if let education = person.education {
            let degree = education.map({$0.degree})
            return degree.joined(separator: ",")
        }
        return String()
    }
    
    init(person: Person) {
        self.person = person
    }
}

class PersonViewModel {
    
    private (set) var subscription: Set<AnyCancellable> = []
    
    @Published var personListViewModel: [PersonListViewModel] = []
    
    var progressHudSubject: PassthroughSubject = PassthroughSubject<(Bool, HudTexts), Never>()
    
    let request: Requestable
    
    // MARK:- Constructor Injection of Request.
    
    init(request: Requestable = Request()) {
        self.request = request
    }
    
    // MARK:- Fetch Data
    func fetchData() {
        
        struct IntermediateModel: Codable, Hashable {
            let data: [Person]
        }
        
        if Reachability.isConnectedToNetwork() {
            self.progressHudSubject.send((true, .online))
            request.load(for: IntermediateModel.self, path: AppConstants.requestURL, queryItems: [], using: .GET)
                .sink { _ in
                    //
                } receiveValue: { model in
                    // move to background queue for saving data
                    self.personListViewModel = model.data.map({PersonListViewModel(person: $0)})
                    QueueService.backgroundQueue.async { [self] in
                        do {
                            try self.saveToDB(person: model.data)
                        } catch let error {
                            print(error)
                        }
                    }
                    
                    self.progressHudSubject.send((false, .online))
                }
                .store(in: &subscription)
        } else {
            self.progressHudSubject.send((true, .offline))
            DatabaseManager.shared.connection?.readPublisher(receiveOn: RunLoop.main, value: { db in
                return try Person.fetchAll(db)
            }).receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                //
            }, receiveValue: { person in
                self.personListViewModel = person.map({PersonListViewModel(person: $0)})
                self.progressHudSubject.send((false, .offline))
            }).store(in: &subscription)
        }
    }
    
    func saveToDB(person: [Person]) throws {
        let _ = try DatabaseManager.shared.connection?.write({ db in
            try db.execute(sql: "DELETE FROM employees")
            try person.forEach { person in
                let jsonEncoder = JSONEncoder()
                let job = try jsonEncoder.encode(person.job)
                let education = try jsonEncoder.encode(person.education)
                try db.execute(sql: "INSERT into employees(uuid,firstname, lastname, age, gender, picture, job, education) VALUES(?, ?,?,?,?,?,?,?)",
                               arguments: [ person.id.uuidString, person.firstName, person.lastName, person.age, person.gender, person.pictureURL, job, education
                               ])
            }
        })
        
    }
    
    func loadFromFile() {
        struct IntermediateModel: Codable, Hashable {
            let data: [Person]
        }
        let model = Utilities.loadJsonFrom("Offline", model: IntermediateModel.self)
        
        if let model = model {
            self.personListViewModel = model.data.map({PersonListViewModel(person: $0)})
        }
    }
}
