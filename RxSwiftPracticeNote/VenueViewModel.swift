//
//  VenueViewModel.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/15.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON
import FoursquareAPIClient

class VenueViewModel {
    
    fileprivate(set) var venues = Variable<[Venue]>([])
    
    //ForesquareのAPIクライアントのインスタンス
    let client = VenuesAPIClient()

    //disposeBagの定義
    let disposeBag = DisposeBag()
    
    //イニシャライザ
    init() {}

    //APIクライアント経由で情報を取得する
    public func fetch(query: String = "") {

        //APIクライアントのメソッドを実行する
        client.search(query: query)
            .subscribe { [weak self] result in
                
                //結果取得ができた際には、APIクライアントの変数:venuesに結果の値を入れる
                switch result {
                case .next(let value):
                    self?.venues.value = value
                case .error(let error):
                    print(error)
                case .completed:
                    ()
                }
            }
            .disposed(by: disposeBag)
    }
}
