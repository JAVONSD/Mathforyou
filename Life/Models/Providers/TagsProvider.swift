//
//  TagsProvider.swift
//  Life
//
//  Created by Shyngys Kassymov on 10.03.2018.
//  Copyright © 2018 Shyngys Kassymov. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import RxSwift
import RxCocoa

class TagsProvider {

    static let disposeBag = DisposeBag()

    static let isLoadingTagsSubject = BehaviorRelay<Bool>(value: false)
    static let tagsSubject = BehaviorRelay<[Tag]>(value: [])

    private static let referencesProvider = MoyaProvider<ReferencesService>(
        plugins: [
            AuthPlugin(tokenClosure: {
                return User.current.token
            })
        ]
    )

    // MARK: - Methods

    public static func getTags() {
        isLoadingTagsSubject.accept(true)

        returnTagsFromCache()

        referencesProvider
            .rx
            .request(.tags)
            .filterSuccessfulStatusCodes()
            .subscribe { response in
                self.isLoadingTagsSubject.accept(false)
                switch response {
                case .success(let json):
                    if let tags = try? JSONDecoder().decode([Tag].self, from: json.data) {
                        self.tagsSubject.accept(tags)
                        self.updateTagsCache(tags)
                    }
                case .error:
                    print("Error to load tags")
                }
            }
            .disposed(by: disposeBag)
    }

    private static func returnTagsFromCache() {
        do {
            let realm = try App.Realms.default()
            let cachedTagObjects = realm.objects(TagObject.self)
            let cachedTags = Array(cachedTagObjects).map { Tag(managedObject: $0) }

            self.isLoadingTagsSubject.accept(false)
            self.tagsSubject.accept(cachedTags)
        } catch let error as NSError {
            print("Failed to access the Realm database with error - \(error.localizedDescription)")
        }
    }

    private static func updateTagsCache(_ tagItems: [Tag]) {
        DispatchQueue.global().async {
            do {
                let realm = try App.Realms.default()
                realm.beginWrite()
                for tag in tagItems {
                    realm.add(tag.managedObject(), update: true)
                }
                for tagObject in realm.objects(TagObject.self).reversed() {
                    if !tagItems.contains(Tag(managedObject: tagObject)),
                        let tagObjectToDelete = realm.object(
                            ofType: TaskObject.self,
                            forPrimaryKey: tagObject.id) {
                        realm.delete(tagObjectToDelete)
                    }
                }
                try realm.commitWrite()
            } catch {
                print("Failed to access the Realm database")
            }
        }
    }

}
