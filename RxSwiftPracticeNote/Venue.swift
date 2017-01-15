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

//ForesquareAPIから取得した情報に関する定義（Model層に該当）
struct Venue: CustomStringConvertible {
    
    let venueId: String
    let name: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
    let categoryIconURL: URL?

    //取得データの詳細に関する変数
    var description: String {
        return "<venueId=\(venueId)"
            + ", name=\(name)"
            + ", address=\(address)"
            + ", latitude=\(latitude), longitude=\(longitude)"
            + ", categoryIconURL=\(categoryIconURL)>"
    }
    
    //イニシャライザ（取得したForesquareAPIからのレスポンスに対して必要なものを抽出する）
    init(json: JSON) {

        //ForesquareAPIからのレスポンスで主要情報を取得する(SWiftyJSONを使用)
        self.venueId = json["id"].string ?? ""
        self.name = json["name"].string ?? ""
        self.address = json["location"]["address"].string
        self.latitude = json["location"]["lat"].double
        self.longitude = json["location"]["lng"].double
        
        //ForesquareAPIからのレスポンスでカテゴリーを元にしてアイコンのURLを作成する(SWiftyJSONを使用)
        if let categories = json["categories"].array, categories.count > 0 {
            let prefix = json["categories"][0]["icon"]["prefix"].string ?? ""
            let suffix = json["categories"][0]["icon"]["suffix"].string ?? ""
            let iconUrlString = String(format: "%@%d%@", prefix, kCategoryIconSize, suffix)
            self.categoryIconURL = URL(string: iconUrlString)
        }
        else {
            self.categoryIconURL = nil
        }
    }
}
