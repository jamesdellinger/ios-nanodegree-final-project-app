//
//  YouTubeVideoViewController.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/10/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

class YouTubeVideoViewController: UIViewController {
    
    // MARK: Properties
    
    var youtubeVideo: YoutubeVideo?
    
    // MARK: Outlets
    
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var youtubePlayer: YTPlayerView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Unhide the navigation bar so user can tap to go back
        // to the parent view controller.
        navigationController?.isNavigationBarHidden = false
        
        // Set the delegate for the YTPlayerViewDelegate protocol.
        self.youtubePlayer.delegate = self
        
        if let youtubeVideo = youtubeVideo {
            
            // Player variables dictionary. "playsinline" key with value 1 tells player to play
            // in-line inside the view controller.
            let playerVars = ["playsinline":1]
            
            // Play the video.
            youtubePlayer.load(withVideoId: youtubeVideo.videoId, playerVars: playerVars)
            
            // Set video title label text to title of the YouTube video
            videoTitleLabel.text = youtubeVideo.title
        }
    }
    
    // MARK: Add YouTube video to recipes
    
    // When user taps the "Add to Your Recipes" button, modally present the Add Recipe View Controller.
    // This segue's identifier in storyboard is "AddRecipeFromYouTubeVideo"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddRecipeFromYouTubeVideo" {
            let destinationController = segue.destination as! AddRecipeViewController
            
            // Set the YoutubeVideo property of the Add Recipe VC to the video being
            // played here.
            destinationController.youtubeVideo = youtubeVideo
        }
    }
}

// MARK: YTPlayerViewDelegate

extension YouTubeVideoViewController: YTPlayerViewDelegate {
    
    // Necessary for YouTube Video playback to initiate
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.youtubePlayer.playVideo()
    }
}
