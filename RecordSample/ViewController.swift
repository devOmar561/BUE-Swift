//
//  ViewController.swift
//  RecordSample
//
//  Created by Muhammad Zubair on 06/06/2020.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit
import AVKit
import ReplayKit

public struct video {
    static var videoURL : URL?
}

class ViewController: UIViewController {

    var broadcastPicker : RPSystemBroadcastPickerView?

    var player           : AVPlayer?
    var playerLayer      : AVPlayerLayer?
    
    let defaults = UserDefaults(suiteName: "group.com.RecordSample")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBroadCaster()
    }
    
    func initBroadCaster(){
        broadcastPicker = RPSystemBroadcastPickerView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 200,
                height: 200
            )
        )
        
        defaults?.set(false, forKey: "Success")
        self.view.addSubview(broadcastPicker!)
    }
    
    @IBAction func play(_ sender: UIButton){
        let _        = defaults?.value(forKey: "URL")
        let success  = defaults?.value(forKey: "Success")
        
        print("=========================")
        print("Success: \(success ?? "")")
        print("=========================")
        
        guard var videoOutputURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.RecordSample"
        ) else {
                fatalError("could not get shared app group directory.")
        }
        
        videoOutputURL = videoOutputURL.appendingPathComponent(
            "RecorderVideos",
            isDirectory: true
        )
        
        videoOutputURL = videoOutputURL.appendingPathComponent(
            "AssembledVideo.mp4"
        )
        
        let path = videoOutputURL.path
        
        if FileManager.default.fileExists(atPath: path) {
            print("==========")
            print("File Exist")
            print("==========")
            setVideo(with: path, in: self.view.frame)
        } else {
            print("=============")
            print("No File Exist")
            print("=============")
        }
        
    }
    
    func setVideo(with path: String, in frame: CGRect) {
        let fileURL = URL(fileURLWithPath: path)
//        let asset   = AVAsset(url: fileURL)
        
        self.player      = AVPlayer(url: fileURL)
        self.playerLayer = AVPlayerLayer(player: self.player)
        
        self.playerLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width : frame.width,
            height: UIScreen.main.bounds.height
        )
        
        self.playerLayer?.contentsGravity = .resizeAspectFill
        
        self.view.layer.addSublayer(self.playerLayer!)
        self.player?.seek(to: .zero)
        self.player?.play()
        
        /* MARK:- Start Deleting If Old File Is There */
//        let tempDir = NSTemporaryDirectory()
//
//        let destinationUrl = URL(
//            fileURLWithPath: tempDir
//        ).appendingPathComponent(
//            "finalRecording.mp4"
//        )
//
//        try? FileManager().removeItem(at: destinationUrl)
        /* MARK:- End Deleting If Old File Is There */
        
        /* MARK:- Using AVSession To Export Movie */
//        if let assetExport = AVAssetExportSession(
//            asset       : asset,
//            presetName  : AVAssetExportPreset1280x720
//            ) {
//
//            assetExport.outputFileType = AVFileType.mp4
//            assetExport.outputURL      = destinationUrl
//
//            assetExport.exportAsynchronously(completionHandler: {
//                switch assetExport.status {
//                case AVAssetExportSessionStatus.failed:
//                    print("failed")
//                    print(assetExport.error ?? "unknown error")
//                case AVAssetExportSessionStatus.cancelled:
//                    print("cancelled")
//                    print(assetExport.error ?? "unknown error")
//                default:
//                    print("Movie complete")
//                    print(destinationUrl)
//
//                    self.player      = AVPlayer(url: destinationUrl)
//                    self.playerLayer = AVPlayerLayer(player: self.player)
//
//                    self.playerLayer?.frame = CGRect(
//                        x: 0,
//                        y: 0,
//                        width : frame.width,
//                        height: UIScreen.main.bounds.height
//                    )
//
//                    self.playerLayer?.contentsGravity = .resizeAspectFill
//
//                    self.view.layer.addSublayer(self.playerLayer!)
//                    self.player?.seek(to: .zero)
//                    self.player?.play()
//                }
//            })
//
//        }
        
    }
    
}

