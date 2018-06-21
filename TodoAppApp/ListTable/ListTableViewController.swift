//
//  ListTableViewController.swift
//  TodoAppApp
//
//  Created by 中山昌勲 on 2018/06/16.
//  Copyright © 2018年 Aki. All rights reserved.
//

import UIKit
import SwipeCellKit

class ListTableViewController: UITableViewController {
    
    //動的な並び替えのため
    fileprivate var sourceIndexPath: IndexPath?     //save index path of tableview cell, where gesture begins
    fileprivate var snapshot: UIView?   //to save snapshot of the cell user is moving.
    
    //list
   fileprivate var todoList = [String]()
    
    // ToDoを格納した配列
   fileprivate var listName = [MyList]()
    let userDefaults = UserDefaults.standard
    
    var editButton :UIBarButtonItem?
    @IBOutlet weak var listTableView: UITableView!

    //letで宣言のみすることができなかったので冗長になっている。将来的に修正予定
    var longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ListTableViewController.longPressHandler(_:)))
    
    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //// 保存しているToDoの読み込み処理
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "list") as? Data {
            if let unarchiveTodlList = NSKeyedUnarchiver.unarchiveObject(with: storedTodoList) as? [MyList] {
                listName.append(contentsOf: unarchiveTodlList)
            }
        }
        
        //長押しジェスチャーの追加
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ListTableViewController.longPressHandler(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.numberOfTapsRequired = 0
        longPressGesture.numberOfTouchesRequired = 1
        self.tableView.addGestureRecognizer(longPressGesture)
        
        // ナビゲーションアイテムの右側に編集ボタンを設置
        editButton = UIBarButtonItem(title: "編集", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ListTableViewController.selToEdit(_:)))
        self.navigationItem.rightBarButtonItem = editButton
        
    }
    
    //テーブル全体の編集の可否を指定する
    @objc func selToEdit(_ sender:Any){
        if self.tableView.isEditing{
            //編集可能なら編集不可にする
            editButton?.title = "編集"
            self.setEditing(false, animated: true)
        }else{
            //編集不可なら可能にする
            editButton?.title = "完了"
            self.setEditing(true, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //リストセルをタップしてTodoリストへ遷移する前の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ListTableViewCell{
            if let viewController = segue.destination as? ViewController{
                viewController.userDefaultsKey = cell.listNameTitle
            }
            //遷移先のbarBottunのテキストをリスト名に変更
            let backButtonItem = UIBarButtonItem(title: cell.listNameTitle, style: .plain, target: nil, action: nil)
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
                //textプロパティに値が存在するかチェック
                guard let inputText = textField.text else{
                    return
                }
                //入力された文字が1文字以上かチェック
                guard inputText.lengthOfBytes(using: String.Encoding.utf8) > 0 else{
                    return
                }
                
                // ToDoの配列に入力値を挿入。先頭に挿入する
                let myTodo = MyList()
                myTodo.listTitle = inputText
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
        alertController.addAction(okAction) // OKボタンを追加
    
        // CANCELボタンがタップされた時の処理
        let cancelButton = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelButton)  // CANCELボタンを追加
        
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
        return listName.count+1
    }

    // テーブルの行ごとのセルを返却する
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableViewCell
        
        //リスト名を入力するためのセル
        if indexPath.row == listName.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! InputTableViewCell
            return cell
        }
        
        let myTodo = listName[indexPath.row]
        // セルのラベルにToDoのタイトルをセット
        guard let listTitle = myTodo.listTitle else {
            return cell
        }
        
        //cell選択時の背景色を変更する
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(hex: "A8DBA8")
        cell.selectedBackgroundView =  selectedView
        
        cell.textLabel?.text = listTitle
        cell.listNameTitle = listTitle
        cell.textLabel?.font = UIFont(name: "System", size: 14) //Fontサイズを14に設定
        return cell
    }
    
//    // セルをタップした時の処理
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    }
    
    //長押しで編集モード
    @objc func longPressHandler(_ sender: UILongPressGestureRecognizer){
        let state = sender.state    //状態
        let location = sender.location(in: self.tableView)  //位置
        
        guard let indexPath = self.tableView.indexPathForRow(at: location) else {
            cleanup()
            return
        }
        
        switch state{
            case .began:
                sourceIndexPath = indexPath
                guard let cell = self.tableView.cellForRow(at: indexPath) else { return }   //cell作成
                
                // Take a snapshot of the selected row using helper method. See below method
                snapshot = self.customSnapshotFromView(inputView: cell)
                guard  let snapshot = self.snapshot else { return }
                
                var center = cell.center
                snapshot.center = center
                snapshot.alpha = 0.0
                self.tableView.addSubview(snapshot)
                
                UIView.animate(withDuration: 0.25, animations: {
                    center.y = location.y
                    snapshot.center = center
                    snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    snapshot.alpha = 0.98
                    cell.alpha = 0.0
                }, completion: { (finished) in
                    cell.isHidden = true
                })
            
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
                    if listName.count > indexPath.row && listName.count > sourceIndexPath.row{
                        //listName.countより大きいindexには何もない
                        swap(&listName[indexPath.row], &listName[sourceIndexPath.row])
                        self.tableView.moveRow(at: sourceIndexPath, to: indexPath)
                        self.sourceIndexPath = indexPath
                    }
                }
            
            default:
                guard let cell = self.tableView.cellForRow(at: indexPath) else {
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
        self.tableView.reloadData()
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
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        // テーブルの編集中はバックボタンを表示しない
        if editing{
            plusBarButtonItem.isEnabled = false
            plusBarButtonItem.tintColor = UIColor(white: 0, alpha: 0)
        } else {
            plusBarButtonItem.isEnabled = true
            plusBarButtonItem.tintColor = UIColor(white: 1, alpha: 1)
        }
        super.setEditing(editing, animated: animated)
    }
    
    //テーブルの編集形式を設定
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing  {
            return UITableViewCellEditingStyle.delete
        }
        else{
            return UITableViewCellEditingStyle.none
        }
    }
    
    // セルが編集可能であるかどうかを返却する
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルを削除した時の処理
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうか
        if editingStyle == UITableViewCellEditingStyle.delete {
           //削除処理
            userDefaults.removeObject(forKey: listName[indexPath.row].listTitle!)    //TodoをUDから削除
            listName.remove(at: indexPath.row)   // リストから削除
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)   // セルを削除
            
            // データ保存
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: listName) //Data型にシリアライズする
            userDefaults.set(data, forKey: "list")   // UserDefautlsに保存
            userDefaults.synchronize()
        }
    }
}

    // NSCodingプロトコルに準拠する必要がある
    class MyList: NSObject, NSCoding {
        var listTitle: String?  // ToDoのタイトル
        // ToDoを完了したかどうかを表すフラグ
        //var todoDone: Bool = false
        // コンストラクタ
        override init() {
        }
        
        // NSCodingプロトコルに宣言されているデシリアライズ処理。デコード処理とも呼ばれる
        required init?(coder aDecoder: NSCoder) {
            listTitle = aDecoder.decodeObject(forKey: "listTitle") as? String
            //todoDone = aDecoder.decodeBool(forKey: "todoDone")
        }
        
        // NSCodingプロトコルに宣言されているシリアライズ処理。エンコード処理とも呼ばれる
        func encode(with aCoder: NSCoder) {
            aCoder.encode(listTitle, forKey: "listTitle")
            //aCoder.encode(todoDone, forKey: "todoDone")
        }
}
