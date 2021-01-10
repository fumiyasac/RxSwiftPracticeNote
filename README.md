# RxSwiftPracticeNote
[ING]RxSwiftの練習記録ノート（iOS Sample Study: Swift）

### 更新情報

+ 2021.01.10: Swift5.3 & Xcode12.3へのコンバートとRxSwift6.0への対応
+ 2019.07.03: Swift5.0 & Xcode12.0へのコンバート
+ 2018.12.29: Swift4.2 & Xcode10.1へのコンバートとDeprecatedになる箇所への対応
+ 2018.06.05: SwiftおよびXCodeのバージョンアップ

### 動作環境

+ XCode 12.3
+ CocoaPods 1.10.0
+ Swift 5.3

私自身苦手意識があったRxSwiftの実装を掴むために個人的な備忘録を兼ねて作成（というか写経）したサンプル集になります。
UIまわりの実装や機能作成に関わる部分を中心に今後も日本語でドキュメンテーションをしてサンプルケースを追加する予定です。

### 主な収録サンプル

+ 【Warming Up】テキストフィールドやボタンコレクションで挨拶文を作るプラクティス
+ 【Chapter1】ラーメンの一覧をRxDataSourcesを利用してUITableViewに一覧表示をするプラクティス
+ 【Chapter2】GithubのAPIを利用してuser名を検索してリポジトリ一覧をUITableViewに一覧表示をするプラクティス
+ 【Chapter3】FoursquareAPIを利用して検索した場所を表示するプラクティス

※ コメントの日本語に関しておかしな表現等がございましたらissueやpull requestを頂けますと幸いです。

### キャプチャ画像

![RxSwift練習記録ノート（前編）](https://qiita-image-store.s3.amazonaws.com/0/17400/daf8adf4-baf8-991b-d30a-c2644c392159.jpeg)
![RxSwift練習記録ノート（後編）](https://qiita-image-store.s3.amazonaws.com/0/17400/9c5e54df-b442-16d7-db39-751aa10666b4.jpeg)

### サンプルの解説

下記のQiita記事にて収録サンプルに関する解説でポイントとなる部分や実装に関する参考資料をまとめたものを掲載しております。

+ [RxSwiftでの実装練習の記録ノート（前編：Observerパターンの例とUITableViewの例）](http://qiita.com/fumiyasac@github/items/90d1ebaa0cd8c4558d96)
+ [RxSwiftでの実装練習の記録ノート（後編：DriverパターンとAPIへの通信を伴うMVVM構成のサンプル例）](http://qiita.com/fumiyasac@github/items/da762ea512484a8291a3)

※ 記事の中にも随時修正が必要な部分については追記をしています。
