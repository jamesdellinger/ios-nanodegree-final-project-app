//
//  YoutubeClient.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/8/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation

class YoutubeClient: NSObject {
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> YoutubeClient {
        struct Singleton {
            static var sharedInstance = YoutubeClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Shared session
    
    let session = URLSession.shared
    
    // MARK:
    
    // Returns an array of up to 50 YouTube video objects, representing the search
    // results returned from the YouTube video search API for a particular
    // search query. Each YouTube video object has properties for a video's videoId, 
    // title, description, as well as URLs for low, medium, and high quality
    // thumbnails.
    func getYoutubeVideos(searchQuery: String, completionHandlerForGetYoutubeVideos: @escaping (_ youtubeVideoArray: [YoutubeVideo]?, _ success: Bool, _ errorMessage: String?) -> Void) {
        
        // Method parameters for YouTube API call.
        let methodParameters =
            [
                Constants.YoutubeParameterKeys.APIKey: Constants.YoutubeParameterValues.APIKey,
                Constants.YoutubeParameterKeys.ResultType: Constants.YoutubeParameterValues.ResultType,
                Constants.YoutubeParameterKeys.SearchQuery: searchQuery,
                Constants.YoutubeParameterKeys.NumberOfResults: Constants.YoutubeParameterValues.NumberOfResults,
                Constants.YoutubeParameterKeys.SearchResourceProperty: Constants.YoutubeParameterValues.SearchResourceProperty
        ]

        // First, retrieve the JSON data returned by the YouTube API for a particulary
        // search query:
        getYoutubeSearchResultsDictionary(searchQuery: searchQuery, methodParameters: methodParameters) { (searchResultsDictionary, success, errorMessage) in
            
            // If Json data was successfully received from YouTube's server, and successfully parsed into
            // a dictionary data structure that Swift can understand, it is now time to convert this
            // search results dictionary into an array of YoutubeVideo objects that will be sent to
            // this method's completion handler.
            if success {
                self.convertToYoutubeVideoArray(searchResultsDictionary: searchResultsDictionary!) { (youtubeVideoArray, success, errorMessage) in
                    
                    // If successful, we have been able to create an array with at least one YoutubeVideo object.
                    // We will send this array to the completion handler.
                    if success {
                        completionHandlerForGetYoutubeVideos(youtubeVideoArray, true, nil)
                    } else {
                        // If an error occurred, send the error message string to the completion handler.
                        completionHandlerForGetYoutubeVideos(nil, false, errorMessage)
                    }
                }
            } else {
                // If an error occurred, send the error message string to the completion handler.
                completionHandlerForGetYoutubeVideos(nil, false, errorMessage)
            }
        }
    }
    
    // Create and execute a YouTube data task. Parse the data into a dictionary formatted data structure
    // that Swift understands.
    private func getYoutubeSearchResultsDictionary(searchQuery: String, methodParameters: [String:String], completionHandlerForGetYoutubeSearchResultsDictionary: @escaping (_ searchResultsDictionary: [String: AnyObject]?, _ success: Bool, _ errorMessage: String?) -> Void) {
        
        // Create the request.
        let request = URLRequest(url: youtubeUrlFromParameters(methodParameters))
        
        // Make the network request.
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // Parse the data and response from the YouTube API task.
            self.youtubeTaskAndDataParsingHelper(data: data, response: response, error: error) { (searchResultsDictionary, success, errorString) in
                
                // If successful, send the dictionary from the successfully parsed data to the completion handler.
                if success {
                    completionHandlerForGetYoutubeSearchResultsDictionary(searchResultsDictionary, true, nil)
                } else {
                    
                    // If an error had occurred, send the string describing the error to the completion handler.
                    completionHandlerForGetYoutubeSearchResultsDictionary(nil, false, errorString)
                }
            }
        }
        
        // Start the task.
        task.resume()
    }
    
    // Parse a dictionary using YouTube response key constants, in order to convert the dictionary's
    // contents into an array of YoutubeVideo objects.
    private func convertToYoutubeVideoArray(searchResultsDictionary: [String:AnyObject], completionHandlerForConvertToYoutubeVideoArray: @escaping (_ youtubeVideoArray: [YoutubeVideo]?, _ success: Bool, _ errorMessage: String?) -> Void) {
        
        // The array of YoutubeVideo objects that will be sent to the completion handler.
        var youtubeVideoArray = [YoutubeVideo]()
        
        // If an error occurs, send its description to the completion handler.
        func displayError(_ errorString: String) {
            completionHandlerForConvertToYoutubeVideoArray(nil, false, errorString)
        }
        
        /* GUARD: Is the "items" key in  the searchResultsDictionary? */
        guard let videoResultsArray = searchResultsDictionary[Constants.YoutubeResponseKeys.SearchResultItems] as? [[String: AnyObject]] else {
            displayError("Cannot find key \"\(Constants.YoutubeResponseKeys.SearchResultItems)\" in the results from YouTube.")
            return
        }
        
        // Convert each video result entry into a YoutubeVideo object and append the array of YoutubeVideo
        // objects that will be sent to the completion handler.
        for result in videoResultsArray {
            if let youtubeVideo = convertResultEntryToYoutubeVideoObject(resultEntry: result) {
                youtubeVideoArray.append(youtubeVideo)
            }
        }
        
        /*
         GUARD: Is there at least one YoutubeVideo in the array of YoutubeVideo objects that will
         be sent to the completion handler?
         */
        guard youtubeVideoArray.count > 0 else {
            displayError("Cannot find any video information in the results from YouTube.")
            return
        }
        
        // If none of the GUARD statements have been tripped, we now have an array that contains at least
        // one YoutubeVideo object. We will send this array to the completion handler here.
        completionHandlerForConvertToYoutubeVideoArray(youtubeVideoArray, true, nil)
    }
    
    // Parse the dictionary of info for one YouTube video in order to intialize a
    // YoutubeVideo object as defined by the YoutubeVideo struct.
    private func convertResultEntryToYoutubeVideoObject(resultEntry: [String:AnyObject]) -> YoutubeVideo? {
        
        // Ensure that all properties needed to initialize a YoutubeVideo object are present
        // in the dictionary returned from YouTube for a particular video:
        
        /* GUARD: Is the "id" key in the resultEntry? */
        guard let resultIdDictionary = resultEntry[Constants.YoutubeResponseKeys.ResultId] as? [String:AnyObject] else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.ResultId)\" in \(resultEntry)")
            return nil
        }
        
        /* GUARD: Is the "videoId" key in the resultIdDictionary? */
        guard let videoId = resultIdDictionary[Constants.YoutubeResponseKeys.VideoId] as? String else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.VideoId)\" in \(resultIdDictionary)")
            return nil
        }
        
        /* GUARD: Is the "snippet" key in the resultEntry? */
        guard let snippetDictionary = resultEntry[Constants.YoutubeResponseKeys.Snippet] as? [String:AnyObject] else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.Snippet)\" in \(resultEntry)")
            return nil
        }
        
        /* GUARD: Is the "title" key in the snippetDictionary? */
        guard let title = snippetDictionary[Constants.YoutubeResponseKeys.VideoTitle] as? String else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.VideoTitle)\" in \(snippetDictionary)")
            return nil
        }
        
        /* GUARD: Is the "description" key in the snippetDictionary? */
        guard let description = snippetDictionary[Constants.YoutubeResponseKeys.VideoDescription] as? String else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.VideoDescription)\" in \(snippetDictionary)")
            return nil
        }
        
        /* GUARD: Is the "thumbnails" key in the snippetDictionary? */
        guard let thumbnailsDictionary = snippetDictionary[Constants.YoutubeResponseKeys.VideoThumbnails] as? [String:AnyObject] else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.VideoThumbnails)\" in \(snippetDictionary)")
            return nil
        }
        
        /* GUARD: Is the "default" key in the thumbnailsDictionary? */
        guard let defaultQualityThumbnailDictionary = thumbnailsDictionary[Constants.YoutubeResponseKeys.DefaultQualityThumbnail] as? [String:AnyObject] else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.DefaultQualityThumbnail)\" in \(thumbnailsDictionary)")
            return nil
        }
        
        /* GUARD: Is the "high" key in the thumbnailsDictionary? */
        guard let highQualityThumbnailDictionary = thumbnailsDictionary[Constants.YoutubeResponseKeys.HighQualityThumbnail] as? [String:AnyObject] else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.HighQualityThumbnail)\" in \(thumbnailsDictionary)")
            return nil
        }
        
        /* GUARD: Is the "url" key in the defaultQualityThumbnailDictionary? */
        guard let defaultQualityThumbnailUrl = defaultQualityThumbnailDictionary[Constants.YoutubeResponseKeys.ThumbnailUrl] as? String else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.ThumbnailUrl)\" in \(defaultQualityThumbnailDictionary)")
            return nil
        }
        
        /* GUARD: Is the "url" key in the highQualityThumbnailDictionary? */
        guard let highQualityThumbnailUrl = highQualityThumbnailDictionary[Constants.YoutubeResponseKeys.ThumbnailUrl] as? String else {
            print("Cannot find key \"\(Constants.YoutubeResponseKeys.ThumbnailUrl)\" in \(highQualityThumbnailDictionary)")
            return nil
        }
        
        // If none of the above GUARD statements have been triggered, we have safely extracted
        // all five properties needed to initialize a YoutubeVideo object, and can initialize
        // and then return it.
        let youtubeVideo = YoutubeVideo(title: title, videoId: videoId, description: description, defaultQualityThumbnailUrl: defaultQualityThumbnailUrl, highQualityThumbnailUrl: highQualityThumbnailUrl)
        
        return youtubeVideo
    }
}

// MARK: YoutubeClient Helper Methods

extension YoutubeClient {

    // Helper method for creating a URL from parameters
    private func youtubeUrlFromParameters(_ parameters: [String:String]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Youtube.APIScheme
        components.host = Constants.Youtube.APIHost
        components.path = Constants.Youtube.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // YouTube API task data parsing helper method
    private func youtubeTaskAndDataParsingHelper(data: Data?, response: URLResponse?, error: Error?, completionHandlerForYoutubeTaskAndDataParsingHelper: @escaping (_ searchResultsDictionary: [String:AnyObject]?, _ success: Bool, _ errorString: String?) -> Void) {
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            let errorString = "There was an error with your request: \(String(describing: error))"
            completionHandlerForYoutubeTaskAndDataParsingHelper(nil, false, errorString)
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            let errorString = "Your request returned a status code other than 2xx!"
            completionHandlerForYoutubeTaskAndDataParsingHelper(nil, false, errorString)
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            let errorString = "No data was returned by the request!"
            completionHandlerForYoutubeTaskAndDataParsingHelper(nil, false, errorString)
            return
        }
        
        // Parse the data.
        let parsedResult: [String:AnyObject]!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        } catch {
            let errorString = "Could not parse the data as JSON: '\(data)'"
            completionHandlerForYoutubeTaskAndDataParsingHelper(nil, false, errorString)
            return
        }
        
        // If data returned by YouTube API is successfully parsed, send this parsed
        // (the searchResultsDictionary) to the completion handler.
        completionHandlerForYoutubeTaskAndDataParsingHelper(parsedResult, true, nil)
    }
}


