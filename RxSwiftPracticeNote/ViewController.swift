//
//  ViewController.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/10.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/*
 【Warming Up】テキストフィールドやボタンコレクションで挨拶文を作るプラクティス

 このサンプルを作成する上での参考資料
 -----------
 ・GreetingGenerator with RxSwift (iOS 8, Swift 3)
 -----------
 (1/7)
 https://www.youtube.com/watch?v=vsBQlk6EzcU
 (2/7)
 https://www.youtube.com/watch?v=GYcFCrHtYiQ
 (3/7)
 https://www.youtube.com/watch?v=mZg8drwEWfY
 (4/7)
 https://www.youtube.com/watch?v=5Ss48KHvvgc
 (5/7)
 https://www.youtube.com/watch?v=9DJgPUieZVQ
 (6/7)
 https://www.youtube.com/watch?v=lrJi1s_9wd8
 (7/7)
 https://www.youtube.com/watch?v=pBGbA-bvZF0
 
 【Observerパターンについて】オブザーバーパターンから始めるRxSwift入門
 http://qiita.com/k5n/items/17f845a75cce6b737d1e
*/

class ViewController: UIViewController {

    //監視対象のオブジェクトの一括解放用
    let disposeBag = DisposeBag()

    //SegmentedControlに対応する値の定義
    enum State: Int {
        case useButtons
        case useTextField
    }

    //UIパーツの配置
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var freeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    //初期化時の初期値の設定
    let lastSelectedGreeting: Variable<String> = Variable("こんにちは")
    
    //(注意)ここはOutletCollectionで紐づける
    //(参考)アウトレットコレクションを使う
    //http://develop.calmscape.net/dev/220/
    @IBOutlet var greetingButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //「お名前:」の入力フィールドにおいて、テキスト入力のイベントを監視対象にする
        let nameObservable: Observable<String?> = nameTextField.rx.text.asObservable()
        
        //「自由入力:」の入力フィールドにおいて、テキスト入力のイベントを監視対象にする
        let freeObservable: Observable<String?> = freeTextField.rx.text.asObservable()
        
        //(combineLatest)「お名前:」と「自由入力:」それぞれの直近の最新値同士を結合する
        let freewordWithNameObservable: Observable<String?> = Observable.combineLatest(
            nameObservable,
            freeObservable
        ) { (string1: String?, string2: String?) in
            return string1! + string2!
        }

        //(bindTo)イベントのプロパティ接続をする ※bindToの引数内に表示対象のUIパーツを設定
        //(DisposeBag)購読[監視?]状態からの解放を行う
        freewordWithNameObservable.bindTo(greetingLabel.rx.text).addDisposableTo(disposeBag)

        //セグメントコントロールにおいて、値変化のイベントを監視対象にする
        let segmentedControlObservable: Observable<Int> = stateSegmentedControl.rx.value.asObservable()
        
        //セグメントコントロールの値変化を検知して、その状態に対応するenumの値を返す
        //(map)別の要素に変換する ※IntからStateへ変換
        let stateObservable: Observable<State> = segmentedControlObservable.map {
            (selectedIndex: Int) -> State in
            return State(rawValue: selectedIndex)!
        }

        //enumの値変化を検知して、テキストフィールドが編集を受け付ける状態かを返す
        //(map)別の要素に変換する ※StateからBoolへ変換
        let greetingTextFieldEnabledObservable: Observable<Bool> = stateObservable.map {
            (state: State) -> Bool in
            return state == .useTextField
        }

        //(bindTo)イベントのプロパティ接続をする ※bindToの引数内に表示対象のUIパーツを設定
        //(DisposeBag)購読[監視?]状態からの解放を行う
        greetingTextFieldEnabledObservable.bindTo(freeTextField.rx.isEnabled).addDisposableTo(disposeBag)
        
        //テキストフィールドが編集を受け付ける状態かを検知して、ボタン部分が選択可能かを返す
        //(map)別の要素に変換する ※BoolからBoolへ変換
        let buttonsEnabledObservable: Observable<Bool> = greetingTextFieldEnabledObservable.map {
            (greetingEnabled: Bool) -> Bool in
            return !greetingEnabled
        }

        //アウトレットコレクションで接続したボタン軍に関する処理
        greetingButtons.forEach { button in
            
            //(bindTo)イベントのプロパティ接続をする ※bindToの引数内に表示対象のUIパーツを設定
            //(DisposeBag)購読[監視?]状態からの解放を行う
            buttonsEnabledObservable.bindTo(button.rx.isEnabled).addDisposableTo(disposeBag)
            
            //メンバ変数：lastSelectedGreetingにボタンのタイトル名を引き渡す
            //(subscribe)イベントが発生した場合にイベントのステータスに応じての処理を行う
            button.rx.tap.subscribe(onNext: { (nothing: Void) in
                self.lastSelectedGreeting.value = button.currentTitle!
            }).addDisposableTo(disposeBag)
        }

        //挨拶の表示ラベルにおいて、テキスト表示のイベントを監視対象にする
        let predefinedGreetingObservable: Observable<String> = lastSelectedGreeting.asObservable()

        //最終的な挨拶文章のイベント
        //(combineLatest)現在入力ないしは選択がされている項目を全て結合する
        let finalGreetingObservable: Observable<String> = Observable.combineLatest(stateObservable, freeObservable, predefinedGreetingObservable, nameObservable) { (state: State, freeword: String?, predefinedGreeting: String, name: String?) -> String in
            
            switch state {
                case .useTextField: return freeword! + name!
                case .useButtons: return predefinedGreeting + name!
            }
        }

        //最終的な挨拶文章のイベント
        //(bindTo)イベントのプロパティ接続をする ※最終的な挨拶文章を表示する
        //(DisposeBag)購読[監視?]状態からの解放を行う
        finalGreetingObservable.bindTo(greetingLabel.rx.text).addDisposableTo(disposeBag)


        /* ----- メモ2. subscribeメソッドでのイベントの受け取り -----
        //イベントを受け取った際に行われる処理をsubscribeメソッドのクロージャーに記載する → イベントのステータスに応じて処理が変わる

         ----------
         subscribeメソッドの主なイベント受け取りまとめ
         ----------
         onNext: { value in
             //通常イベント発生時の処理
         },

         onError: { error in
             //エラー発生時の処理
         },
         
         onCompleted: {
             //完了時の処理
         }
         ----------

        nameObservable.subscribe(onNext: { (string: String?) in
            self.greetingLabel.text = string
        })
        */

        
        /* ----- メモ1. subscribeメソッドでのイベントの受け取り -----
        //イベントを受け取った際に行われる処理をsubscribeメソッドのクロージャーに記載する
        nameObservable.subscribe({ (event: Event<String?>) in
            
            //イベントのステータスに応じて処理が変わる
            switch event {
                case .completed: print("completed")
                case .error(_):  print("error")
                case .next(let string): print(string ?? "") //テキストが変更されるたびに「.next」のイベントが実行される
            }
        })
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

