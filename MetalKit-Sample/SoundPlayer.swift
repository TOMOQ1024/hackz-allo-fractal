//
//  SoundPlayer.swift
//  MetalKit-Sample
//
//  Created by 東光邦 on 2023/03/13.
//
import UIKit
import AVFoundation

class SoundPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    let TrakNumber = 4
    let musicDatas = [NSDataAsset(name: "LoopPad")!.data, NSDataAsset(name: "LoopCello")!.data, NSDataAsset(name: "LoopBass")!.data, NSDataAsset(name: "LoopPiano")!.data]
    var isPlay = false
    var musicPlayers : [AVAudioPlayer] = []
    
    func musicPlay(rate: CGFloat) {
        do{
            for i in 0..<TrakNumber {
                let mp: AVAudioPlayer! = try AVAudioPlayer(data: musicDatas[i])
                if let unwrap_mp = mp{
                    print(unwrap_mp)
                    musicPlayers.append(unwrap_mp)
                }else{
                    print("ERR:mp[\(i)] is nil")
                    return
                }
                
                musicPlayers[i].numberOfLoops = -1
                musicPlayers[i].setVolume(calcVolume(i: i, rate: Float(rate)), fadeDuration: 0.1)
                musicPlayers[i].play()
            }
            
            self.isPlay = true
            print("music play!")
        }catch{
            print("ERR:can't play sound")
        }
    }
    func update(rate: CGFloat){
        for i in 0..<TrakNumber {
            musicPlayers[i].setVolume(calcVolume(i: i, rate: Float(rate)), fadeDuration: 0.1)
        }
        
        print("music play!")
    }
    func stopAllMusic(){
        if(!self.isPlay) {
            return
        }
        for i in 0..<TrakNumber{
            musicPlayers[i].stop()
        }
        
        self.isPlay = false
    }
    func calcVolume(i: Int, rate: Float) -> Float{
        let res: Float = (rate-1.0)/pow(10, Float(i+1))
        if(res < 0){
            return 0.0
        }
        else if(res > 1){
            return 1.0
        }
        else{
            return res
        }
    }
}
