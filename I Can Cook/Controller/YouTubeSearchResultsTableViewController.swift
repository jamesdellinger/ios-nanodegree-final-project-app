//
//  YouTubeSearchResultsTableViewController.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/9/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import UIKit

class YouTubeSearchResultsTableViewController: UIViewController {

    // MARK: Properties
    
    // An array of YoutubeVideo objects. Will be populated with items based on result of
    // a keyword query to the YouTube API.
    var youtubeVideoArray = [YoutubeVideo]()
    
    // The most recent data download task. We keep a reference to it so that it can be
    // canceled every time a new search is performed.
    var searchTask: URLSessionDataTask?
    
    // Overlay that will appear underneath the activity indicator, whenever it begins
    // animating.
    var overlay: UIView?
    
    // The YoutubeVideo object corresponding to the row the user selects, if they select one.
    var selectedYoutubeVideo: YoutubeVideo?
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure tap recognizer, so that tapping outside of search bar
        // text box will dismiss keyboard.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Hide the navigation bar when user arrives at this screen.
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: Dismiss keyboard
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: UIGestureRecognizerDelegate

extension YouTubeSearchResultsTableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return searchBar.isFirstResponder
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension YouTubeSearchResultsTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of rows in table equals number of videos (max of 50) returned from our
        // keyword search query to the YouTube API.
        return youtubeVideoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YoutubeResultTableCell", for: indexPath) as! YouTubeSearchResultsTableViewCell
        
        // The YouTube video for a given cell in the table.
        let youtubeVideo = youtubeVideoArray[indexPath.row]
        
        // Set the YouTube video's title as the cell's label text.
        cell.textLabel?.text = youtubeVideo.title
        
        // Download the YouTube video's default quality thumbnail image and display
        // inside the cell's image view.
        let imageUrl = URL(string: youtubeVideo.defaultQualityThumbnailUrl)
        
        // Image downloading happens on the background thread.
        DispatchQueue.global(qos: .background).async {
            if let imageData = try? Data(contentsOf: imageUrl!) {
                
                // If image data downloaded successfully, conver to
                // a UIImage and display inside cell's imageview.
                performUIUpdatesOnMain {
                    cell.tableCellImageView?.image = UIImage(data: imageData)
                }
            } else {
                print("Unable to download default quality thumbnail image for video \"\(youtubeVideo.title)\" from URL: \(imageUrl!)")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // YoutubeVideo object corresponding to the row the user selected.
        selectedYoutubeVideo = youtubeVideoArray[indexPath.row]
        
        // Get the destination controller
        let destinationController = self.storyboard!.instantiateViewController(withIdentifier: "YouTubeVideoViewController") as! YouTubeVideoViewController
        
        // Set the YoutubeVideo object property of the destination controller to
        // the YoutubeVideo that corresponds to the table row selected by the user.
        destinationController.youtubeVideo = selectedYoutubeVideo
        
        // Push the destination view controller
        navigationController?.pushViewController(destinationController, animated: true)
    }
}

extension YouTubeSearchResultsTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Cancel the previous task (if it exists) whenever a new search is performed
        if let task = searchTask {
            task.cancel()
            
            // Also hide the activity indicator and gray overlay, in case they were being displayed.
            hideActivityIndicator()
        }
        
        if let searchQuery = searchBar.text {
            
            // Display the activity indicator.
            performUIUpdatesOnMain {
                self.displayActivityIndicator()
            }
            
            YoutubeClient.sharedInstance().getYoutubeVideos(searchQuery: searchQuery) { (youtubeVideoArray, success, errorMessage) in
                
                // If we successfully have an array of YoutubeVideo objects, set this view
                // controller's youtubeVideoArray property equal to the array returned by
                // the above method call.
                if success {
                    self.youtubeVideoArray = youtubeVideoArray!
                    
                    // In order for the table view to display the videos, reload the table view
                    // on the main thread.
                    performUIUpdatesOnMain {
                        self.tableView.reloadData()
                        
                        // Hide the activity indicator.
                        self.hideActivityIndicator()
                    }
                    
                } else {
                    // Display alert describing errorMessage
                    performUIUpdatesOnMain {
                        self.displayErrorAlert(errorMessage: errorMessage!)
                    }
                }
            }
        }
        searchBar.resignFirstResponder()
    }
}

// MARK: Connection Error Alert

extension YouTubeSearchResultsTableViewController {
    
    func displayErrorAlert(errorMessage: String?) {
        // Error messages may be verbose and technical, so print them out and display
        // a more readable error message inside the pop-up that the user sees.
        print(errorMessage!)
        
        let alert = UIAlertController(title: "Connection Error", message: "Unable to retrive results from YouTube.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Dismiss", comment: "Default action"), style: .`default`, handler: { _ in
            print("The \"Connection Error\" alert occured.")
        }))
        self.present(alert, animated: true, completion: {
            
            // Stop the activity indicator, remove the gray tinted overlay
            self.hideActivityIndicator()
        })
    }
}

// MARK: Display/Hide activity indicator

extension YouTubeSearchResultsTableViewController {
    
    func displayActivityIndicator() {
        
        // Create a gray-tinted overlay to appear underneath the activity indicator:
        
        // Ensure that the overlay covers the entire view, and that it tints the screen gray.
        let overlayArea = view.frame
        overlay = UIView(frame: overlayArea)
        overlay?.alpha = 0.5
        overlay?.backgroundColor = UIColor.black
        
        // Add the overlay uiview as a subview of the tableview.
        if let overlay = overlay {
            tableView.addSubview(overlay)
        }
        
        // Start animating the activity indicator, which also causes it to appear.
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        
        // Remove the overlay from its superview.
        if let overlay = overlay {
            overlay.removeFromSuperview()
        }
        
        // Make the activity indicator stop animating, which will also cause
        // it to disappear.
        activityIndicator.stopAnimating()
    }
    
}
