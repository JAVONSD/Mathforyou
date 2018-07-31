//
//  GlobalSearch.swift
//  Life
//
//  Created by 123 on 31.07.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import UIKit
import Alamofire

typealias SearchComplete = (Bool) -> Void

class Search {
    enum Category: Int {
        case news = 0
        
        var entityName: String {
            switch self {
            case .news: return ""
       
            }
        }
    }
    
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results( [NewsSearch] )
    }
    
    // variable is private, but only half
    fileprivate(set) var state: State = .notSearchedYet
    
    fileprivate var dataTask: URLSessionDataTask? = nil
}

// MARK: - Networking
extension Search {
    // all the user interface logic has been removed.
    // The purpose of Search is just to perform a search,
    // it should not do any UI stuff. That’s the job of the view controller
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            
            dataTask?.cancel()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            state = .loading
            
            
        }
    }
    
    fileprivate func iTunesURL(searchText: String, category: Category) -> URL {
        let entityName = category.entityName
    
        // method to escape the special characters ((+)(%20) < > )
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString =
            String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@&lang=%@&country=%@",
                   escapedSearchText, entityName)
        
        
        let url = URL(string: urlString)
        print("URL: \(url!)")
        
        return url!
    }
}


// MARK: - Parsing
extension Search {
    
    fileprivate func parse(json data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    fileprivate func parse(dictionary: [String: Any]) -> [NewsSearch] {
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults: [NewsSearch] = []
        for resultDict in array {
            if let resultDict = resultDict as? [String: Any] {
                // Indexing a dictionary always gives you an optional
                var searchResult: NewsSearch?
                if let wrapperType = resultDict["wrapperType"] as? String {
                    // instead of (if 'wrapperType' == "track")
                    wrapperType: switch wrapperType {
                    case "track":
                        searchResult = parse(track: resultDict)
                    case "audiobook":
                        searchResult = parse(audiobook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                    default:
                        break wrapperType
                    }
                    if let result = searchResult {
                        searchResults.append(result)
                    }
                } else if let kind = resultDict["kind"] as? String {
                    kind: switch kind {
                    case "ebook":
                        searchResult = parse(ebook: resultDict)
                    default:
                        break kind
                    }
                }
            }
        }
        return searchResults
    }
    
    fileprivate func parse(track dictionary: [String: Any]) -> NewsSearch {
        let decoder = JSONDecoder()
        let searchResult = try! NewsSearch(from: decoder as! Decoder)
      
        return searchResult
    }
    
    fileprivate func parse(audiobook dictionary: [String: Any]) -> NewsSearch {
        let decoder = JSONDecoder()
        return try! NewsSearch(from: decoder as! Decoder)
    }
    
    fileprivate func parse(software dictionary: [String: Any]) -> NewsSearch {
        let decoder = JSONDecoder()
        return try! NewsSearch(from: decoder as! Decoder)
    }
    
    fileprivate func parse(ebook dictionary: [String: Any]) -> NewsSearch {
        let decoder = JSONDecoder()
        return try! NewsSearch(from: decoder as! Decoder)
    }
}










