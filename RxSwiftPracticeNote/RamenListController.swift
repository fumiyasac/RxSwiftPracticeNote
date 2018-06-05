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
  ===========
  2018/06/05 XCode9.4 & Swift4.1系へコンバート対応
  対応内容まとめ: RxTableViewSectionedReloadDataSourceの書き方が変わっていた部分の対応
  ===========
 
 【Chapter1】ラーメンの一覧をRxDataSourcesを利用してUITableViewに一覧表示をするプラクティス
 
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
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Ramen>>(

        //データソースを元にしてセルの生成を行う
        configureCell: { (_, tableView, indexPath, ramens) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = ramens.name
            cell.detailTextLabel?.text = ramens.taste
            cell.imageView?.image = ramens.image
            return cell
        },

        //データソースの定義を元にセクションヘッダーを生成する ※動画サンプルと形式が違う部分
        titleForHeaderInSection: { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }
    )
    
    //UIパーツの配置
    @IBOutlet weak var ramenTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //作成したデータと表示するUITableViewをBindして表示する
        ramensData.ramens.bind(to: ramenTableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)

        //RxSwiftを利用してUITableViewDelegateを適用する
        //(参考) https://cocoapods.org/pods/RxReusable
        ramenTableView.rx.setDelegate(self).disposed(by: disposeBag)
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
