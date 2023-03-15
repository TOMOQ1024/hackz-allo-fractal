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
    var currentMode = 0
    let musicDatas = [
        [NSDataAsset(name: "LoopPad")!.data, NSDataAsset(name: "LoopCello")!.data, NSDataAsset(name: "LoopBass")!.data, NSDataAsset(name: "LoopPiano")!.data],
        [NSDataAsset(name: "BC_Pad")!.data, NSDataAsset(name: "BC_Brass")!.data, NSDataAsset(name: "BC_Bass")!.data, NSDataAsset(name: "BC_Bell")!.data],
        [NSDataAsset(name: "Sepias_Pad")!.data, NSDataAsset(name: "Sepias_Bass")!.data, NSDataAsset(name: "Sepias_Piano")!.data, NSDataAsset(name: "Sepias_Bell")!.data],
        [NSDataAsset(name: "Metal_Pad")!.data, NSDataAsset(name: "Metal_Bass")!.data, NSDataAsset(name: "Metal_Calv")!.data, NSDataAsset(name: "Metal_Lead")!.data],
        [NSDataAsset(name: "Psych_Pad")!.data, NSDataAsset(name: "Psych_Bass")!.data, NSDataAsset(name: "Psych_Piano")!.data, NSDataAsset(name: "Psych_Drum")!.data]
    ]
    var isPlay = false
    var musicPlayers : [AVAudioPlayer] = []
    
    func musicPlay(rate: Float) {
        do{
            for i in 0..<TrakNumber {
                let mp: AVAudioPlayer! = try AVAudioPlayer(data: musicDatas[currentMode][i])
                if let unwrap_mp = mp{
                    print(unwrap_mp)
                    musicPlayers.append(unwrap_mp)
                }else{
                    print("ERR:mp[\(i)] is nil")
                    return
                }
                
                musicPlayers[i].numberOfLoops = -1
                musicPlayers[i].setVolume(calcVolume(i: i, rate: Float(rate)), fadeDuration: 0.5)
                musicPlayers[i].play()
            }
            
            self.isPlay = true
            print("music play!")
        }catch{
            print("ERR:can't play sound")
        }
    }
    func update(rate: Float){
        for i in 0..<TrakNumber {
            musicPlayers[i].setVolume(calcVolume(i: i, rate: rate), fadeDuration: 0.1)
        }
    }
    func switchMode(mode: Int, rate: Float){
        if(currentMode == mode || mode == -1){
            return
        }
        print(currentMode)
        print("newMode:\(mode)")
        stopAllMusic()
        musicPlayers = []
        currentMode=mode
        musicPlay(rate: rate)
        
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
        let res: Float = (rate-1.0)/pow(5.5, Float(i+1))
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
