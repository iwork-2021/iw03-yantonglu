//
//  AboutTableViewController.swift
//  ITSC
//
//  Created by yantonglu on 2021/11/6.
//

import UIKit
import SwiftSoup

class AboutTableViewController: UITableViewController {
    let titles = ["服务电话","服务时间","校园卡电话","服务时间","服务邮箱","招聘邮箱","仙林信息化中心楼","鼓楼综合服务大厅"]
    var details = ["","","","","","","",""]
    var pageText = ""
    var isError = false
    
    func loadPageData(){
        let semaphore = DispatchSemaphore(value: 0) //使用信号量进行同步
        let aboutUrl = URL(string:"https://itsc.nju.edu.cn/main.htm")
        let request = URLRequest(url: aboutUrl!)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request,
                                        completionHandler: {(data, response, error) -> Void in
            if error != nil{
                print(error.debugDescription)
                self.isError = true
            } else {
                self.pageText = String(data: data!, encoding: String.Encoding.utf8)!
                //print(str)
                do {
                    let doc: Document = try SwiftSoup.parse(self.pageText)
                    //print(try doc.text())
                    let splitArray = try doc.text().components(separatedBy: " ")
                    
                    var findIndex:Int = 0
                    for i in 0..<self.titles.count{
                        if self.titles[i] != "服务时间"{
                            findIndex = splitArray.firstIndex(where: { (str) -> Bool in
                                return (str == self.titles[i])
                            })!
                            self.details[i] = splitArray[findIndex + 1]
                        } else{
                            self.details[i] = splitArray[findIndex + 2]
                            self.details[i] = String(self.details[i].dropFirst(5))
                        }
                        if self.details[i].hasPrefix("前台工作时间"){
                            self.details[i] = String(self.details[i].dropFirst(7))
                        }
                    }
                    
                    print("About Page Loaded")
                    DispatchQueue.main.async {
                        self.tableView.reloadData() // 在主线程中刷新UI
                    }
                    self.isError = false
                } catch {
                    print("error")
                }
            }
            semaphore.signal()
        }) as URLSessionTask
        dataTask.resume()
        //使用resume方法启动任务
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    func errorHandle(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "错误", message: "连接失败，请检查您的网络", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        self.loadPageData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.loadPageData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isError{
            errorHandle()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 4
        } else{
            return 2
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aboutCell", for: indexPath) as! ListTableViewCell
        
        // Configure the cell...
        
        if indexPath.section == 0{
            cell.title.text! = titles[indexPath.row]
            cell.detail.text! = details[indexPath.row]

            if cell.title.text == "服务时间"{
                cell.title.textColor = UIColor.darkGray
            } else {
                cell.title.textColor = UIColor.black
            }
        } else{
            cell.title.text! = titles[2 + indexPath.section * 2 + indexPath.row]
            cell.detail.text! = details[2 + indexPath.section * 2 + indexPath.row]
            
            cell.title.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = ["电话", "邮箱", "工作时间"]
        return titles[section]
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
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
