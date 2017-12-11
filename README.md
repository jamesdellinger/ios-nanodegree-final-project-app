<img src="https://s3-us-west-1.amazonaws.com/udacity-content/degrees/catalog-images/nd003.png" alt="iOS Developer Nanodegree logo" height="70" >

# Final Project: "I Can Cook" App

![Platform iOS](https://img.shields.io/badge/nanodegree-iOS-blue.svg)

This repository contains the final project app for Udacity's iOS Nanodegree.

"I Can Cook" provides a simple, user-friendly interface for creating, editing, and easily accessing all of your
recipes. Think of it as recipe notebook for the smartphone era.

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
where they can search for YouTube cooking videos by keyword. Tapping search sends the keyword
query to YouTube's data API, which returns a list of videos whose title and or description match the
user's search.

These results are displayed in a table view:

<img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.07.51.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.07.58.png" height="400">    <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.08.06.png" height="400"> <img src="https://github.com/jamesdellinger/ios-nanodegree-final-project-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-12-10%20at%2016.08.06.png" height="400">





1. Tapping "Edit" causes the map view to rise up, revealing the red bar underneath. Makes for greater similarity with how "Delete"
    indicators are revealed in other iOS elements, such as table views:

    <img src="https://github.com/jamesdellinger/ios-nanodegree-virtual-tourist-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-11-22%20at%2011.56.27.png" height="400">

2. Can tap on pin displayed above a location's photo album to reveal a nicely formatted address. If user has already dropped
    several pins, it can be easy to forget which pin's album is being viewed:

    <img src="https://github.com/jamesdellinger/ios-nanodegree-virtual-tourist-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-11-22%20at%2011.57.34.png" height="400">

3. Finally, it is possible to long press on any cell inside the collection view to display a larger size of a photo. The screen
    displaying this blown-up photo also contains an affordance that allows user to share the photo with any of their friends.
    
    <img src="https://github.com/jamesdellinger/ios-nanodegree-virtual-tourist-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-11-22%20at%2011.57.57.png" height="400">
    
    <img src="https://github.com/jamesdellinger/ios-nanodegree-virtual-tourist-app/blob/master/Screenshots/Simulator%20Screen%20Shot%20-%20iPhone%208%20Plus%20-%202017-11-22%20at%2012.18.54.png" height="400">
