//
//  InputTableViewCell.swift
//  TodoAppApp
//
//  Created by 中山昌勲 on 2018/06/21.
//  Copyright © 2018年 Aki. All rights reserved.
//

import UIKit

class InputTableViewCell: UITableViewCell {

    @IBOutlet weak var listInputTextView:UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
