//
//  Venue.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/15.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit
import SwiftyJSON

//アイコンのサイズに関する定数
//(参考)https://developer.foursquare.com/docs/responses/category
let kCategoryIconSize = 88

//
/**
 * ForesquareAPIから取得した情報に関する定義（Model層に該当）
 * 
 * (参考)【iOS Swift入門 #255】独自クラスでログ出力(description)を実装する
 * http://swift.swift-studying.com/entry/2015/09/14/090849
 */
struct Venue: CustomStringConvertible {
    
    let venueId: String
    let name: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let state: String?
    let city: String?
    let categoryIconURL: URL?

    //取得データの詳細に関する変数
    var description: String {
        return "<venueId=\(venueId)"
            + ", name=\(name)"
            + ", address=\(String(describing: address))"
            + ", latitude=\(String(describing: latitude)), longitude=\(String(describing: longitude))"
            + ", state=\(String(describing: state))"
            + ", city=\(String(describing: city))"
            + ", categoryIconURL=\(String(describing: categoryIconURL))>"
    }
    
    //イニシャライザ（取得したForesquareAPIからのレスポンスに対して必要なものを抽出する）
    init(json: JSON) {

        //ForesquareAPIからのレスポンスで主要情報を取得する(SWiftyJSONを使用)
        self.venueId = json["id"].string ?? ""
        self.name = json["name"].string ?? ""
        self.address = json["location"]["address"].string
        self.latitude = json["location"]["lat"].double
        self.longitude = json["location"]["lng"].double
        self.state = json["location"]["state"].string ?? ""
        self.city = json["location"]["city"].string ?? ""
        
        //ForesquareAPIからのレスポンスでカテゴリーを元にしてアイコンのURLを作成する(SWiftyJSONを使用)
        if let categories = json["categories"].array, categories.count > 0 {
            let iconPrefix = json["categories"][0]["icon"]["prefix"].string ?? ""
            let iconSuffix = json["categories"][0]["icon"]["suffix"].string ?? ""
            let iconUrlString = String(format: "%@%d%@", iconPrefix, kCategoryIconSize, iconSuffix)
            self.categoryIconURL = URL(string: iconUrlString)
        }
        else {
            self.categoryIconURL = nil
        }
    }
}
