//
//  UnsplashExplorerTableTests.swift
//  UnsplashExplorerTableTests
//
//  Created by tanya on 07/02/2024.
//

import XCTest
@testable import UnsplashExplorerTable

final class UnsplashExplorerTableTests: XCTestCase {

    func testLoadPhotos() async throws  {
        let service = PhotosService()
        
        let photos = try await service.loadPhotos(search: "home", page: 1)
        
        XCTAssertEqual(photos.count, 10)
    }

}
