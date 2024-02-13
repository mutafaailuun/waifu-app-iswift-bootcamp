//
//  Home.swift
//  FindYourWaifu
//
//  Created by Jaliel on 10/02/24.
//

import SwiftUI

struct Home: View {
    @StateObject private var photoVM = PhotosViewModel()
    @State var enableDelete: Bool = true
    @State var isShowingDialog: Bool = false
    @State private var selectedPhoto: Photo? = nil
    //    @State private var photos: [Photo] = photoVM.photos
    
    @State private var searchText = ""
    
    
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 100), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(searchResults, id: \.self) { photo in
                        Group {
                            let url = URL(string: photo.image)
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    VStack {
                                        Image(systemName: "photo.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                            .foregroundStyle(Color.white)
                                    }
                                    .frame(width: 100, height: 180)
                                    .background(Color.gray.opacity(0.3))
                                    .scaledToFill()
                                    
                                case .success(let image):
                                    VStack (alignment: .leading) {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        Text(photo.name)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                            .fontWeight(.bold)
                                            .padding(.bottom, 2)
                                        
                                        Text(photo.anime)
                                            .lineLimit(1)
                                        
                                    }
                                    .font(.system(size: 16))
                                    
                                    
                                case .failure(_):
                                    VStack {
                                        Image(systemName: "photo.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                            .foregroundStyle(Color.white)
                                            .frame(width: 100, height: 100)
                                            .background(ColorUtility.randomColor())
                                            .cornerRadius(10)
                                        
                                        Text(photo.name)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                            .fontWeight(.bold)
                                            .padding(.bottom, 2)
                                        
                                        Text(photo.anime)
                                            .lineLimit(1)
                                        
                                    }
                                    
                                    
                                @unknown default:
                                    fatalError()
                                }
                            }
                        }
                        .frame(width: 100, height: 180)
                        .cornerRadius(10)
                        .padding(10)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .sheet(isPresented: $photoVM.showOptions) {
                            Group {
                                let defaultText = "You are about to share this items"
                                
                                if let imageToShare = photoVM.imageToShare {
                                    ActivityView(activityItems: [defaultText, imageToShare])
                                } else {
                                    ActivityView(activityItems: [defaultText])
                                }
                            }
                            .presentationDetents([.medium, .large])
                        }
                        .contextMenu {
                            Button {
                                Task {
                                    await photoVM.prepareImageAndShowSheet(from: photo.image)
                                }
                                
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            
                            Button {
                                selectedPhoto = photo
                                isShowingDialog.toggle()
                            }  label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                        }
                        .confirmationDialog(
                            "Are you sure you want to delete your waifu?",
                            isPresented: $isShowingDialog,
                            titleVisibility: .visible
                        ) {
                            Button("Yes, sure!", role: .destructive) {
                                if let itemToDelete = selectedPhoto {
                                    photoVM.deleteItem(itemToDelete)
                                }
                            }
                            
                            Button("Cancel", role: .cancel) {
                                isShowingDialog = false
                            }
                        }
                    message: {
                        Text("This action cannot be undone!")
                    }
                        
                        
                    }
                }
                
            }
            .navigationTitle("Waifu App")
            
        }
        .task {
            await photoVM.fetchPhotos()
        }
        .navigationTitle("Waifu App")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Looking for waifu?"
        )
        
        .overlay {
            if searchResults.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        
        
    }
    
    var searchResults: [Photo] {
        
        guard !searchText.isEmpty else { return photoVM.photos }
        return photoVM.photos.filter {
            $0.name.lowercased().contains(searchText.lowercased()) || $0.anime.lowercased().contains(searchText.lowercased())
        }
    }
    
}

#Preview {
    Home()
}

@ViewBuilder
func waitView() -> some View {
    VStack(spacing: 20) {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(.pink)
        
        Text("fetching image....")
    }
}
