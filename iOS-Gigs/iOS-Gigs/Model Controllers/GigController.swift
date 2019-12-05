//
//  GigController.swift
//  iOS-Gigs
//
//  Created by Patrick Millet on 12/4/19.
//  Copyright © 2019 Patrick Millet. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case badAuth
    case noAuth
    case otherError
    case badData
    case noDecode
}

extension Date {
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

class GigController {
    
    private let baseURL = URL(string: "https://lambdagigs.vapor.cloud/api")!
    
    var bearer: BearerToken?
    var gigs: [Gig] = []
    func signUp(with user: User, completion: @escaping (Error?) -> ()) {
        
        let signUpUrl = baseURL.appendingPathComponent("users/signup")
        
        var request = URLRequest(url: signUpUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (_, response, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            DispatchQueue.main.async {
            completion(nil)
            }
        }.resume()
    }
    
    func signIn(with user: User, completion: @escaping (Error?) -> ()) {
        
        let signInUrl = baseURL.appendingPathComponent("users/login")
        
        var request = URLRequest(url: signInUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
        } catch {
            print("Error encoding user object \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(NSError(domain: "", code: response.statusCode, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(NSError())
                return
            }
            
            let decoder = JSONDecoder()
            do {
                self.bearer = try decoder.decode(BearerToken.self, from: data)
            } catch {
                print("Error decoding bearer token \(error)")
                completion(error)
                return
            }
            
            DispatchQueue.main.async {
            completion(nil)
            }
        }.resume()
    }
    
    func fetchGigs(completion: @escaping (Result<[Gig], NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noAuth))
            return
        }

        let gigURL = baseURL.appendingPathComponent("gigs")

        var request = URLRequest(url: gigURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse,
            response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }

            if let error = error {
                print("Error receiving gig data: \(error)")
                completion(.failure(.otherError))
            }

            guard let data = data else {
                completion(.failure(.badData))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let gigs = try decoder.decode([Gig].self, from: data)
                self.gigs = gigs
                completion(.success(gigs))
            } catch {
                print("Error decoding [Gig] object: \(error)")
                completion(.failure(.noDecode))
            }
        }.resume()
    }

    func add(gig: Gig, completion: @escaping (Error?) -> ()) {
        guard let bearer = bearer else {
            print("No Auth")
            completion(nil)
            return
        }

        let gigURL = baseURL.appendingPathComponent("gigs")

        var request = URLRequest(url: gigURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let newGig = try encoder.encode(gig)
            request.httpBody = newGig
        } catch {
            print("Error encoding gig object: \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let response = response as? HTTPURLResponse,
            response.statusCode == 401 {
                print("Bad Auth")
                completion(nil)
                return
            }

            if let error = error {
                print("Error receiving gig data: \(error)")
                completion(nil)
                return
            } else {
                self.fetchGigs { result in
                }
            }
        }.resume()
    }
}
