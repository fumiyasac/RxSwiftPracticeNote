//
//  VenueCell.swift
//  RxSwiftPracticeNote
//
//  Created by 酒井文也 on 2017/01/15.
//  Copyright © 2017年 just1factory. All rights reserved.
//

import UIKit

class VenueCell: UITableViewCell {

    //UIパーツの配置
    @IBOutlet weak var venueName: UILabel!
    @IBOutlet weak var venueAddress: UILabel!
    @IBOutlet weak var venueState: UILabel!
    @IBOutlet weak var venueCity: UILabel!
    @IBOutlet weak var venueIconImage: UIImageView!
    @IBOutlet weak var venueDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
