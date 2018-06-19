//
//  ViewController.swift
//  TodoAppApp
//
//  Created by 中山昌勲 on 2018/06/07.
//  Copyright © 2018年 Aki. All rights reserved.
//

import UIKit
import SwipeCellKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var uiTableView: UITableView!
    //Todo入れるテキストフィールド
    @IBOutlet weak var todoText: UITextField!
   
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
    var todoArray = [String]()
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
        
        //イメージがフェードイン
        image.alpha = 0.0
        UIView.animate(withDuration: 2.0, delay: 1.0, options: [.curveEaseIn], animations: {
            self.image.alpha = 1.0
        }, completion: nil)
        //イメージがジャンプ
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseIn, .autoreverse, .repeat], animations: {
            self.image.center.y += 100.0
        }) { _ in
            self.image.center.y -= 100.0
        }
        //imageを下に移動
        let transScale = CGAffineTransform(translationX: 0, y: 400)
        image.transform = transScale
        
        //notificationの登録
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.update),
                           name: Notification.Name.UIApplicationWillTerminate,
                           object: nil)
        
        
        
        //UDに保存されている値を取得。オプショナルバインディングで書き換えてみた。
        if let str = UserDefaults.standard.object(forKey: userDefaultsKey) {
            todoArray = str as! [String]    //Any型なのでString型にダウンキャスト
        }
    }
    
    //checkBoxタップ時の動作
    @IBAction func checkBox(_ sender: CheckBox) {
        print(sender.isChecked)
    }
    
    //OKボタンをタップした時のメソッド
    @IBAction func okTButtonTaped(_ sender: Any) {
        //入力内容を配列の先頭に入れる→新しいリストが先頭のセルに出る
        todoArray.insert(todoText.text!, at: 0)
        //追加ボタンを押したらフィールドを空にする
        todoText.text = ""
        //変数の中身をUDに追加
        userDefaults.set( todoArray, forKey: userDefaultsKey )
        //UDの値を明示的に同期
        userDefaults.synchronize()
        //tableを再生成して、表示を更新
        self.uiTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.fade)
        //キーボード閉じる
        view.endEditing(true)
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
        
        todoCell.delegate = self
        todoCell.selectedBackgroundView = createSelectedBackgroundView()
        
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
    
    //???_ textFieldにしなかったらenterでキーボードが下がらない＝メソッドが呼び出されなかった。なぜ？
    //Returnキー押下時の呼び出しメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる。
        view.endEditing(true)
        return false
    }
    
//    //左スワイプによる削除機能
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
//            //todoArrayから削除
//            self.todoArray.remove(at: indexPath.row)
//            //userDefaultsの更新
//            self.userDefaults.set(self.todoArray, forKey: self.userDefaultsKey)
//            //見た目上のセルからも削除
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//        deleteButton.backgroundColor = UIColor.red
//        //UserDefaults.standard.removeObject(forKey: "TodoList")
//        return [deleteButton]
//
//    }
    
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
            
            let read = SwipeAction(style: .default, title: nil) { action, indexPath in
            }
            
            read.hidesWhenSelected = false
            return [read]
        }
            //左スワイプ
        else {
            let flag = SwipeAction(style: .default, title: nil, handler: nil)
            flag.hidesWhenSelected = true
            configure(action: flag, with: .flag)
            
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in (
                //todoArrayから削除
                self.todoArray.remove(at: indexPath.row),
                //userDefaultsの更新
                self.userDefaults.set(self.todoArray, forKey: self.userDefaultsKey)
                )
            }
            configure(action: delete, with: .trash)
            
            let cell = tableView.cellForRow(at: indexPath) as! TodoTableViewCell
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
        
        //イメージの最大幅を設定
        
        
        
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 3
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
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
















