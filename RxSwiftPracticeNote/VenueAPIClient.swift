//
//  VenueAPIClient.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/15.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON
import FoursquareAPIClient

//Foresquareのベニュー情報を取得用のクライアント部分(実際のデータ通信部分)
class VenuesAPIClient {

    //クエリ文字列を元に検索を行う
    func search(query: String = "") -> Observable<[Venue]> {

        //Observable戻り値に対して
        return Observable.create{ observer in

            //APIクライアントへのアクセス用の設定
            let client = FoursquareAPIClient(
                clientId: APIKey.foresquare_clientid.rawValue,
                clientSecret: APIKey.foresquare_clientsecret.rawValue
            )

            //検索用のパラメータの設定（暫定的に東京メトロ新大塚駅にしています）
            let parameter: [String : String] = [
                "ll": "35.7260747,139.72983",
                "query": query
            ];

            //クライアントへのアクセス
            client.request(path: "venues/search", parameter: parameter) {
                [weak self] data, error in
                
                //
                guard let strongSelf = self, let data = data else { return }
                
                //
                let json = JSON(data: data)
                let venues = strongSelf.parse(venuesJSON: json["response"]["venues"])
                
                //パースしてきたjsonの値を通知対象にする
                //(参考)RxSwiftの動作を深く理解する
                //http://qiita.com/k5n/items/643cc07e3973dd1fded4
                observer.on(.next(venues))
                observer.on(.completed)
            }
            
            //この取得処理を監視対象からはずすための処理（自信ない...）
            return Disposables.create {}
        }
    }
    
    //Venue.swift(Model層)で定義した形で取得した値を格納する
    fileprivate func parse(venuesJSON: JSON) -> [Venue] {
        var venues = [Venue]()
        for (key: _, venueJSON: JSON) in venuesJSON {
            venues.append(Venue(json: JSON))
        }
        return venues
    }
}
