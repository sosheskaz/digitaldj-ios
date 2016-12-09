//
//  AppDelegate.swift
//  DDJiOS
//
//  Created by Miguel Marquez on 10/26/16.
//  Copyright © 2016 msoe. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SPTAudioStreamingDelegate {
    let CLIENT_ID = "fc6d46c6e95e4c579abd440376ba7555"
    let CLIENT_SECRET = "b101c807436144c2848f84d2fb26c264"
    let CALLBACK_URL = "ddj://callback/"
    
    var window: UIWindow?
    
    var auth: SPTAuth?
    var authViewController: UIViewController?
    var player: SPTAudioStreamingController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.auth = SPTAuth.defaultInstance()
        // The client ID you got from the developer site
        self.auth!.clientID = CLIENT_ID
        // The redirect URL as you entered it at the developer site
        self.auth!.redirectURL = URL(string: CALLBACK_URL)
        // Setting the `sessionUserDefaultsKey` enables SPTAuth to automatically store the session object for future use.
        self.auth!.sessionUserDefaultsKey = "current session"
        // Set the scopes you need the user to authorize. `SPTAuthStreamingScope` is required for playing audio.
        self.auth!.requestedScopes = [SPTAuthStreamingScope, SPTAuthUserReadTopScope, SPTAuthUserReadPrivateScope];
        
        // spin up player
        self.player = SPTAudioStreamingController.sharedInstance()
        do {
            try self.player?.start(withClientId: self.auth!.clientID)
        } catch {
            assertionFailure("Spotify failed to initialize.")
        }
        
        // Start authenticating when the app is finished launching
        DispatchQueue.main.async(execute: {
            self.startAuthenticationFlow()
        });
        
        // Override point for customization after application launch.
        return true
    }
    
    // callback for spotify
    func application(_ application: UIApplication, url: URL, options: Dictionary<String, Any>) {
        if(self.auth?.canHandle(url))! {
            self.authViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            self.auth!.handleAuthCallback(withTriggeredAuthURL: url, callback: {error, session in
                if (error == nil) {
                    assertionFailure("Spotify failed to authenticate.")
                    return
                }
                if (session != nil) {
                    // login to the player
                    self.player!.login(withAccessToken: self.auth!.session.accessToken)
                } else {
                    assertionFailure("Spotify failed to authenticate.")
                    return
                }
            })
        }
    }
    
    func startAuthenticationFlow() {
        if (self.auth!.session != nil && (self.auth!.session.isValid())) {
            // Use it to log in
            // self.startLoginFlow()
        } else {
            // Get the URL to the Spotify authorization portal
            let authURL = self.auth!.spotifyWebAuthenticationURL()
            // Present in a SafariViewController
            self.authViewController = SFSafariViewController(url: authURL!)
            self.window?.rootViewController?.present(self.authViewController!, animated: true, completion:nil)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "msoesdl.DDJiOS" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "DDJiOS", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

