//
//  SampleHandler.swift
//  BCUExtension
//
//  Created by Muhammad Zubair on 06/06/2020.
//  Copyright © 2020 macbook. All rights reserved.
//

import AVKit
import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {
    
    let dispatchGroup = DispatchGroup()
    
    var assetURL         : URL?
    
    var videoInput       : AVAssetWriterInput!
    var audioInput       : AVAssetWriterInput!
    
    var assetWriter      : AVAssetWriter!
    
    var isWritingStarted : Bool = false
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        super.broadcastStarted(withSetupInfo: setupInfo)
                
        assetURL    = URL(fileURLWithPath: FileSystemUtil.videoFilePath())
        
        assetWriter = try! AVAssetWriter(
            outputURL : assetURL!,
            fileType  : AVFileType.mp4
        )

        /* MARK:- Video Input */
        let videoOutputSettings : Dictionary<String, Any> = [
            AVVideoCodecKey  : AVVideoCodecType.h264,
            AVVideoWidthKey  : UIScreen.main.bounds.size.width,
            AVVideoHeightKey : UIScreen.main.bounds.size.height
        ]
        
        videoInput  = AVAssetWriterInput(
            mediaType      : AVMediaType.video,
            outputSettings : videoOutputSettings
        )
            
        videoInput.expectsMediaDataInRealTime = true
                
        /* MARK:- Audio Input */
        var audioChannelLayout = AudioChannelLayout()
        memset(&audioChannelLayout, 0, MemoryLayout<AudioChannelLayout>.size)
        
        audioChannelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Mono
        
        let audioOutputSettings: [String: Any] = [
            AVFormatIDKey         : kAudioFormatMPEG4AAC,
            AVSampleRateKey       : 44100,
            AVNumberOfChannelsKey : 1,
            AVEncoderBitRateKey   : 64000,
            AVChannelLayoutKey    : Data(bytes: &audioChannelLayout,
                                      count : MemoryLayout<AudioChannelLayout>.size
                                    )
        ]
        
        audioInput = AVAssetWriterInput(
            mediaType      : AVMediaType.audio,
            outputSettings : audioOutputSettings
        )
        
        audioInput.expectsMediaDataInRealTime = true
        
        assetWriter.add(videoInput)
        assetWriter.add(audioInput)
        assetWriter.startWriting()
    }
    
    override func broadcastPaused() {
        super.broadcastPaused()
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        super.broadcastResumed()
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        super.broadcastFinished()
        // User has requested to finish the broadcast.
        dispatchGroup.enter()
        self.videoInput.markAsFinished()
        self.audioInput.markAsFinished()
        self.assetWriter.finishWriting {
            if let url = self.assetURL {
                if FileManager.default.fileExists(
                    atPath: url.path
                    ) {
                    
                    print("==========")
                    print("File Exist")
                    print("==========")
                    
                    do {
                        let data = try Data(contentsOf: url)
                        print("==============")
                        print("Data : \(data)")
                        print("==============")
                    } catch {
                        print("==============")
                        print("Error: \(error)")
                        print("==============")
                    }
                    
                } else {
                    print("=============")
                    print("No File Exist")
                    print("=============")
                }
            }
            self.dispatchGroup.leave()
        }
        self.dispatchGroup.wait() 
    }
    
    override func finishBroadcastWithError(_ error: Error) {
        print("================")
        print("Error : \(error)")
        print("================")
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            if CMSampleBufferDataIsReady(sampleBuffer){
                // Before writing the first buffer we need to start a session
                if !isWritingStarted {
                    self.assetWriter.startSession(
                        atSourceTime: CMSampleBufferGetPresentationTimeStamp(
                            sampleBuffer
                        )
                    )
                    isWritingStarted = true
                }

                if self.assetWriter.status == AVAssetWriter.Status.failed {
                    print("===================================================")
                    print("Error:\(String(describing: self.assetWriter.error))")
                    print("===================================================")
                    return
                }

                if self.videoInput.isReadyForMoreMediaData {
                  self.videoInput.append(sampleBuffer)
                }
            }
            break
        case RPSampleBufferType.audioApp:
            if CMSampleBufferDataIsReady(sampleBuffer){
                if isWritingStarted {
                    
                    if self.assetWriter.status == AVAssetWriter.Status.failed {
                        print("===================================================")
                        print("Error:\(String(describing: self.assetWriter.error))")
                        print("===================================================")
                        return
                    }
                    
                    if self.audioInput.isReadyForMoreMediaData {
                        self.audioInput.append(sampleBuffer)
                    }
                    
                }
            }
            break
        case RPSampleBufferType.audioMic:
            if CMSampleBufferDataIsReady(sampleBuffer){
                if isWritingStarted {
                    
                    if self.assetWriter.status == AVAssetWriter.Status.failed {
                        print("===================================================")
                        print("Error:\(String(describing: self.assetWriter.error))")
                        print("===================================================")
                        return
                    }
                    
                    if self.audioInput.isReadyForMoreMediaData {
                        self.audioInput.append(sampleBuffer)
                    }
                    
                }
            }
            break
        default :
            break
        }
    }
    
}
