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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



/*
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
 }
 */

/*
 // Override to support editing the table view.
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 if editingStyle == .delete {
 // Delete the row from the data source
 tableView.deleteRows(at: [indexPath], with: .fade)
 } else if editingStyle == .insert {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the item to be re-orderable.
 return true
 }
 */

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */

