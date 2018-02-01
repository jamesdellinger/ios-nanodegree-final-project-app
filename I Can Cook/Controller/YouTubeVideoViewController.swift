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
        youtubePlayer.delegate = self
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        // Test connection to www.youtube.com and display an error alert pop-up
        // if network connection is unsuccessful.
        testNetworkConnectionToYouTube()
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
        youtubePlayer.playVideo()
    }
}

// MARK: Test network connection to Youtube.com

extension YouTubeVideoViewController {
    
    func testNetworkConnectionToYouTube() {
        
        do {
            Network.reachability = try Reachability(hostname: "www.youtube.com")
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
                // Display alert pop-up to user if unable to make network
                // connection to YouTube.
                displayConnectionErrorAlert()
            } catch {
                print(error)
                displayConnectionErrorAlert()
            }
        } catch {
            print(error)
            displayConnectionErrorAlert()
        }
    }
}

// MARK: Connection Error Alert

extension YouTubeVideoViewController {
    
    func displayConnectionErrorAlert() {

        let alert = UIAlertController(title: "Connection Error", message: "Unable to connect to YouTube to play this video.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Default action"), style: .`default`, handler: { _ in
            print("The \"Connection Error\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
