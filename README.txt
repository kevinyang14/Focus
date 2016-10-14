CS193P Final Project - Kevin Yang

FOCUS - productivity app that interweaves a suite of tools to improve daily efficiency.

Parts of the iOS Application:

1. Home Screen - elegant white greeting to the user with running time and daily focus to be set by the user. The gift button at the top allows the user to switch to a different landscape backrgound and a hidden easter egg through growing vine animation (consistent with the theme of sceneries) is revealed by drawing on the screen with a pan gesture. All this is presented over a parallax background. 

a. Time - was powered by NSTimer
b. Vine Animation - was customized from the original Vineline created by Michael Behan that is powered by UIBezierPath drawing + QuartzCore Animation
c. Username & Backrgound - was kept consistent using NSUserDefaults

2. To Do List - robust to do list that manages to dos (each with a task, deadline, audio recording, photo, and urgency level). The todo list is primarily sorted by urgency level and by how close the task is due and any todo can be easily deleted once completed by swiping to the left. Clicking the "+" button will allow a user to create a new todo with the task and deadline as mandatory fields to input and the audio and photo (camera button on the top right) as optional. If the user does not add audio or photo, selecting the audio/photo buttons on the UITableView cell will show an alert. Selecting an existing todo will enter the current to do page that has another easter egg - mini game of dropping snowballs (dynamically colored based on their background scenery) when repeatedly tapped. 

a. ToDo List - UITableView with CustomUITableView cells and allows integration to different views through UINavigationBar
b. ToDo List Data - was powered by Core Data. The list is dynamically updated during adding and deleting and immediately sorted by changing the urgency level by tapping the 4 colored dots. 
c. Current ToDo Mini Game - was powered by UIDynamic Animator with gravity, elasticity (no rotation), and collision behavior and UIBezierPath View. The background color sensitive snow balls were created with custom light from UIImageEffects. 
d. Photo Added - used a modal segue with UIImageView and ImagePicker to take the photo. 
e. Recording Audio - used a AVFoundation to record, play, and save the audio
f. Storing Photo & Audio - used NSFileManager to actually store and later retrieve the photo and audio data
g. Deadline - used NSDatepicker to allow the user to select the precise date deadline. 
h. Viewing Photo - used UIScrollView

3. Timer - minimalist timer for helping the user keep track of work time. 

a. Time - powered by NSTimer
b. Circle Animation - was created with UIBezierPath and CSShapeLayer and powered by QuartzCore Animation with CABasicAnimation strokePath

4. NearbyChat - simple chat feature that allows the user to chat with other students around a certain study space to ask for help. 

a. Chat - was powered entirely by Multipeer

5. Data - graph showing the user's workload over the next 7 days (relative to the current day).

a. Graph - was drawn entirely with UIBezierPath and animated by QuartzCore Animation and CSBasicAnimation
b. Graph Data - was taken using CoreData 

*everything was organized with UITabBar