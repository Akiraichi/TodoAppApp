//
//  ViewController.swift
//  TodoAppApp
//
//  Created by 中山昌勲 on 2018/06/07.
//  Copyright © 2018年 Aki. All rights reserved.
//

import UIKit



class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var uiTableView: UITableView!
    @IBOutlet weak var todoText: UITextField!
    
    var todoArray = [String]()
    let saveData = UserDefaults.standard
    
    /*@IBAction func checkView(_ sender: CheckBox) {
     print(sender.isChecked)
     }*/
    
    @IBAction func checkBox(_ sender: CheckBox) {
        print(sender.isChecked)
    }
    //OKボタンをタップした時のメソッド
    @IBAction func okTButtonTaped(_ sender: Any) {
        //変数に入力内容を入れる
        todoArray.append(todoText.text!)
        //追加ボタンを押したらフィールドを空にする
        todoText.text = ""
        //変数の中身をUDに追加
        UserDefaults.standard.set( todoArray, forKey: "TodoList" )
        self.uiTableView.reloadData()
    }
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiTableView.delegate=self
        self.uiTableView.dataSource=self
       // self.uiTableView.transform = __CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        
        //UDに保存されている値を取得
        if UserDefaults.standard.object(forKey: "TodoList") != nil {
            todoArray = UserDefaults.standard.object(forKey: "TodoList") as! [String]
        }
        
      
        /*
         //カスタムセルを別途nidなので作成した時に必要
         tableView.register(UINib(nibName: "ListT", bundle: nil), forCellReuseIdentifier: "cell")
         */
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
    
    //左スワイプで削除機能
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
            //todoArrayから削除
            self.todoArray.remove(at: indexPath.row)
            //UserDefaultsの更新
            UserDefaults.standard.set(self.todoArray, forKey: "TodoList")
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


