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

        for _ in 0..<3 {
            if let jsonPath = Bundle.main.path(forResource: "suggestion_details", ofType: "json"),
                let suggestion = try? JSONDecoder().decode(
                    Suggestion.self,
                    from: Data(contentsOf: URL(fileURLWithPath: jsonPath))) {
                sample.suggestions.append(SuggestionItemViewModel(suggestion: suggestion))
            }
        }

        return sample
    }
}

class SuggestionItemViewModel: NSObject, ListDiffable {
    var suggestion: Suggestion

    var needReloadOnWebViewLoad = true
    var calculatedWebViewHeight: CGFloat = 0

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
