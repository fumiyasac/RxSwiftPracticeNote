//
//  Ramen.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/11.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit

//UITableViewやUICollectionViewのDataSourceをRxSwiftで扱う場合はこれが必要（Podfile参照）
import RxDataSources

//ラーメンデータ定義用の構造体(Model層)
struct Ramen {

    //取得データに関する定義
    let name: String
    let taste: String
    let imageId: String
    var image: UIImage?
    
    //取得データのイニシャライザ
    init(name: String, taste: String, imageId: String) {
        self.name = name
        self.taste = taste
        self.imageId = imageId
        image = UIImage(named: imageId)
    }
}

//TODO: コメントの記載をちゃんとする
extension Ramen: IdentifiableType {
    typealias Identity = String
    var identity: Identity { return imageId }
}



