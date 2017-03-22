# ReadMe

## Package Management
The program uses [CocoaPods](https://cocoapods.org/) to manage dependencies. This is the easiest, and industry-standard way to manage packages for XCode projects. The first time it's run on a machine, it will take much longer than usual; it's recommended to run this on a fast network connection, as it manages its package list using a very large git repo.

The packages can be found in `Podfile`, which is a small ruby script. It should be set up correctly and work well going forward. To install the "pods" just run `pod install` once you've installed CocoaPods. 

### How CocoaPods Works
Cocoapods, like most package managers, only installs packages if they have not already been installed. CocoaPods recommends uploading all of the Pods to the main source code repository. When a Pod is installed, it updates the .xcworkspace file, as well as the targets' associated frameworks. That means, you run `pod install`, and you don't need to put in any more work to link the frameworks to the associated targets.

**IMPORTANT:** On my machine, running `pod install` freezes XCode. It takes 1-2 force quits before it starts properly. If you install, and it freezes, just force quit and reopen until it starts normally.

## Notes on the Project
It's recommended to open the XCode project by opening the `.xcworkspace` file, ***NOT*** the `.xcproj` file. Opening it this way makes it behave better with CocoaPods.

## Overall Breakdown
The project is divided into a few subgroups.

* DDJClient - Handles the main logic for client mode.
* DDJHost - Handles the main logic for host mode. 
* Utility - Miscellaneous utility files that don't really belong anywhere else. Notable is the Global.swift files, where global variables should *generally* be put. Also, Spotify API Authentication is handled here in SpotifyAuthentication.swift.
* UI - handles the UI files. Basically, anything that extends UIViewController or, more generally, uses UIKit, should go here.
* CommandCentral - This houses the Command framework and the Server API calls.

There are some top-level files, including:
* AppDelegate - This is global and is basically the main() of the app.
* Main.storyboard - the storyboard.
* Launchscreen.storyboard - the launch screen.
* Info.plist - project file. Don't edit this manually, use the project menu.
* DDJiOS-Bridging-Header.h - This is needed for some things that count on Objective-C libraries. If adding an Objective-C library, you will need to edit this file as appropriate.

## Third-Party Frameworks
* AlamoFire - used for all HTTP/HTTPS networking. It is WAY easier and cleaner than Apple's native solution, and is industry standard.
* BlueSocket - IBM's socket framework. A bit ugly, but it's abstracted away by our Command Framework.
* Spotify-iOS-SDK - obv
* SwiftyBeaver - Our logging framework. I 💙 it.

## The Command Framework
All of the TCP commands are run through the command famework. This is located in Models > Commands. The main file is Command.swift, which defines how execution of all of these commands. There's a lot of logic here, mostly based around error handling. Command.swift also handles variables and enums relevant to its framework.

The CommandRunner subgroup handles listeners for commands. There are Client and Host children, which handle the logic for listening for, and responding to TCP commands.

There's also a framework called the ServerCommand Framework, which handles calls to the server. This is very tightly bound and made to make calls to the server easy. This framework probably has functions that are no longer used, and should be pruned at some point.

## Logging
We're switching to a new logging framework. Currently, only a few high-risk modules use it, but we should be using it across the whole project. If you're doing heavy work in a file, while you're add it, change the print statements in the file as appropriate. The logging framework serves to make logs clear and easy-to-read. Use it, you'll thank yourself later. The logging system allows for differentiation between levels (info, warning, and error) as well as shows the file and line where the log occurred. It's pretty great. When logging, keep the following in mind:

* Log often.
* Log concisely, clearly, and descriptively.
* Provide any necessary context for the logs.
* Use the appropriate level when logging.

The logging system is simple and easy to use.

    log.info("Everything is ok.")
    log.warning("Something concerning, but not terrible, happened.")
    log.error("💩💩💩💩💩")

## Some Things I Found Useful
These things may help you, or they may not. They were helpful to me and things I wish I knew about earlier.

&nbsp;

Error handling - It should follow the following format:

    do { 
        _ = try riskyFunction()
    } catch let error as SpecificError {
        error.log(error.description)
    } catch let error {
        error.log("The exact error type is not being caught, so a catch clause should be added for it. This is the best we can do in the meantime:")
        error.log(error.localizedDescription) // This is really vague, but it tells you the error type.
    }

&nbsp;

To edit properties of the project or the individual targets, select the top-level "DDJiOS" file. On the left pane, you can select between the DDJiOS project, or one of the three targets. This edits properties for the project or target safely and easily.

&nbsp;

Regex in Swift sucks. Use Utility > EZRegex. If EZRegex doesn't have what you need, add it.