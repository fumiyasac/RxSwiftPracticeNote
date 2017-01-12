//
//  RamenListController.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/11.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

/*
 【Chapter1】ラーメンの一覧をRxDataSourcesを利用してUITableViewに一覧表示をするサンプル
 
 このサンプルを作成する上での参考資料
 -----------
 ・通信を伴わないRxSwiftを使用した「View層 + Model層 + Presenter層」のサンプル
 -----------
 [RxSwift] SectionありのDataSourceを生成する
 http://baroqueworksdevjp.blogspot.jp/2016/04/rxswift-sectiondatasource.html

 （英語が怪しい？感じだったので映像のコードを写した形にしています）
 https://www.youtube.com/watch?v=aSP8sb2v2ms
 https://www.youtube.com/watch?v=en0JpiEiM-4
 
 【Observerパターンについて】オブザーバーパターンから始めるRxSwift入門
 http://qiita.com/k5n/items/17f845a75cce6b737d1e
 
 【写真素材について】足成
 http://www.ashinari.com/
 */

class RamenListController: UIViewController {

    //監視対象のオブジェクトの一括解放用
    let disposeBag = DisposeBag()
    
    //Presenter層から表示するラーメンデータの取得
    let ramensData = RamenPresenter()
    
    //データソースの定義
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Ramen>>()
    
    //UIパーツの配置
    @IBOutlet weak var ramenTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //データソースを元にしてセルの生成を行う
        dataSource.configureCell = {_, tableView, indexPath, ramens in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = ramens.name
            cell.detailTextLabel?.text = ramens.taste
            cell.imageView?.image = ramens.image
            return cell
        }

        //作成したデータと表示するUITableViewをBindして表示する
        ramensData.ramens.bindTo(ramenTableView.rx.items(dataSource: dataSource)).addDisposableTo(disposeBag)

        //RxSwiftを利用してUITableViewDelegateを適用する
        //(参考) https://cocoapods.org/pods/RxReusable
        ramenTableView.rx.setDelegate(self).addDisposableTo(disposeBag)

        //データソースの定義を元にセクションヘッダーを生成する ※動画サンプルと形式が違う部分
        dataSource.titleForHeaderInSection = { (ds, section: Int) -> String in
            return ds[section].model
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//UITableViewCellのセル高さを設定する(UITableViewDelegate)
extension RamenListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(65)
    }
}
