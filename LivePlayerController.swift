//
//  LivePlayerViewController.swift
//  jufangzhushou
//
//  Created by 刘兆娜 on 16/5/16.
//  Copyright © 2016年 tbaranes. All rights reserved.
//

import Foundation
import KDEAudioPlayer
import QorumLogs


class LivePlayerViewController : PlayerViewController {
    
    
    override init(playerCell : PlayerCell) {
        super.init(playerCell: playerCell)
    }
    
    override func initPlayerController() {
        super.initPlayerController()
        
        //暂时认为一个直播album只有一个直播节目
        cell.preButton.isEnabled = false
        cell.nextButton.isEnabled = false
        cell.bufferProgress.progress = 0
        //直播不显示进度条
        cell.bufferProgress.isHidden = true
        
        let song = (audioPlayer.currentItem as! MyAudioItem).song as! LiveSong
        //获取直播的时间
        cell.playingLabel.text = Utils.getCurrentTime()
        cell.durationLabel.text = song.endTime
        (cell as! LivePlayerCell).peopleCountLabel.text = song.listenPeople
        
        //- 获取直播的图片
        //cell.artImageView.downloadedFrom(link: song.imageUrl!, contentMode: .ScaleAspectFit)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.liveProgressTimer == nil {
            appDelegate.liveProgressTimer  = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(updatePlayingProgress), userInfo: nil, repeats: true)
        }
        
        cell.progressBar.value =  Float(song.playedTime / song.totalTime)
        
        cell.progressBar.isEnabled = true
    }
    
    override func playOrPause() {
         QL1("playOrPause: player state is \(audioPlayer.state)")
        if audioPlayer.state == AudioPlayerState.playing || audioPlayer.state == AudioPlayerState.buffering {
            audioPlayer.pause()
            
        } else if audioPlayer.state == AudioPlayerState.paused {
            audioPlayer.resume()
            audioPlayer.seekToSeekableRangeEnd(padding: 0)
        } else {
            if audioPlayer.currentItem != nil {
                QL1("player state is \(audioPlayer.state), try to play the item")
                
                //TODO:
                //audioPlayer.playItem(audioPlayer.currentItem!)
            }
        }
    }
    
    override func getPlaceHolderMusicImageName() -> String {
        return "liveMusicCover"
    }
    
    override func audioPlayer(audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, toState to: AudioPlayerState) {
        print("LivePlayerViewController:didChangeStateFrom called，from = \(from), to = \(to)")
        updatePrevAndNextButtonStatus()
        updatePlayAndPauseButton()
        
        updateBufferCircle()
        cell.progressBar.isEnabled = true
    }
    
    //加载直播信息，不能删除
    override func audioPlayer(audioPlayer: AudioPlayer, willStartPlayingItem item: AudioItem) {
        print("LivePlayerViewController:willStartPlayingItem called")
        
    }
    
    //更新播放进度条，不能删除
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateProgressionToTime time: TimeInterval, percentageRead: Float){

    }
    
    //更新缓冲进度条，不能删除
    /*
    override func audioPlayer(audioPlayer: AudioPlayer, didLoadRange range: AudioPlayer.TimeRange, forItem item: AudioItem){
        print("LivePlayerViewController:didLoadRange, loadRange = \(range)")
        updateBufferProgress()
    }*/
    
    //更新基础信息，不能删除
    override func audioPlayer(audioPlayer: AudioPlayer, didUpdateEmptyMetadataOnItem item: AudioItem, withData data: Metadata) {
        
    }

    
    private func getCurrentSong() -> LiveSong {
        return (audioPlayer.currentItem as! MyAudioItem).song as! LiveSong
    }
    
    
    override func updateBufferProgress() {
        //print("LivePlayerViewController:updateBufferProgress")
        let beforeTime = TimeInterval( getCurrentSong().totalTime - getCurrentSong().leftTime )
        if audioPlayer.currentItemLoadedRange != nil {
            cell.bufferProgress.progress = Float( (beforeTime + audioPlayer.currentItemLoadedRange!.latest) / TimeInterval( getCurrentSong().totalTime) )
        }

    }
    
    var isPlaying : Bool {
        get {
            return self.audioPlayer.state == AudioPlayerState.playing
        }
    }
    
    @objc override func updatePlayingProgress() {
        if isPlaying {
            //print("LivePlayerViewController:updatePlayingProgress")
            
            cell.playingLabel.text = Utils.getCurrentTime()
            //log.debug("progress = \(getCurrentSong().progress)")
            cell.progressBar.value = getCurrentSong().progress
        }
        
    }


    
}
