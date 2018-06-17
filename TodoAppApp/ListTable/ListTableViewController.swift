//
//  ListTableViewController.swift
//  TodoAppApp
//
//  Created by 中山昌勲 on 2018/06/16.
//  Copyright © 2018年 Aki. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // ToDoを格納した配列
    var listName = [MyList]()
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var listTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //// 保存しているToDoの読み込み処理
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "list") as? Data {
            if let unarchiveTodlList = NSKeyedUnarchiver.unarchiveObject(with: storedTodoList) as? [MyList] {
                listName.append(contentsOf: unarchiveTodlList)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //リストセルをタップしてTodoリストへ遷移する前の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ListTableViewCell{
            if let viewController = segue.destination as? ViewController{
                viewController.userDefaultsKey = cell.listName
            }
            //遷移先のbarBottunのテキストをリスト名に変更
            let backButtonItem = UIBarButtonItem(title: cell.listName, style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem = backButtonItem
        }
        
    }
    
    // +ボタンをタップしたときに呼ばれる処理
    @IBAction func tapAddButton(_ sender: Any) {
        // アラートダイアログを生成
        let alertController = UIAlertController(title: "リスト追加", message: "リスト名を入力してください", preferredStyle: UIAlertControllerStyle.alert)
        // テキストエリアを追加
        alertController.addTextField(configurationHandler: nil)
        
        // OKボタンがタップされた時の処理
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            // OKボタンがタップされた時の処理
            if let textField = alertController.textFields?.first {
                // ToDoの配列に入力値を挿入。先頭に挿入する
                let myTodo = MyList()
                myTodo.listTitle = textField.text!
                self.listName.insert(myTodo, at: 0)
                
                // テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableViewRowAnimation.right)
                
                // ToDoの保存処理
                let userDefaults = UserDefaults.standard
                // Data型にシリアライズする
                let data = NSKeyedArchiver.archivedData(withRootObject: self.listName)
                userDefaults.set(data, forKey: "list")
                userDefaults.synchronize()
            }
        }
        
        // OKボタンを追加
        alertController.addAction(okAction)
        
        // CANCELボタンがタップされた時の処理
        let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        // CANCELボタンを追加
        alertController.addAction(cancelButton)
        
        // アラートダイアログを表示
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listName.count
    }

    // テーブルの行ごとのセルを返却する
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListTableViewCell else{
            return ListTableViewCell()
        }

        // 行番号に合ったToDoの情報を取得
        let myTodo = listName[indexPath.row]
        // セルのラベルにToDoのタイトルをセット
        cell.textLabel?.text = myTodo.listTitle
        cell.listName = myTodo.listTitle!
//        // セルのチェックマーク状態をセット
//        if myTodo.todoDone {
//            // チェックあり
//            cell.accessoryType = UITableViewCellAccessoryType.checkmark
//        } else {
//            // チェックなし
//            cell.accessoryType = UITableViewCellAccessoryType.none
//        }
        return cell
    }
    
    // セルをタップした時の処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myTodo = listName[indexPath.row]
//        if myTodo.todoDone {
//            // 完了済みの場合は未完了に変更
//            myTodo.todoDone = false
//        } else {
//            // 未完の場合は完了済みに変更
//            myTodo.todoDone = true
//        }
       
        // セルの状態を変更
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        // データ保存。Data型にシリアライズする
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: listName)
        // UserDefautlsに保存
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "list")
        userDefaults.synchronize()
    }
    
    // セルが編集可能であるかどうかを返却する
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルを削除した時の処理
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうか
        if editingStyle == UITableViewCellEditingStyle.delete {
            // ToDoリストから削除
            listName.remove(at: indexPath.row)
            // セルを削除
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            // データ保存。Data型にシリアライズする
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: listName)
            // UserDefautlsに保存
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "list")
            userDefaults.synchronize()
            
            //UserDefaultsからリストを削除
            
        }
    }
}
    // NSCodingプロトコルに準拠する必要がある
    class MyList: NSObject, NSCoding {
        // ToDoのタイトル
        var listTitle: String?
//        // ToDoを完了したかどうかを表すフラグ
//        var todoDone: Bool = false
        // コンストラクタ
        override init() {
            
        }
        
        // NSCodingプロトコルに宣言されているデシリアライズ処理。デコード処理とも呼ばれる
        required init?(coder aDecoder: NSCoder) {
            listTitle = aDecoder.decodeObject(forKey: "listTitle") as? String
//            todoDone = aDecoder.decodeBool(forKey: "todoDone")
        }
        
        // NSCodingプロトコルに宣言されているシリアライズ処理。エンコード処理とも呼ばれる
        func encode(with aCoder: NSCoder) {
            aCoder.encode(listTitle, forKey: "listTitle")
//            aCoder.encode(todoDone, forKey: "todoDone")
        }
}
