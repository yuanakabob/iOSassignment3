//
//  APICaller.swift
//  news
//
//  Created by Chuanxu Wang on 18/5/21.
//

import Foundation
import UIKit


final class APICaller {
    static let shared = APICaller()
    
    //potentially addable: country location?
    
    struct Constants {
        static let topHeadLinesURL = URL(string:
                                            "https://newsapi.org/v2/top-headlines?country=AU&apiKey=a70d415768fe4649bf7fe902922a551a"
        )
        
        static let searchUrlString =
            "https://newsapi.org/v2/everything?sortedBy=popularity&apiKey=a70d415768fe4649bf7fe902922a551a&q="
    }
    
    private init() {}
    public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.topHeadLinesURL else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    public func search(with query: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let urltring = Constants.searchUrlString + query
        guard let url = URL(string: urltring) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion ( .failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch {
                    completion (.failure(error))
                }
            }
        }
        task.resume()
    }
}

//Models
struct APIResponse: Codable  {
    let articles: [Article]
}

struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url:String?
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Codable {
    let name: String
}
