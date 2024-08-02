//
//  ContentView.swift
//  UnsplashExplorerTable
//
//  Created by tanya on 07/02/2024.
//

import SwiftUI
import SDWebImageSwiftUI
struct UnsplashPhotosView: View {
   
    @ObservedObject var viewModel: UnsplashPhotosViewModel
    @State var search: String = ""
  
    init(viewModel: UnsplashPhotosViewModel) {
        self.viewModel = viewModel
    }
  
    var body: some View {
        NavigationView {
            VStack {

                HStack(spacing: 0) {
                    TextField("Search...", text: $search)
                        .onSubmit {
                            viewModel.clearPhotos()
                            viewModel.loadPhotos(search: search, page: 1)
                        }
                }
                .padding()
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(Array(zip(viewModel.photos.indices, viewModel.photos)), id: \.0) { i, photo in
                            NavigationLink {
                                UnsplashPhotoView(url: photo.urls.url)
                            } label: {
                                HStack {
                                    AnimatedImage(url: photo.urls.url)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                
                                    Text(photo.description ?? "")
                                    Spacer()
                                }
                                .padding(.vertical)
                                .onAppear {
                                    if i == viewModel.photos.count - 1 {
                                        viewModel.loadPhotos(search: search, page: viewModel.nextPage)
                                    }
                                }
                            }                        }
                    }
                    .padding(.horizontal)
                }
                
            }
            .background(.gray.opacity(0.1))
            .navigationTitle("Unsplash photos")
            .toolbarTitleDisplayMode(.inline)
        }
    
        //.ignoresSafeArea(.all)

        //.padding()
    }
}

#Preview {
    UnsplashPhotosView(viewModel:  UnsplashPhotosViewModel(service: PhotosService()))
}
