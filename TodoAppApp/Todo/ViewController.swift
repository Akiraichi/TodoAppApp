//
//  ViewController.swift
//  TodoAppApp
//
//  Created by 中山昌勲 on 2018/06/07.
//  Copyright © 2018年 Aki. All rights reserved.
//

import UIKit
import SwipeCellKit
import TapticEngine

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var uiTableView: UITableView!
    //Todo入れるテキストフィールド
    @IBOutlet weak var todoText: UITextField!
   
    //動的な並び替えのため
    fileprivate var sourceIndexPath: IndexPath?     //save index path of tableview cell, where gesture begins
    fileprivate var snapshot: UIView?   //to save snapshot of the cell user is moving.
    //letで宣言のみすることができなかったので冗長になっている。将来的に修正予定
    var longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressHandler(_:)))
    
    var defaultOptions = SwipeOptions() //右スワイプを許可する
    
    var isSwipeRightEnabled = true      //displayモードをimageモードにする
    var buttonDisplayMode: ButtonDisplayMode = .imageOnly
    var buttonStyle: ButtonStyle = .circular //imageButtonをcirculerにする
    var usesTallCells = false   //cellの高さを通常にする
    
    //penguin_imageを入れるイメージビュー
    @IBOutlet weak var image: UIImageView!
    
    //tap操作のため
    @IBOutlet var singleRecognizer: UITapGestureRecognizer!
    
    //空の辞書を作成
    fileprivate var todoArray = [String]()  //動的並べ替えのため
    let userDefaults = UserDefaults.standard
    //UDのキーを設定するための変数
    var userDefaultsKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiTableView.delegate=self
        self.uiTableView.dataSource=self
        todoText.delegate=self  //todoTextnoデリゲイトはself
        
        //スワイプのための設定
        uiTableView.allowsSelection = true
        uiTableView.allowsMultipleSelectionDuringEditing = true
        
        //長押しジェスチャーの追加
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ListTableViewController.longPressHandler(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.numberOfTapsRequired = 0
        longPressGesture.numberOfTouchesRequired = 1
        self.uiTableView.addGestureRecognizer(longPressGesture)
        
//        //イメージがフェードイン
//        image.alpha = 0.0
//        UIView.animate(withDuration: 2.0, delay: 1.0, options: [.curveEaseIn], animations: {
//            self.image.alpha = 1.0
//        }, completion: nil)
//        //イメージがジャンプ
//        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseIn, .autoreverse, .repeat], animations: {
//            self.image.center.y += 100.0
//        }) { _ in
//            self.image.center.y -= 100.0
//        }
//        //imageを下に移動
//        let transScale = CGAffineTransform(translationX: 0, y: 400)
//        image.transform = transScale
        
        //notificationの登録
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.update),
                           name: Notification.Name.UIApplicationWillTerminate,
                           object: nil)
        
        //UDに保存されている値を取得。オプショナルバインディングで書き換えてみた。
        if let str = userDefaults.object(forKey: userDefaultsKey) {
            todoArray = str as! [String]    //Any型なのでString型にダウンキャスト
        }
    }
    
    //長押しで編集モード
    @objc func longPressHandler(_ sender: UILongPressGestureRecognizer){
        let state = sender.state    //状態
        let location = sender.location(in: self.uiTableView)  //位置
        
        guard let indexPath = self.uiTableView.indexPathForRow(at: location) else {
            cleanup()
            return
        }
        
        switch state{
        case .began:
            sourceIndexPath = indexPath
            guard let cell = self.uiTableView.cellForRow(at: indexPath) else { return }   //cell作成
            
            // Take a snapshot of the selected row using helper method. See below method
            snapshot = self.customSnapshotFromView(inputView: cell)
            guard  let snapshot = self.snapshot else { return }
            
            var center = cell.center
            snapshot.center = center
            snapshot.alpha = 0.0
            self.uiTableView.addSubview(snapshot)
            
            //tapic prepare
            TapticEngine.impact.prepare(.medium)
            
            UIView.animate(withDuration: 0.25, animations: {
                center.y = location.y
                snapshot.center = center
                snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                snapshot.alpha = 0.98
                cell.alpha = 0.0
            }, completion: { (finished) in
                cell.isHidden = true
            })
            TapticEngine.impact.feedback(.medium)
            
        case .changed:
            guard  let snapshot = self.snapshot else {
                return
            }
            var center = snapshot.center
            center.y = location.y
            snapshot.center = center
            guard let sourceIndexPath = self.sourceIndexPath  else {
                return
            }
            
            if indexPath != sourceIndexPath {
                if todoArray.count > indexPath.row && todoArray.count > sourceIndexPath.row{
                    //listName.countより大きいindexには何もない
                    swap(&todoArray[indexPath.row], &todoArray[sourceIndexPath.row])
                    //
                    TapticEngine.impact.feedback(.heavy)
                    
                    self.uiTableView.moveRow(at: sourceIndexPath, to: indexPath)
                    self.sourceIndexPath = indexPath
                }
            }
            
        default:
            //並べ替えを保存
            userDefaults.set(todoArray, forKey: userDefaultsKey)
            userDefaults.synchronize()
            
            guard let cell = self.uiTableView.cellForRow(at: indexPath) else {
                return
            }
            guard  let snapshot = self.snapshot else {
                return
            }
            cell.isHidden = false
            cell.alpha = 0.0
            
            UIView.animate(withDuration: 0.25, animations: {
                snapshot.center = cell.center
                snapshot.transform = CGAffineTransform.identity
                snapshot.alpha = 0
                cell.alpha = 1
            }, completion: { (finished) in
                self.cleanup()
            })
        }
    }
    
    //cleanup
    private func cleanup() {
        self.sourceIndexPath = nil
        snapshot?.removeFromSuperview()
        self.snapshot = nil
        self.uiTableView.reloadData()
    }
    
    //helper
    private func customSnapshotFromView(inputView: UIView) -> UIView? {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        if let CurrentContext = UIGraphicsGetCurrentContext() {
            inputView.layer.render(in: CurrentContext)
        }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0
        snapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
        snapshot.layer.shadowRadius = 5
        snapshot.layer.shadowOpacity = 0.4
        return snapshot
    }
    
    //checkBoxタップ時の動作
    @IBAction func checkBox(_ sender: CheckBox) {
        print(sender.isChecked)
    }
    
    //OKボタンをタップした時のメソッド
    @IBAction func okTButtonTaped(_ sender: Any) {
        //textプロパティに値が存在するかチェック
        guard let inputText = todoText.text else{
            return
        }
        //入力された文字が1文字以上かチェック
        guard inputText.lengthOfBytes(using: String.Encoding.utf8) > 0 else{
            return
        }

        todoArray.insert(inputText, at: 0) //入力内容を配列の先頭に入れる
        todoText.text = ""  //追加ボタンを押したらフィールドを空にする
        //tableを再生成して、表示を更新
        self.uiTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.fade)
        
        //保存処理
        userDefaults.set( todoArray, forKey: userDefaultsKey )
        userDefaults.synchronize()
    }
    
    //通知処理。ただし書きかけ
    @objc func update(notification: NSNotification?){
        print("notification_ON")
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todoCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoTableViewCell
        //todoCell.checkBox.isChecked = false //セル再利用に備えて、リセットする
        
//        //cell選択時の背景色を変更する
//        let selectedView = UIView()
//        selectedView.backgroundColor = UIColor(hex: "757575")
//        todoCell.selectedBackgroundView =  selectedView
        
        todoCell.delegate = self
       // todoCell.selectedBackgroundView = createSelectedBackgroundView()
        
        //変数の中身を作る
        todoCell.todoTextCell?.text = todoArray[indexPath.row]

        //戻り値の設定（表示する中身)
        return todoCell
    }
    
    //singleタップ時のアクション
    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
        //キーボードを閉じる。
        view.endEditing(true)
    }
    
    //Returnキー押下時の呼び出しメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる。ただし、入力文字があった場合はキーボードを下げない
        if let text = textField.text{
            if text.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                okTButtonTaped(textField)
                return false
            }
        }
        okTButtonTaped(textField)
        view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ////////////////////////////////////
    // MARK: - Helpers
    //viewのバックグラウンドカラーを変更
    func createSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }
}

extension ViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        //右スワイプ
        if orientation == .left {
            guard isSwipeRightEnabled else { return nil }
            
            let flag = SwipeAction(style: .default, title: nil, handler: nil)
            flag.hidesWhenSelected = true
            configure(action: flag, with: .flag)
            
            return [flag]
        }
            //左スワイプ
        else {
            let cell = self.uiTableView.cellForRow(at: indexPath) as! TodoTableViewCell
            
            let flag = SwipeAction(style: .default, title: nil, handler: nil)
            flag.hidesWhenSelected = true
            configure(action: flag, with: .flag)
            
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in (
                //todoArrayから削除
                self.todoArray.remove(at: indexPath.row),
                cell.checkBox.isChecked = false,
                cell.todoTextCell.textColor = UIColor.black,
                
                //userDefaultsの更新
                self.userDefaults.set(self.todoArray, forKey: self.userDefaultsKey),
                self.userDefaults.synchronize()
                )
            }
            configure(action: delete, with: .trash)
            
           // let cell = tableView.cellForRow(at: indexPath) as! TodoTableViewCell
            let closure: (UIAlertAction) -> Void = { _ in cell.hideSwipe(animated: true) }
            let more = SwipeAction(style: .default, title: nil) { action, indexPath in
                let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                
                controller.addAction(UIAlertAction(title: "Reply", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Forward", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Mark...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Notify Me...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Move Message...", style: .default, handler: closure))
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: closure))
                self.present(controller, animated: true, completion: nil)
            }
            configure(action: more, with: .more)
            
            return [delete, flag, more]
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        options.backgroundColor = UIColor(hex: "FAF3EB")
        //イメージの最大幅を設定
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 3
            options.backgroundColor = UIColor(hex: "EFEFEF")
        }
        
        return options
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
}
