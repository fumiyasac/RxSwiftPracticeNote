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

class ViewController: UIViewController {

    //UIパーツの配置
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var greetingTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!

    //Outlet Collectionで紐づける
    //(参考)アウトレットコレクションを使う
    //http://develop.calmscape.net/dev/220/
    @IBOutlet var greetingButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

