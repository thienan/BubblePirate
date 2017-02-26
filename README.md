CS3217 Problem Set 5
==

**Name:** Lim Ta Eu

**Matric No:** A0126356E

**Tutor:** WangJingHan

### Rules of Your Game

clear all the bubble to win
if the last row is filled, the player will lose
tap the canon to swap bubble


note the the colourful image bubble is the star bubble while the yellow star imaged bubble is the lightning bubble

### Problem 1: Cannon Direction

player can tap on the screen to make the cannon look at the tap position
player can pan on the screen to make the cannon look at the pan position 


### Problem 2: Upcoming Bubbles

red blue purple and green bubble are shuffled and added in to the queue at the start of the game.
when there are 2 bubble left, red blue purple and green bubble are shuffled and added to the queue again.

i design such way because the player can tap the cannon to swap the bubble if they got an undesired bubble


### Problem 3: Integration
the bubble is a bubbleGrid while the bubble in the game is Bubble.

advantages
There are both seperated because bubbleGrid doesnt need the game logic and only need to store data of colour bubble and position.
while the bubble has the game logic.
bubblegrid requires saving logic while bubble doesn't'

disadvantage
need an extra class which is the gridbubble

alternative approach
merge grid bubble and bubble into 1 single object

advantage
no need to seperate into 2 classes

disadvantage
everything is clumped together in 1 single class which makes it very messy


### Problem 4.3

my strategy is the best among the alternatives because the bubble manager will handle each bubble behaviour, because the bubble manager has all the references of all the bubble and it can traverse the grid to find the neighbour bubble


altenative strategy - bubble chaining effect logic in bubble
the bubble doesnt know its neighbour and requires to communicate with the bubble manager to get neighbour bubble to do the chain effect


### Problem 7: Class Diagram

Please save your diagram as `class-diagram.png` in the root directory of the repository.

### Problem 8: Testing

BlackBox Testing
Test movable bubbles
- shoot toward a grid position above the line 
    -expect to snap, move in the same direction as the cannon
- shoot toward bottom of screen
    - wont be able to shoot
- shoot all different coloured bubble

Test collision between two bubbles
- test collision between two same color bubbles
- test collision between three same color bubbles
- test collision between two same different color bubbles
- try to test collision between two moving bubble (which won’t happen)
- test collision with bubble at last row with different color
- test collision with bubble at last row with a formation of 3 same coloured bubbles

Test collisions between a bubble and a screen edge
- test collision at the top of the screen
- test collision at the right screen
- test collision at the left screen
- test dynamic collision of 2 moving bubble 
    -expected to bounce off

Test performance
- test playing with grid full of bubbles 
- try to pop full grid of red bubbles with a red bubble

Test destroying unrooted bubbles 
- test destroy a single unrooted bubble
- test destroying a group of unrooted bubble
- test destroying multiple single hanging bubble

Test general
- test playing with empty screen
- test newly launched bubble
- load game with unrooted bubbles

Level
- move from home to level design to game
- move from home to level selection to game
- game to home
- game to level selection
- game to level design
- win a loaded level
    - check if the 3 stars are saved in the level selection
- lose a loaded level
- win a level that was started from level designer
    - wont get 3 star in level selection as is was not played from level selection
- lose a level that was started from level designer

Preload Level
- win a preload level and check if the stars are saved, reopen game to check if the stars are saved
- modify the preload level, reopen game 
    -expect to no be ovewritten by the old preload level

Level Selection
- test the view when is is loaded with 20 levels
- test the view when is is loaded with 0 levels
- test the view when is is loaded with 1 levels

Gameplay Level
- test end game by destroyign all bubbles
- test end game with some bubbles flying around
    - bubbles should dissapear
- test pause menu

Level Design
-save and load with a valid string,”level 1”
-save with invalid string,“”, " ", ".", "/"
    -expected to prompt invalid message
-save with unicode
-save and load empty grid
-save and load grid full of bubbles
-save and load grid with all available colour
-save and load level with existing level name - expect to overwrite
-modify and save a level that was loaded
-save 100 levels
-cancel when save alert is prompted

Bubbles
Test indestrutible Bubble
- cant be removed through connecting of adjacent bubbles
- can be removed from falling
- can be removed by bomb bubble
- can be removed by lightning bubble
- cant be removed by star bubble

Test lightning bubble
- remove whole row of bubble
- trigger bomb bubble on the same row
- trigger lightning bubble on the same row
- can be removed from falling without triggering

Test bomb bubble
- remove adjacent bubble
- trigger adjacent bomb bubble 
- can be removed from falling without triggering

Star bubble
- remove all color of the same type
- wont trigger other star bubble
- can be removed from falling without triggering

Cannon
- shoots bubble in the direction of the cannon's direction'
- tap as fast as possible
- tap at the bottom of the screen 
- test animation
    -should be played once for every tap and stoped

trajectory
- trajectory that has a limit when there is too many bounces
- test upward trajectory

Sound
- test background music 
- test bubble effect music overlaps with background music
- test all special effect bubble sound
    -expected all different


Glass-box testing
GamePlay Controller class
setUpEngineAndBubbleManagerAndGridBound()
- test with valid gridBubbles
- test with invalid gridBubbles (will show error)

createLauncher()
- test with nil bubbleManager ( launcher won’t be created )

BubbleManager class
init()
- init with invalid gridBubbles size
- init with valid gridBubbles

calculateGridLowerBound()
- test with empty grid
- test with full grid

createBubble(bubbleGird: BubbleColor, position: CGVector)
- test with bubbleColor like pink that is not in switch case
- test with valid bubble color

fireBubble()
- fire when game mode is ready
- fire when game mode is waiting

setCurrentBubbleInQueue()
- test with empty queue
- test with non empty queue

setNextBubbleInQueue()
- test with emptyQueue
- test with 1 item in queue
- test with 2 item in queue

createAnimatedBubbleObnject()
- test with nil spriteComponent
- test with valid spriteComponent

isValid()
- test with valid gridBubbles
- test with invalid gridBubbles that have different dimension

onBubbleDoneSnapping()
- test with bubble that is not in that bubble manger’s 2d bubble array
- test with bubble that exists in the bubble manager

tryToPop()
- test with connectedColorBubble of 0
- test with connectedColorBubble of 1
- test with connectedColorBubble of 3

getBubbleIndex(bubble: Bubble) -> IndexPath?
- test with bubble that exists in the 2d array
- test with bubble that is not in the 2d array

getVisitedBubbles(visited: [IndexPath:Bool]): [Bubble]
- empty visited
- full visited (all bubbles)

bfs
- test with startIndexPath different from startBubble’s current index (result will be incorrect)
- test with correct startIndexPath and startBubble’s index

findNeightBour(indexPath: IndexPath): [IndexPath]
- test at row =0, col = 0, row<ROW_COUNT, col < COL_COUNT, row = ROW_COUNT/2, col = COL_COUNT/2

SphereColliderComponent
intersect()
- test with valid colliding circles
- test with non colliding circles

CGVector
- test all operator function with valid CGVector

StorageManager.swift
init()
-init storage with no level saved
-init storage with existing level saved

getLevelNamesPath()
-valid path name
-invalid path name

getLevelContentsPath()
-valid path name
-invalid path name

save()
-valid string, “level1”, unicode string
-invalid string, “”, string that contains "." and "/"
-valid/invalid levelNamesPath
-valid/invalid levelContentsPath
-existing level name

loadLevelNames()
-valid/invalid levelNamesPath
-valid/invalid saved content

getLevelNames()
-0 level saved
-10 level saved

LevelDesignViewController.swift
-all button presses func()
-embedController is nil
-press the same button - expect to be unselected
-fadeAllButton()
-when no button is selected
-when a button is selected (test for all button)
-createSaveAlert(title)
-title = empty string
-title = “level1”
-textfield - empty string, “level1”, unicode
-embedController is nil

GridCollectionController.swift

GridCollectionCell.swift
-clearImage()
-when imageView.image has an image
-when imageView.image has no image 
-setImage(image: UIImage)
-different screen width for auto scaling
-image that fits the cell
-image that is bigger than the cell
-image that is smaller than the cell

BubbleGridManager.swift
-createEmptyBubbleGrid()
-call the function when grid is totally empty, full of bubbles
-ROW_COUNT = 0
-COLUMN_COUNT_ODD = 0
-COLUMN_COUNT_EVEN = 0	

-setBubbleColor(), getBubbleColor(), cycleBubbleColor(), isValid(indexRow, indexCol)
-valid indexCol, indexRow
-invalid indexCol, indexRow
-indexRow, indexCol = 0
-indexRow, indexCol such that: 
-indexRow = ROW_COUNT - 1
-indexRow = COLUMN_COUNT_EVEN -1
-indexRow = COLUMN_COUNT_ODD -1

-cycleBubbleColor() 
-when bubbleColor != NONE
-when bubbleColor == NONE

-getBubbles()
-when bubbleGrid is empty
-when bubble grid is full of bubbles

-loadBubbles(bubbles: [[Bubble]])
*dimension = row size, col size
-bubbles’s dimension = bubble grid dimension
-when bubbles’s dimension != bubble grid dimension
-empty grid
-full of bubbles
-1 bubble

-isValid(bubbles: [[Bubble]])
-bubbles’s dimension = bubble grid dimension
-when bubbles’s dimension != bubble grid dimension


GridBubble.swift
cycleToNextColor()
-blue -> red
-red -> orange
-orange -> green
-green -> blue
-none -> none

required convenience init()
-valid color
-invalid color.rawvalue

encode()
-valid color


### Problem 9: The Bells & Whistles
- screen vibration when pop bubble / special bubble
- 3 star win/lose screen
- custom asset for everything in the game
- path trajectory
- swap bubble for cannon
- different animated effect for different special bubble
- different sound effect for different special bubble
- different colour pop effect for different bubble
- both the animated effect and colour pop effect are created with a random rotation to get rid of repetition pattern 
- 5 different sound that are picked at random for bubble pop to provide different pop sound effect 
- 2 different sound effect for shooting cannon
- bubble will move to snap position linearly instead of snappng straight
- animated cannon
- sound system has pooling and threading


### Problem 10: Final Reflection
the game engine still obey the MVC pattern and i have the bubble Model, controller and the view. The game engine has a render engine that handles the view while bubble only contains the data required by the render engine to draw the sprite in the view

My game engine also works by using component pattern which allow gameobject to contain any component and extend other physic engine 

The component's position are local position while the gameobject is the parent - this makes is easy to create the component with position relative to the parent - for example a sphere collider with centre (0, 0) while parent is at (100, 100)'

There is also a sound system which handles all the sound polling and threading to improve the performance

improvement
in game object collate all components into a component list, so a game object can have mutiple sprite component, multiple collider component. the physic and render engine will just take in all the sprite component or physci component of the game object


Testing
save level without save (created)
save as preloaded level
start game with empty bubble

