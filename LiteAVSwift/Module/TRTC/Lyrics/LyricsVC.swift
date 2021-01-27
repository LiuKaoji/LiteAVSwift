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
    var lastLRC :String = ""
    var lastIndex :Int = 0
    var currentRow :Int = 0
    
    var lyricsView: LyricsView!
    
    var isDrag = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepare()
    }
    
    func prepare() {
        
        lyricsView = LyricsView.init(role: param.role)
        lyricsView.backgroundColor = .clear
        self.view.addSubview(lyricsView)
        lyricsView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(self.bottomLayoutGuide.snp.bottom)
            }
            make.top.equalTo(trtcRoomView.backBtn.snp.bottom)
            make.left.width.equalToSuperview()
        }
        
        /// 返回按钮
        trtcRoomView.backBtn.rx.tap.subscribe { [weak self] _ in
            
            self?.stopLocal()
            self?.trtc.exitRoom()
            
        }.disposed(by: disposeBag)
        
        ///=======================以下是主播需要=========================
        guard self.param.role == .anchor else {
            return
        }
        
        /// 播放按钮
        lyricsView.playBtn.rx.tap.subscribe { [weak self] _ in
            
            self?.startPlayMusic()
            
        }.disposed(by: disposeBag)
        
        /// 解释歌词
        let parser = LRCParser.init()
        lyricsArray = parser.processLRC(path: Bundle.main.path(forResource: "yisibugua", ofType: "txt")!)
        for item in lyricsArray {
            debugPrint("\(item.lrcTime): \(item.lrc)")
        }
        
        /// tableView 数据源
        let items = Observable.just(
            (0..<lyricsArray.count - 1).map { lyricsArray[$0] }
        )
        items.bind(to: lyricsView.tableView.rx.items(cellIdentifier: "lyricsCellId", cellType: UITableViewCell.self)) { [weak self](row, element, cell) in
            cell.textLabel?.text = element.lrc
            cell.backgroundColor = .clear
            cell.textLabel?.textAlignment = .center
            if (self?.lastIndex == row) {
                cell.textLabel?.textColor = .green
            }else{
                cell.textLabel?.textColor = .white
            }
        }.disposed(by: disposeBag)
        
        /// tableView 拖拽事件
        Observable.zip([lyricsView.tableView.rx.willBeginDragging.asObservable(),
                        lyricsView.tableView.rx.willBeginDragging.asObservable(),
                        lyricsView.tableView.rx.didEndDecelerating.asObservable()
        ]).subscribe { [weak self] _ in
            
            self?.isDrag = self!.lyricsView.tableView.isDragging
            
        }.disposed(by: disposeBag)

    }
    
   @objc func startPlayMusic(){
        let audioParam = TXAudioMusicParam()
        audioParam.id = 1000
        audioParam.path = Bundle.main.path(forResource: "yisibugua", ofType: "mp3")!
        trtc.getAudioEffectManager()?.startPlayMusic(audioParam, onStart: { (code) in
            
            if (code == 0) {
                self.lyricsView.miniLrcView.isHidden = false
                self.lyricsView.playBtn.isHidden = (self.param.role == .anchor ?true:false)
            }

        }, onProgress: { [self] (progressMs, durationMs) in
            
            for (index,element) in lyricsArray.enumerated().reversed(){
                
                if element.lrcTime <= progressMs && lastLRC != element.lrc && index > lastIndex{
                    ///歌词发送
                    let result =  trtc.sendSEIMsg(element.lrc.data(using: .utf8), repeatCount: 1)
                    lastLRC = element.lrc
                    lastIndex = index
                    //self.displayLRC(lyrics: element.lrc)
                    debugPrint("[歌词发送]:\(element.lrc) 结果:\(result)")
                    
                    /// UI更新
                    if !isDrag && param.role == .anchor && index < lyricsArray.count - 1{
                        let indexPath = IndexPath.init(row: index, section: 0)
                        self.lyricsView.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                        self.lyricsView.tableView.reloadData()
                    }
                    
                    break
                }
            }
            
        }, onComplete: { [weak self] (code) in
            self?.lyricsView.playBtn.isHidden = (self?.param.role == .anchor ?false:true)
            self?.lastLRC = ""
            self?.lastIndex  = 0
        })
        
    }
    
    override func onEnterRoom(_ result: Int) {
        
       debugPrint("[进房onEnterRoom]-Result-:\(result)")
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
        self.lyricsView.miniLrcView.isHidden = false
        self.lyricsView.miniLrcView.text = lyrics
        self.perform(#selector(hideLyrics), with: nil, afterDelay: 7)
    }
    
    @objc func hideLyrics() {
        self.lyricsView.miniLrcView.isHidden =  true
    }
    
}
