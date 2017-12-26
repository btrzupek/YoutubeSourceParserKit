//
//  AppDelegate.swift
//  youtube-parser
//
//  Created by Toygar Dündaralp on 7/5/15.
//  Copyright (c) 2015 Toygar Dündaralp. All rights reserved.
//

import UIKit
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        //let testURL = NSURL(string: "https://www.youtube.com/watch?v=swZJwZeMesk")! // copyrighted content
        let testURL = NSURL(string: "https://www.youtube.com/watch?v=MmyGP03tt0c")! // free content
        Youtube.h264videosWithYoutubeURL(youtubeURL: testURL) { (videoInfo, error) -> Void in
            if let videoURLString = videoInfo?["url"] as? String,
                let videoTitle = videoInfo?["title"] as? String {
                print("\(videoTitle)")
                print("\(videoURLString)")
                
                // Save the video
                self.downloadVideoLinkAndCreateAsset(videoURLString)
            }
        }
        return true
    }
    
    func downloadVideoLinkAndCreateAsset(_ videoLink: String) {
        
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else { return }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // check if the file already exist at the destination folder if you don't want to download it twice
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
            
            // set up your download task
            URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
                
                // use guard to unwrap your optional url
                guard let location = location else { return }
                
                // create a deatination url with the server response suggested file name
                let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
                
                do {
                    
                    try FileManager.default.moveItem(at: location, to: destinationURL)
                    
                    PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                        
                        // check if user authorized access photos for your app
                        if authorizationStatus == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                                    if completed {
                                        print("Video asset created")
                                    } else {
                                        print(error.debugDescription)
                                    }
                            }
                        }
                    })
                    
                } catch { print(error) }
                
                }.resume()
            
        } else {
            print("File already exists at destination url")
        }
        
    }
}
