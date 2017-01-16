//
//  VenueSearchViewController.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/15.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

/*
 【Chapter3】FoursquareAPIを利用して検索した場所を表示するプラクティス
 
 このサンプルを作成する上での参考資料
 -----------
 ・通信+便利ライブラリを使用してにRxSwiftを使用した「View層 + Model層 + ViewModel層」のサンプル
 -----------
 【参考にさせて頂いたサンプルコード（一部カスタマイズ）】

 ・解説（ありがとうございました！）
 http://blog.koogawa.com/entry/2016/10/23/195454

 ・リポジトリ
 https://github.com/koogawa/RxSwiftSample
 
 （参考）Webアプリケーション開発者から見た、MVCとMVP、そしてMVVMの違い
 http://qiita.com/shinkuFencer/items/f2651073fb71416b6cd7
 
 （参考）MVVM入門（objc.io #13 Architecture 日本語訳）
 http://qiita.com/FuruyamaTakeshi/items/6c4404f1fd61e3fa4eb7
 
 （参考）RxSwiftを使ってアプリを作ってみて、よく使った書き方
 http://qiita.com/Tueno@github/items/099d287217b38c314e1e
 
 【FoursquareのAPIについて】
 https://developer.foursquare.com/
 */
class VenueSearchViewController: UIViewController {

    //UIパーツの配置
    @IBOutlet weak var venueSearchTableView: UITableView!
    @IBOutlet weak var venueSearchBar: UISearchBar!
    @IBOutlet weak var bottomVenueTableConstraint: NSLayoutConstraint!

    //ViewModel・デリゲート・データソースのインスタンスを設定
    var venueViewModel = VenueViewModel()
    var venueDataSource = VenueDataSource()
    var venueDelegate = VenueDelegate()

    //disposeBagの定義
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //RxSwiftでの処理に関する部分をまとめたメソッドを実行
        setupRx()

        //RxSwiftを使用しない処理に関する部分をまとめたメソッド実行
        setupUI()
    }
    
    //データ表示用のテーブルビュー内にForesquareから取得した情報を表示する
    fileprivate func setupRx() {

        //配置したテーブルビューにデリゲートの適用をする
        venueSearchTableView.delegate = self.venueDelegate
        
        //Xibのクラスを読み込む宣言を行う
        let nibTableView: UINib = UINib(nibName: "VenueCell", bundle: nil)
        venueSearchTableView.register(nibTableView, forCellReuseIdentifier: "VenueCell")
        
        //検索バーの変化から0.5秒後に.driveメソッド内の処理を実行する
        venueSearchBar.rx.text.asDriver()
            .throttle(0.5)
            .drive(onNext: { query in
                
                //ViewModelに定義したfetchメソッドを実行
                self.venueViewModel.fetch(query: query!)
            })
            .addDisposableTo(disposeBag)
        
        //データの取得ができたらテーブルビューのデータソースの定義に則って表示する値を設定する
        venueViewModel.venues
            .asDriver()
            .drive (
                self.venueSearchTableView.rx.items(dataSource: self.venueDataSource)
            )
            .addDisposableTo(disposeBag)
        
        //テーブルビューのセルを選択した際の処理
        venueSearchTableView.rx.itemSelected
            
            //テーブルビューのセルを選択した場合にはindexPathを元にセルの情報を取得する
            .bindNext { [weak self] indexPath in
                
                //この値を元に具体的な処理を記載する
                if let venue = self?.venueViewModel.venues.value[indexPath.row] {
                    
                    //PLAN: 場所の表示だけではなく何かしらアレンジできればGood!
                    
                    //キーボードが表示されていたらキーボードを閉じる
                    if (self?.venueSearchBar.isFirstResponder)! {
                        self?.venueSearchBar.resignFirstResponder()
                    }
                    
                    //Foursquareのページを表示する
                    let urlString = "https://foursquare.com/v/" + venue.venueId
                    if let url = URL(string: urlString) {
                        let safariViewController = SFSafariViewController(url: url)
                        self?.present(safariViewController, animated: true, completion: nil)
                    }
                    
                    //DEBUG: 取得データに関するチェック
                    print("-----------")
                    print(venue.venueId)
                    print(venue.name)
                    print(venue.city)
                    print(venue.state)
                    print(venue.address ?? "")
                    print(venue.latitude ?? "")
                    print(venue.longitude ?? "")
                    print(venue.categoryIconURL ?? "")
                    print("-----------")
                    print("")

                }
            }
            .addDisposableTo(disposeBag)
    }

    func setupUI() {
        
        //キーボードのイベントを監視対象にする
        //Case1. キーボードを開いた場合のイベント
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        
        //Case2. キーボードを閉じた場合のイベント
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    //キーボード表示時に発動されるメソッド
    func keyboardWillShow(_ notification: Notification) {
        
        //キーボードのサイズを取得する（英語のキーボードが基準になるので日本語のキーボードだと少し見切れてしまう）
        guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        //一覧表示用テーブルビューのAutoLayoutの制約を更新して高さをキーボード分だけ縮める
        bottomVenueTableConstraint.constant = keyboardFrame.height
        UIView.animate(withDuration: 0.3, animations: {
            self.view.updateConstraints()
        })
    }
    
    //キーボード非表示表示時に発動されるメソッド
    func keyboardWillHide(_ notification: Notification) {
        
        //一覧表示用テーブルビューのAutoLayoutの制約を更新して高さを元に戻す
        bottomVenueTableConstraint.constant = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.updateConstraints()
        })
    }
    
    //メモリ解放時にキーボードのイベント監視対象から除外する
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
