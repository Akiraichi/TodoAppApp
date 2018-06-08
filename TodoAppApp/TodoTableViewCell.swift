//
//  TodoTableViewCell.swift
//  TodoAppApp
//
//  Created by 中山昌勲 on 2018/06/07.
//  Copyright © 2018年 Aki. All rights reserved.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var todoTextCell: UITextField!
    @IBOutlet weak var checkBox: CheckBox!
    var strikeOn:Bool = false
    
    @IBAction func checkBoxAct(_ sender: Any) {
        if !strikeOn{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: todoTextCell.text!)
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            self.todoTextCell.attributedText=attributeString
            //取り消し線を加える
            strikeOn=true
        }else{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: todoTextCell.text!)
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
            self.todoTextCell.attributedText=attributeString
            
            //取り消し線を消す
            strikeOn=false
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
