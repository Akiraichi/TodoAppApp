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
    
    ///////////////
    var defaultOptions = SwipeOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    var usesTallCells = false
    /////////////////////////////////
    
    // ToDoを格納した配列
    var listName = [MyList]()
    let userDefaults = UserDefaults.standard
    
    var editButton :UIBarButtonItem?
    @IBOutlet weak var listTableView: UITableView!

    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /////////////////////
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        //////////////////////////
        //// 保存しているToDoの読み込み処理
        let userDefaults = UserDefaults.standard
        if let storedTodoList = userDefaults.object(forKey: "list") as? Data {
            if let unarchiveTodlList = NSKeyedUnarchiver.unarchiveObject(with: storedTodoList) as? [MyList] {
                listName.append(contentsOf: unarchiveTodlList)
            }
        }
   
        //長押しジェスチャーの追加
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ListTableViewController.longPressHandler(_:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.numberOfTapsRequired = 0
        longPressGesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(longPressGesture)
            
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
        }
        else{
            //編集不可なら可能にする
            editButton?.title = "完了"
            self.setEditing(true, animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableViewCell
        cell.delegate = self as? SwipeTableViewCellDelegate
        cell.selectedBackgroundView = createSelectedBackgroundView()
        
        // 行番号に合ったToDoの情報を取得
        let myTodo = listName[indexPath.row]
        // セルのラベルにToDoのタイトルをセット
        cell.textLabel?.text = myTodo.listTitle
        cell.titleName = myTodo.listTitle!
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
    
    //セルの移動を許可
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool{
       //セルは移動可能
        return true
    }
    
    // テーブルのセルを移動
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath)
    {
        print("\(fromIndexPath.row)番地から\(to.row)番地に移動しました")
    }
    
//    //長押しで並べ替え
    @objc func longPressHandler(_ sender: UILongPressGestureRecognizer){
        
        switch sender.state {
        case UIGestureRecognizerState.began:
            self.setEditing(true, animated: true)
            editButton?.title = "完了"

        case UIGestureRecognizerState.ended:
            break
        default:
            break
        }
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
        }else{
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
    ////////////////////////////////////
    // MARK: - Helpers
    //viewのバックグラウンドカラーを変更
    func createSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
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

extension ListTableViewController: SwipeTableViewCellDelegate {
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
            
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                
            }
            configure(action: delete, with: .trash)
            
            let cell = tableView.cellForRow(at: indexPath) as! ListTableViewCell
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
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
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















