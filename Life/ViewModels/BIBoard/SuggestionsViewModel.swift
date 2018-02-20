//
//  SuggestionsViewModel.swift
//  Life
//
//  Created by Shyngys Kassymov on 19.02.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import IGListKit

class SuggestionsViewModel: NSObject, ListDiffable {
    var suggestions = [SuggestionItemViewModel]()
    var minimized = true

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let object = object as? SuggestionsViewModel {
            return self == object
        }
        return false
    }
}

extension SuggestionsViewModel: Mockable {
    typealias T = SuggestionsViewModel

    static func sample() -> SuggestionsViewModel {
        let sample = SuggestionsViewModel()

        for _ in 0..<2 {
            let json = [
                "title": "Test suggestion"
            ]
            if let suggestion = try? JSONDecoder().decode(Suggestion.self, from: json.toJSONData()) {
                let item = SuggestionItemViewModel(suggestion: suggestion)
                sample.suggestions.append(item)
            }
        }

        return sample
    }
}

class SuggestionItemViewModel: NSObject, ListDiffable {
    var suggestion: Suggestion

    init(suggestion: Suggestion) {
        self.suggestion = suggestion
    }

    func diffIdentifier() -> NSObjectProtocol {
        return NSString(string: suggestion.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let item = object as? SuggestionItemViewModel {
            return suggestion.id == item.suggestion.id
        }
        return false
    }
}
