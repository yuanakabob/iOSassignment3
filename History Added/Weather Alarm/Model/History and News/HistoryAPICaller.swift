//
//  APICaller.swift
//  news
//
//  Created by Chuanxu Wang on 18/5/21.
//

import Foundation
import UIKit


final class HistoryAPICaller {
    static let shared = HistoryAPICaller()
    
    struct Constants {
        static let topHeadLinesURL = URL(string:
                                            "http://history.muffinlabs.com/date"
        )
        
        static let searchUrlString =
            "http://history.muffinlabs.com/date"
    }
    
    private init() {}
    public func getTopStories(completion: @escaping (Result<[Events], Error>) -> Void) {
        
        guard let html = Constants.topHeadLinesURL else {
            
            return
            
        }
        
        let task = URLSession.shared.dataTask(with: html) { data, _, error in
            
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(HistoryAPIResponse.self, from: data)
                    print("Articles: \(result.data.Events.count)")
                    completion(.success(result.data.Events))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    public func search(with query: String, completion: @escaping (Result<[Events], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        let urltring = Constants.searchUrlString + query
        guard let html = URL(string:urltring) else {
            return
        }
        let task = URLSession.shared.dataTask(with: html) { data, _, error in
            if let error = error {
                completion ( .failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(HistoryAPIResponse.self, from: data)
                    print("Articles: \(result.data.Events.count)")
                    completion(.success(result.data.Events))
                }
                catch {
                    completion (.failure(error))
                }
            }
        }
        task.resume()
    }
}

struct HistoryAPIResponse: Codable  {
    let data: HistoryDataAPIResponse }

struct HistoryDataAPIResponse: Codable  {
    let Events: [Events] }

struct Events: Codable {
    let year: String
    let text: String
    let html: String
    let no_year_html: String
    let links: [Links]
}

struct Links: Codable {
    let link: String
}
