//
//  YoutubeVideo.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/9/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation

struct YoutubeVideo {
    
    // MARK: Properties
    
    let title: String
    let videoId: String
    let description: String
    let defaultQualityThumbnailUrl: String
    let highQualityThumbnailUrl: String
    
    // MARK: Initializer
    
    init(title: String, videoId: String, description: String, defaultQualityThumbnailUrl: String, highQualityThumbnailUrl: String) {
        self.title = title
        self.videoId = videoId
        self.description = description
        self.defaultQualityThumbnailUrl = defaultQualityThumbnailUrl
        self.highQualityThumbnailUrl = highQualityThumbnailUrl
    }
}
