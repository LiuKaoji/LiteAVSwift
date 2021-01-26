//
//  LyricsVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2021/1/25.
//  Copyright © 2021 kaoji. All rights reserved.
//

import UIKit

class LyricsVC: RoomVC {
    
    /// 歌词数据
    var lyricsArray :Array<LRCItem>!
    /// last
    var lastLRC :String = ""
    /// last
    var lastIndex :Int = 0
    
    /// 歌词显示
    var miniLrcView: UILabel!
    var lrcViewContainView: UIView!
    
    //重播
    var refreshBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }
    
    func prepare() {
        
        /// 解释歌词
        let parser = LRCParser.init()
        lyricsArray = parser.processLRC(path: Bundle.main.path(forResource: "duoxingyun", ofType: "txt")!)
        for item in lyricsArray {
            debugPrint("\(item.lrcTime): \(item.lrc)")
        }
        
        lrcViewContainView = UIView()
        lrcViewContainView.backgroundColor = rgba(0, 0, 0, 0.3)
        self.view.addSubview(lrcViewContainView)
        lrcViewContainView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom)
            make.height.equalTo((isBangDevice ?74:40))
            make.left.width.equalToSuperview()
        }
        
        //底部工具栏
        miniLrcView = UILabel()
        miniLrcView.textColor = .white
        miniLrcView.textAlignment = .center
        lrcViewContainView.addSubview(miniLrcView)
        miniLrcView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp.bottom).offset(isBangDevice ? -34:0)
            make.left.width.top.equalToSuperview()
        }
        
        //refreshBtn
        refreshBtn = UIButton()
        refreshBtn.setImage(UIImage.init(named: "refresh_red"), for: .normal)
        refreshBtn.isHidden = true
        refreshBtn.addTarget(self, action: #selector(startPlayMusic), for: .touchUpInside)
        self.view.addSubview(refreshBtn)
        refreshBtn.snp.makeConstraints { (make) in
            make.size.equalTo(60)
            make.centerX.centerY.equalToSuperview()
        }
    }
    
   @objc func startPlayMusic(){
        let audioParam = TXAudioMusicParam()
        audioParam.id = 1000
        audioParam.path = Bundle.main.path(forResource: "duoxingyun", ofType: "mp3")!
        trtc.getAudioEffectManager()?.startPlayMusic(audioParam, onStart: { (code) in
            
            if (code == 0) {
                self.lrcViewContainView.isHidden = false
                self.refreshBtn.isHidden = true
            }

        }, onProgress: { [self] (progressMs, durationMs) in
            
            for (index,element) in lyricsArray.enumerated().reversed(){
                
                if element.lrcTime < progressMs/1000 && lastLRC != element.lrc && index > lastIndex{
                    let result =  trtc.sendSEIMsg(element.lrc.data(using: .utf8), repeatCount: 2)
                    lastLRC = element.lrc
                    lastIndex = index
                    self.displayLRC(lyrics: element.lrc)
                    debugPrint("[歌词发送]:\(element.lrc) 结果:\(result)")
                    break
                }
            }
            
        }, onComplete: { (code) in
            self.lrcViewContainView.isHidden = true
            self.refreshBtn.isHidden = false
            self.lastLRC = ""
            self.lastIndex  = 0
        })
        
    }
    
    override func onEnterRoom(_ result: Int) {
        
        guard param.role == .anchor && result > 0  else {
            return
        }
        startPlayMusic()
    }
    
    override func onRecvSEIMsg(_ userId: String, message: Data) {
        
        guard param.role == .audience else {
            return
        }
        let lyrics = String.init(data: message, encoding: .utf8)
        DispatchQueue.main.async {
            self.displayLRC(lyrics: lyrics ?? "数据异常")
        }
    }
    
    @objc func displayLRC(lyrics: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideLyrics), object: nil)
        self.lrcViewContainView.isHidden = false
        self.miniLrcView.text = lyrics
        self.perform(#selector(hideLyrics), with: nil, afterDelay: 7)
    }
    
    @objc func hideLyrics() {
        self.lrcViewContainView.isHidden = true
    }
    
}
