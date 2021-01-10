//
//  RepositoryListController.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/12.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper
import RxAlamofire

/*
  ===========
  2018/06/05 XCode9.4 & Swift4.1系へコンバート対応
  対応内容まとめ: メソッドの書き方が変わっていた部分の対応(全体的に)

  2018/12/29 XCode10.1 & Swift4.2系へコンバート対応
  対応内容まとめ: Variableの書き直しと全体的なアップデート
  ===========

 【Chapter2】GithubのAPIを利用してuser名を検索してリポジトリ一覧をUITableViewに一覧表示をするプラクティス
 
 このサンプルを作成する上での参考資料
 -----------
 ・通信+便利ライブラリを使用してにRxSwiftを使用した「View層 + Model層 + ViewModel層」のサンプル
 -----------
 【写したサンプルコード（一部だけカスタマイズ）】
 ・解説（英語）
 http://www.thedroidsonroids.com/blog/ios/rxswift-examples-4-multithreading/
 ・リポジトリ ※他にもサンプルたくさんある
 https://github.com/DroidsOnRoids/RxSwiftExamples/tree/master/Libraries%20Usage/RxAlamofireExample/RxAlamofireExample
 
 （参考）Webアプリケーション開発者から見た、MVCとMVP、そしてMVVMの違い
 http://qiita.com/shinkuFencer/items/f2651073fb71416b6cd7

 （参考）MVVM入門（objc.io #13 Architecture 日本語訳）
 http://qiita.com/FuruyamaTakeshi/items/6c4404f1fd61e3fa4eb7

 【GithubのAPIについて】
 https://developer.github.com/guides/getting-started/
 */

class RepositoryListController: UIViewController {

    //UIパーツの配置
    @IBOutlet weak var nameSearchBar: UISearchBar!
    @IBOutlet weak var repositoryListTableView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
 
    //disposeBagの定義
    let disposeBag = DisposeBag()
    
    //ViewModelのインスタンス格納用のメンバ変数
    var repositoriesViewModel: RepositoriesViewModel!
    
    //検索ボックスの値変化を監視対象にする（テキストが空っぽの場合はデータ取得を行わない）
    var rx_searchBarText: Observable<String> {
        return nameSearchBar.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .filter { $0.count > 0 }
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) //0.5秒のバッファを持たせる
            .distinctUntilChanged()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //RxSwiftでの処理に関する部分をまとめたメソッドを実行
        setupRx()
        
        //RxSwiftを使用しない処理に関する部分をまとめたメソッド実行
        setupUI()
    }

    //ViewModelを経由してGithubの情報を取得してテーブルビューに検索結果を表示する
    func setupRx() {

        /**
         * メンバ変数の初期化（検索バーでの入力値の更新をトリガーにしてViewModel側に設置した処理を行う）
         *
         * (フロー1) → 検索バーでの入力値の更新が「データ取得のトリガー」になるので、ViewModel側に定義したfetchRepositories()メソッドが実行される
         * (フロー2) → fetchRepositories()メソッドが実行後は、ViewModel側に定義したメンバ変数rx_repositoriesに値が格納される
         *
         * 結果的に、githubのアカウント名でのインクリメンタルサーチのようになる
         */
        repositoriesViewModel = RepositoriesViewModel(withNameObservable: rx_searchBarText)

        /**
         *（UI表示に関する処理の流れの概要）
         *
         * リクエストをして結果が更新されるたびにDriverからはobserverに対して通知が行われ、
         * driveメソッドでバインドしている各UIの更新が働くようにしている。
         * 
         * (フロー1) → テーブルビューへの一覧表示
         * (フロー2) → 該当データが0件の場合のポップアップ表示
         */

        //リクエストした結果の更新を元に表示に関する処理を行う（テーブルビューへのデータ一覧の表示処理）
        repositoriesViewModel
            .rx_repositories
            .drive(repositoryListTableView.rx.items) { (tableView, i, repository) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: IndexPath(row: i, section: 0))
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = repository.html_url
                
                return cell
            }
            .disposed(by: disposeBag)
        
        //リクエストした結果の更新を元に表示に関する処理を行う（取得したデータの件数に応じたエラーハンドリング処理）
        repositoriesViewModel
            .rx_repositories
            .drive(onNext: { repositories in
                
                //データ取得ができなかった場合だけ処理をする
                if repositories.count == 0 {
                    
                    let alert = UIAlertController(title: ":(", message: "No repositories for this user.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    //ポップアップを閉じる
                    if self.navigationController?.visibleViewController is UIAlertController != true {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    //キーボードのイベント監視の設定 ＆ テーブルビューに付与したGestureRecognizerに関する処理
    //この部分はRxSwiftの処理ではないので切り離して書かれている形？
    func setupUI() {
        
        /**
         * 2017/01/14: 補足事項
         *
         * Notification周りやGesture周りもRxでの記載が可能
         *
         * (記載例)
         * ----------
         * Notification: 
         * ----------
         * NotificationCenter.default.rx.notification(.UIKeyboardWillChangeFram) ...
         * NotificationCenter.default.rx.notification(.UIKeyboardWillHide) ...
         *
         * ----------
         * Gesutre:
         * ----------
         * let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped(_:)))
         * let didTap = stap.rx.event ...
         * 
         * → NotificationやGestureに関しても、このような記述をすることでObservableとして利用可能！
         *
         * (さらに参考になった資料)【RxSwift入門】普段使ってるこんなんもRxSwiftで書けるんよ
         * http://qiita.com/ikemai/items/8d3efcc71ea9db340484
         *
         * RxKeyboard:
         * https://github.com/RxSwiftCommunity/RxKeyboard/blob/master/Sources/RxKeyboard.swift
         */

        //テーブルビューにGestureRecognizerを付与する
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped(_:)))
        repositoryListTableView.addGestureRecognizer(tap)

        //キーボードのイベントを監視対象にする
        //Case1. キーボードを開いた場合のイベント
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        //Case2. キーボードを閉じた場合のイベント
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    //キーボード表示時に発動されるメソッド
    @objc func keyboardWillShow(_ notification: Notification) {
        
        //キーボードのサイズを取得する（英語のキーボードが基準になるので日本語のキーボードだと少し見切れてしまう）
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
     
        //一覧表示用テーブルビューのAutoLayoutの制約を更新して高さをキーボード分だけ縮める
        tableViewBottomConstraint.constant = keyboardFrame.height
        UIView.animate(withDuration: 0.3, animations: {
            self.view.updateConstraints()
        })
    }

    //キーボード非表示表示時に発動されるメソッド
    @objc func keyboardWillHide(_ notification: Notification) {
        
        //一覧表示用テーブルビューのAutoLayoutの制約を更新して高さを元に戻す
        tableViewBottomConstraint.constant = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.view.updateConstraints()
        })
    }
    
    //メモリ解放時にキーボードのイベント監視対象から除外する
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //テーブルビューのセルタップ時に発動されるメソッド
    @objc func tableTapped(_ recognizer: UITapGestureRecognizer) {
        
        //どのセルがタップされたかを探知する
        let location = recognizer.location(in: repositoryListTableView)
        let path = repositoryListTableView.indexPathForRow(at: location)
        
        //キーボードが表示されているか否かで処理を分ける
        if nameSearchBar.isFirstResponder {
            
            //キーボードを閉じる
            nameSearchBar.resignFirstResponder()

        } else if let path = path {
            
            //タップされたセルを中央位置に持ってくる
            repositoryListTableView.selectRow(at: path, animated: true, scrollPosition: .middle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
