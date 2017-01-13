//
//  Repository.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/12.
//  Copyright © 2017年 just1factory. All rights reserved.
//

/**
 * GithubのAPIより取得する項目を定義する（ObjectMapperを使用して表示したいものだけを抽出してマッピングする）
 * Model層に該当する部分
 */
import ObjectMapper

class Repository: Mappable {

    //表示する値を変数として定義
    var identifier: Int!
    var html_url: String!
    var name: String!
    
    //イニシャライザ
    required init?(map: Map) {}
    
    //ObjectMapperを利用したデータのマッピング
    func mapping(map: Map) {
        identifier <- map["id"]
        html_url <- map["html_url"]
        name <- map["name"]
    }
}
