# iOS Developer Nanodegree Final Project: *I Can Cook* App
*Conceiving, designing, prototyping, and finally implementing a unique full-fledged iOS app from scratch. Putting into use all concepts learned during the nanodegree, including UIKit classes, RESTful API calls, thread concurrency, and data persistence.*

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/iosndlogo.jpg" alt="iOS Developer Nanodegree logo" height="100" >

This repository contains my final project app for Udacity's [iOS Nanodegree](https://www.udacity.com/course/ios-developer-nanodegree--nd003). Titled *I Can Cook*, my app provides a simple, user-friendly interface for creating, editing, and easily accessing all of your
recipes. Think of it as recipe notebook for the smartphone era.

## App Walkthrough
On first-time app launch, a friendly hint graphic shows the user how to add their first recipe:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-08%20at%2013.40.39.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-08%20at%2014.17.28.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2015.29.21.png" height="400">

Tapping "+" takes the user to a screen where they can enter their recipe's name, ingredients, preparation
directions, as well as take a photo of their dish using their iPhone's camera, or choose a photo from their
photo album:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2015.40.42.png" height="400">

After entering their recipe's info (all fields are optional except for the recipe's title), tapping "Save"
saves the recipe in Core Data on the user's iPhone and navigates the user back to the recipes
screen, where their newly created recipe is now visible:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2015.41.37.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2015.41.53.png" height="400">

The app keeps track of recipe's by their names. Each recipe must have a unique name, and if the
user tries to add a recipe with a duplicate title, the app will prevent this from happening:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2015.48.14.png" height="400">

Selecting a saved recipe takes the user to that recipe's details. Tapping "Edit" at the top of this screen
allows the user to edit their saved recipe's title, photo, ingredients, and or preparation directions. Tapping
"Save" immediately saves these updates in Core Data:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.07.51.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.07.58.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.08.06.png" height="400">

This app has the added capability of letting search for and discover brand new recipes by searching
for and watching YouTube videos. Tapping "Discover Recipes" takes the user to a search screen
where they can search for YouTube cooking videos by keyword.

Tapping search sends the keyword query to YouTube's data API, which returns a list of videos whose title
and or description match the user's search. These results are displayed in a table view:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.14.39.png" height="350">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.14.44.png" height="350">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.14.49.png" height="350">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.14.57.png" height="350">

When the user selects a particular YouTube video from the table view, a screen will be displayed that
automatically starts playing the YouTube video in-line inside the screen:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.21.12.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.21.19.png" height="400">

(In-line YouTube video playback was achieved by using YouTube's youtube-ios-player-helper library
available at https://github.com/youtube/youtube-ios-player-helper.)

The user can add the recipe described in a particular YouTube video by tapping the "Add To Your Recipes"
button. Doing this takes the user to the "Add Recipe" screen, where the recipe title and image fields are
pre-populated with the YouTube video's title and thumbnail image, respectively.

After adding the ingredients and preparation directions, tapping "Save" saves the recipe in
Core Data. The user is also taken back to the screen where the YouTube video is playing.
When the user returns to their recipes screen, the recipe they added from YouTube is displayed
right alongside their other saved recipes:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.21.35.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.21.52.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.31.16.png" height="400">

## To build and run this app
1. Clone or download this repository.
2. Open the file 'I Can Cook.xcodeproj' in Xcode and press the Run button.

## Project Grading and Evaluation
* [Project Review](https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/ios-nanodegree-final-project-app-review.pdf)

* [Project Grading Rubric](https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/ios-nanodegree-final-project-app-specs-and-rubric.pdf)
