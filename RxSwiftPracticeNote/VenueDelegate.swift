//
//  VenueDelegate.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/15.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit

class VenueDelegate: NSObject, UITableViewDelegate {

    //UITableViewDelegateでテーブルビューの高さを返すメソッド
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
