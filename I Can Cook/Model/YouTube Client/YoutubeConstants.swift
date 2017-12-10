//
//  YoutubeConstants.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/8/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation

// MARK: YoutubeClient (Constants)

// Example of YouTube API search query GET request formatting
// https://www.googleapis.com/youtube/v3/search?key=AIzaSyDo7h-vPHPqz6XZPz1-LBVwvVEn9aqV29Y&type=video&q=surfing&maxResults=50&part=snippet

extension YoutubeClient {

    struct Constants {
        
        // MARK: Youtube
        struct Youtube {
            static let APIScheme = "https"
            static let APIHost = "www.googleapis.com"
            static let APIPath = "/youtube/v3/search"
        }
        
        // MARK: Youtube Parameter Keys
        struct YoutubeParameterKeys {
            static let APIKey = "key"
            static let ResultType = "type"
            static let SearchQuery = "q"
            static let NumberOfResults = "maxResults"
            static let SearchResourceProperty = "part"
        }
        
        // MARK: Youtube Parameter Values
        struct YoutubeParameterValues {
            static let APIKey = "AIzaSyDo7h-vPHPqz6XZPz1-LBVwvVEn9aqV29Y"
            static let ResultType = "video"
            static let NumberOfResults = "50"
            static let SearchResourceProperty = "snippet"
        }
        
        // MARK: Youtube Response Keys
        struct YoutubeResponseKeys {
            static let SearchResultItems = "items"
            static let ResultId = "id"
            static let VideoId = "videoId"
            static let Snippet = "snippet"
            static let VideoTitle = "title"
            static let VideoDescription = "description"
            static let VideoThumbnails = "thumbnails"
            static let DefaultQualityThumbnail = "default"
            static let HighQualityThumbnail = "high"
            static let ThumbnailUrl = "url"
        }
    }
}
