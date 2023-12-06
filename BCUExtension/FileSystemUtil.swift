//
//  FileSystemUtil.swift
//  RecordSample
//
//  Created by M Farhan on 6/11/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import Foundation

class FileSystemUtil {
    
    internal class func videoFilePath() -> String {
        
        guard var videoOutputURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.RecordSample"
            ) else {
                fatalError("could not get shared app group directory.")
        }
        
        videoOutputURL = videoOutputURL.appendingPathComponent(
            "RecorderVideos",
            isDirectory: true
        )
        
        let directory = videoOutputURL
        
        videoOutputURL = videoOutputURL.appendingPathComponent(
            "AssembledVideo.mp4"
        )
        
        var isDir : ObjCBool = false
        let path = directory.path
        
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                do {
                    if FileManager.default.fileExists(atPath: path) {
                        try FileManager.default.removeItem(atPath: path)
                    }
                } catch {
                    print("================================")
                    print("Caught Error While removing File")
                    print("================================")
                }
            } else {
                print("==================================")
                print("File exists and is not a directory")
                print("==================================")
            }
        } else {
            do {
                try FileManager.default.createDirectory(
                    at: directory,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            }
            catch {
                print("=====================================")
                print("Caught Error While Creating Directory")
                print("=====================================")
            }
        }
        
        return videoOutputURL.path
    }

}
