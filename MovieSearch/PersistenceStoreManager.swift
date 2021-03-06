//
//  PersistenceStoreManager.swift
//  MovieSearch
//
//  Created by Alex Paul on 12/15/17.
//  Copyright © 2017 Alex Paul. All rights reserved.
//

import UIKit

class PersistentStoreManager {
    
    static let kPathname = "Favorites.plist"
    
    // singleton
    private init(){}
    static let manager = PersistentStoreManager()
    
    private var favorites = [Favorite]() {
        didSet{
            saveFavorites()
        }
    }
    
    // returns documents directory path for app sandbox
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // /documents/Favorites.plist
    // returns the path for supplied name from the dcouments directory
    func dataFilePath(withPathName path: String) -> URL {
        return PersistentStoreManager.manager.documentsDirectory().appendingPathComponent(path)
    }
    
    // save to documents directory
    func saveFavorites() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(favorites)
            try data.write(to: dataFilePath(withPathName: PersistentStoreManager.kPathname), options: .atomic)
        } catch {
            print("encoding error: \(error.localizedDescription)")
        }
        print("\n==================================================")
        print(documentsDirectory())
        print("===================================================\n")
    }
    
    // load from documents directory
    func load() {
        // where are we loading from????
        let path = dataFilePath(withPathName: PersistentStoreManager.kPathname)
        let decoder = PropertyListDecoder()
        do {
            let data = try Data.init(contentsOf: path)
            favorites = try decoder.decode([Favorite].self, from: data)
        } catch {
            print("decoding error: \(error.localizedDescription)")
        }
    }
    
    // does 2 tasks:
    // 1. stores image in documents folder
    // 2. appends favorite item to array 
    func addToFavorites(movie: Movie, andImage image: UIImage) {
        // checking for uniqueness
        let indexExist = favorites.index{ $0.trackId == movie.trackId }
        if indexExist != nil { print("FAVORITE EXIST"); return }
        
        // packing data from image
        guard let imageData = UIImagePNGRepresentation(image) else { return }
        
        // writing and saving to documents folder
        
        // 1) save image from favorite photo
        let imageURL = PersistentStoreManager.manager.dataFilePath(withPathName: "\(movie.trackId)")
        do {
            try imageData.write(to: imageURL)
        } catch {
            print("image saving error: \(error.localizedDescription)")
        }
        
        // 2) save favorite object
        let newFavorite = Favorite.init(collectionName: movie.collectionName, collectionId: movie.collectionId, trackId: movie.trackId, longDescription: movie.longDescription)
        favorites.append(newFavorite)
    }
    
    func getFavorites() -> [Favorite] {
        return favorites
    }

}
