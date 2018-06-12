//
//  ViewController.swift
//  TodoAppApp
//
//  Created by 中山昌勲 on 2018/06/07.
//  Copyright © 2018年 Aki. All rights reserved.
//

import UIKit



class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var uiTableView: UITableView!
    @IBOutlet weak var todoText: UITextField!
   
    //penguin_image
    @IBOutlet weak var image: UIImageView!
    
    //tap操作のため
    @IBOutlet var singleRecognizer: UITapGestureRecognizer!
    
    //空の辞書を作成
    var todoArray = [String]()
    //UserDefaultsの参照。インスタンスの作成
    let userDefaults = UserDefaults.standard
    
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
        userDefaults.set( todoArray, forKey: "TodoList" )
        //UDの値を明示的に同期
        userDefaults.synchronize()
        //tableを再生成して、表示を更新
        self.uiTableView.reloadData()
    }
    
    //通知処理。ただし書きかけ
    @objc func update(notification: NSNotification?){
        print("notification_ON")
    }
    
    //viewDidLoad
    override func viewDidLoad() {
        
        //オーバーライド前の本来の処理を実行
        super.viewDidLoad()
        
        self.uiTableView.delegate=self
        self.uiTableView.dataSource=self
        
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
        
        //cellの高さを自動調整
        uiTableView.rowHeight = UITableViewAutomaticDimension
        
        //todoTextnoデリゲイトはself
        todoText.delegate=self
       // self.uiTableView.transform = __CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        
        //UDに保存されている値を取得。オプショナルバインディングで書き換えてみた。
        if let str = UserDefaults.standard.object(forKey: "TodoList") {
            todoArray = str as! [String]    //Any型なのでString型にダウンキャスト
        }
    }
    
    // MARK: - Table view data source
    //セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //セル数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return todoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todoCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoTableViewCell
        //変数の中身を作る
        todoCell.todoTextCell?.text = todoArray[indexPath.row]
        
        //todoCell.transform = __CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        
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
    
    //左スワイプによる削除機能
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            //todoArrayから削除
            self.todoArray.remove(at: indexPath.row)
            //userDefaultsの更新
            self.userDefaults.set(self.todoArray, forKey: "TodoList")
            //見た目上のセルからも削除
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteButton.backgroundColor = UIColor.red
        //UserDefaults.standard.removeObject(forKey: "TodoList")
        return [deleteButton]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


