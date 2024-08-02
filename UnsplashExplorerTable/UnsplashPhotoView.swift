//
//  UnsplashPhotoView.swift
//  UnsplashExplorerTable
//
//  Created by tanya on 07/02/2024.
//

import SwiftUI
import SDWebImageSwiftUI
struct UnsplashPhotoView: View {
    let url: URL?
    
    var body: some View {
        AnimatedImage(url: url)
            .resizable()
            .scaledToFit()
            .frame(width: .infinity, height: .infinity)
    }
}

#Preview {
    UnsplashPhotoView(url: nil)
}
