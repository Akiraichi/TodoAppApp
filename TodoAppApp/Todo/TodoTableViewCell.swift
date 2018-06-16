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
            
            //textcolorを変更する
            todoTextCell.textColor=UIColor(hex: "ccd1d2")
            //取り消し線を加える
            strikeOn=true
        }else{
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: todoTextCell.text!)
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
            self.todoTextCell.attributedText=attributeString
           
            //textColorを戻す
            todoTextCell.textColor=UIColor(hex: "000000")
            //取り消し線を消す
            strikeOn=false
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        //元々入っているセルの情報をリセット
        todoTextCell=nil
        strikeOn=false
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

//色を変更しやすくする
extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = hex.map { String($0) } + Array(repeating: "0", count: max(6 - hex.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0) / 255.0
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0) / 255.0
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}
