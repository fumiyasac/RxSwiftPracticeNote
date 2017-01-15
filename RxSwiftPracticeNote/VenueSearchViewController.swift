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

class VenueSearchViewController: UIViewController {

    //UIパーツの配置
    @IBOutlet weak var venueSearchTableView: UITableView!
    @IBOutlet weak var venueSearchBar: UISearchBar!

    //ViewModel・デリゲート・データソースのインスタンスを設定
    var venueViewModel = VenueViewModel()
    var venueDataSource = VenueDataSource()
    var venueDelegate = VenueDelegate()

    //disposeBagの定義
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //配置したテーブルビューにデリゲートの適用をする
        venueSearchTableView.delegate = self.venueDelegate
        
        //Xibのクラスを読み込む宣言を行う
        let nibTableView: UINib = UINib(nibName: "VenueCell", bundle: nil)
        venueSearchTableView.register(nibTableView, forCellReuseIdentifier: "VenueCell")
        
        //
        venueSearchBar.rx.text.asDriver()
            .throttle(0.3)
            .drive(onNext: { query in

                //
                self.venueViewModel.fetch(query: query!)
            })
            .addDisposableTo(disposeBag)
        
        //
        venueViewModel.venues
            .asDriver()
            .drive (
                self.venueSearchTableView.rx.items(dataSource: self.venueDataSource)
            )
            .addDisposableTo(self.disposeBag)
        
        //
        venueSearchTableView.rx.itemSelected

            //
            .bindNext { [weak self] indexPath in

                //
                if let venue = self?.venueViewModel.venues.value[indexPath.row] {
                    
                    //Debug.
                    print(venue.venueId)
                    print(venue.name)
                    print(venue.address)
                    print(venue.latitude)
                    print(venue.longitude)
                    print(venue.categoryIconURL)
                }
            }
            .addDisposableTo(self.disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
