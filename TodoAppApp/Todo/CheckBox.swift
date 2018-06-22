import UIKit


class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "ico_check_on")! as UIImage
    let uncheckedImage = UIImage(named: "ico_check_off")! as UIImage
    
    // isCheckの値によってsetするイメージを変更
    //プロパティの変更前/後で処理を実行
    public var isChecked = false{
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControlState.normal)
                
            } else {
                self.setImage(uncheckedImage, for: UIControlState.normal)
            }
        }
    }
    //nibファイルに登録されたのオブジェクト間のインスタンス変数(IBOutlet)の自動接続が終了するタイミングで実行
    override func awakeFromNib() {
        //touch up insideでbuttonClickdが呼び出されれる
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        //ボタンの初期値はfalse
        self.isChecked = false
    }
    
    //ボタンがクリックされたらcheck状態を逆にする
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}


