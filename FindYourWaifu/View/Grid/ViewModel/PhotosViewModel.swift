//
//  PhotoViewModel.swift
//  FindYourWaifu
//
//  Created by Jaliel on 10/02/24.
//

import Foundation
import SwiftUI

@MainActor
class PhotosViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var imageToShare: UIImage?
    @Published var showOptions: Bool = false
    //    @Published var isShowingDialog: Bool = false
    @Published var enableDelete: Bool = false
    
    
    func fetchPhotos() async {
        do {
            let loadedPhotos = try await loadPhotos()
            self.photos = loadedPhotos
        } catch {
            print(error)
        }
    }
    
    private func loadPhotos() async throws -> [Photo] {
        
        guard let urlPhotos = URL(string: "https://waifu-generator.vercel.app/api/v1") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: urlPhotos)
        
        let photos = try JSONDecoder().decode([Photo].self, from: data)
        return photos
    }
    
    //downloading image
    func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error downloading image: \(error.localizedDescription)")
            return nil
        }
    }
    
    //preparing show to the sheet
    func prepareImageAndShowSheet(from urlString: String) async {
        imageToShare = await downloadImage(from: urlString)
        showOptions = true
    }
    
    //delete
    func deleteItem(_ items: Photo) {
        guard let index = photos.firstIndex(of: items) else { return }
            photos.remove(at: index)
            print(items.name)
    }
}
