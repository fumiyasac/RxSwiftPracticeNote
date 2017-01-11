//
//  RamenPresenter.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/11.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

//TODO: コメントの記載をちゃんとする
class RamenPresenter {
    
    //表示用のデータの具体的な設定をする
    let ramens = Observable.just([

        //TODO: コメントの記載をちゃんとする
        SectionModel(model: "醤油", items: [
            Ramen(name: "豚骨醤油ラーメン",taste: "濃いめ", imageId: "sample005"),
            Ramen(name: "喜多方ラーメン", taste: "あっさり", imageId: "sample009"),
            Ramen(name: "チャーシューメン", taste: "あっさり", imageId: "sample010")
        ]),

        SectionModel(model: "塩味", items: [
            Ramen(name: "野菜たっぷりタンメン", taste: "あっさり", imageId: "sample007")
        ]),

        SectionModel(model: "味噌", items: [
            Ramen(name: "8番ラーメン味噌味", taste: "ふつう", imageId: "sample001"),
            Ramen(name: "もやしそば味噌味", taste: "濃いめ", imageId: "sample008")
        ]),

        SectionModel(model: "その他", items: [
            Ramen(name: "台湾風まぜそば", taste: "濃いめ", imageId: "sample002"),
            Ramen(name: "長崎ちゃんぽん", taste: "ふつう", imageId: "sample003"),
            Ramen(name: "酸辣湯麺", taste: "ふつう", imageId: "sample004"),
            Ramen(name: "トマトと野菜のラーメン", taste: "あっさり", imageId: "sample006")
        ])
    ])

}
