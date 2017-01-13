//
//  RepositoriesViewModel.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/12.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import ObjectMapper
import RxAlamofire
import RxCocoa
import RxSwift

/**
 * リクエストで受け取った結果をDriverに変換するための部分
 * ViewModel層に該当する部分
 *
 * (参考)RxSwiftでUIの更新にはDriverを使ってみたまとめ
 * http://qiita.com/mafmoff/items/e8786cd75c292cdc3ec0
 */
struct RepositoriesViewModel {

    /**
     * オブジェクトの初期化に合わせてプロパティの初期値を決定したいのでlazy varにする
     *
     * (参考)Swiftのlazyの使い所
     * http://blog.sclap.info/entry/swift-how-to-use-lazy
     */
    lazy var rx_repositories: Driver<[Repository]> = self.fetchRepositories()
    
    //監視対象のメンバ変数
    fileprivate var repositoryName: Observable<String>
    
    //監視対象の変数初期化処理(イニシャライザ)
    init(withNameObservable nameObservable: Observable<String>) {
        self.repositoryName = nameObservable
    }
    
    /**
     * GithubAPIへアクセスしてデータを取得してViewController側のUI処理とバインドするためにDriverに変換をする処理
     * (※データ取得にはRxAlamofireを使用)
     *
     * Driverパターンのデータの流れ方や設定に関しては下記の資料を参考にしました
     *
     * (参考1)RxSwiftと愉快な仲間たち / RxSwift with Units
     * https://speakerdeck.com/mihyaeru21/rxswift-with-units
     *
     * (参考2)RxSwiftをつかってMVVMアーキテクチャを実装する
     * https://tech.recruit-sumai.co.jp/rxswift-mvvm/
     */
    fileprivate func fetchRepositories() -> Driver<[Repository]> {
        
        /**
         * Observableな変数に対して、「.subscribeOn」→「.observeOn」→「.observeOn」...という形で数珠つなぎで処理を実行
         * 処理の終端まで無事にたどり着いた場合には、
         *
         * (参考)RxSwiftで実行するSchedulerの作り方とお行儀良く扱うためのメモ
         * http://blog.sgr-ksmt.org/2016/03/15/rxswift_scheduler/
         */
        return repositoryName
            
            //処理Phase1: 見た目に関する処理
            .subscribeOn(MainScheduler.instance) //メインスレッドで処理を実行する
            .do(onNext: { response in

                //ネットワークインジケータを表示状態にする
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
            
            //処理Phase2: 下記のAPI(GithubAPI)のエンドポイントへRxAlamofire経由でのアクセスをする
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background)) //バックグラウンドスレッドで処理を実行する
            .flatMapLatest { text in
                
                //APIからデータを取得する
                return RxAlamofire
                    .requestJSON(.get, "https://api.github.com/users/\(text)/repos")
                    .debug()
                    .catchError { error in
                        
                        //エラー発生時の処理(この場合は値を持たせずにここで処理を止めてしまう)
                        return Observable.never()
                }
            }
            
            //処理Phase3: ModelクラスとObjectMapperで定義した形のデータを作成する
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background)) //バックグラウンドスレッドで処理を実行する
            .map { (response, json) -> [Repository] in

                //APIからレスポンスが取得できた場合にはModelクラスに定義した形のデータを返却する
                if let repos = Mapper<Repository>().mapArray(JSONObject: json) {
                    return repos
                } else {
                    return []
                }
            }

            //処理Phase4: データが受け取れた際の見た目に関する処理とDriver変換
            .observeOn(MainScheduler.instance) //メインスレッドで処理を実行する
            .do(onNext: { response in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false //ネットワークインジケータを非表示状態にする
            })
            .asDriver(onErrorJustReturn: []) //Driverに変換する
    }
}
