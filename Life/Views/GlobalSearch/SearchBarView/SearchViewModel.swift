//
//  SearchViewModel.swift
//  SearchBar
//
//  Created by huangmian on 2018/7/26.
//  Copyright © 2018年 hm. All rights reserved.
//
import Foundation

class SearchViewModel: NSObject {
    let maxHistoryCount = 20
    let searchKey = "SearchHistory"
 
    func getSearchHistory() -> [String] {
        var historys = (UserDefaults.standard.object(forKey: searchKey) as? [String]) ?? [String]()
        if historys.count > maxHistoryCount {
            historys = Array(historys[0..<maxHistoryCount])
            saveSearchHistory(histroys: historys)
        }
        return historys
    }
    
    func saveSearchHistory(histroys: [String]) {
        UserDefaults.standard.set(histroys, forKey: searchKey)
        UserDefaults.standard.synchronize()
    }
    
    func clearSearchHistory() {
        UserDefaults.standard.set(nil, forKey: searchKey)
        UserDefaults.standard.synchronize()
    }
    
    
}
