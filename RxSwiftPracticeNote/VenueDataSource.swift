//
//  VenueDataSource.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/15.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VenueDataSource: NSObject, RxTableViewDataSourceType, UITableViewDataSource {

    //エイリアスの設定
    public typealias Element = [Venue]
    
    //FourSquareからのベニュー情報格納用の変数
    fileprivate var venues = [Venue]()
    
    //RxTableViewDataSourceTypeのメソッドを拡張して設定する
    public func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .next(let value):
            self.venues = value
            tableView.reloadData()
        case .error(_):
            ()
        case .completed:
            ()
        }
    }
    
    //UITableViewDataSourceでセクション数を返すメソッド
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //UITableViewDataSourceでセクションに表示するセル数を返すメソッド
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.venues.count
    }

    //UITableViewDataSourceでセルの編集有無を設定するメソッド
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    //UITableViewDataSourceでセルの編集有無を設定するメソッド
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath)

        //TODO: 自前で用意したセルに値を入れる
        
        return cell
    }
    
}
