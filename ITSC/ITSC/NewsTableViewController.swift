//
//  NewsTableViewController.swift
//  ITSC
//
//  Created by yantonglu on 2021/11/13.
//

import UIKit
import SwiftSoup

class NewsTableViewController: UITableViewController {
    
    var pageText = ""
    var pageCount = 0
    var isError = false
    var titles:[String] = []
    var dates:[String] = []
    var urls:[String] = []
    
    func loadPageData(page:Int, title:String){
        
        let semaphore = DispatchSemaphore(value: 0) //使用信号量进行同步
        
        let listUrl = URL(string:"https://itsc.nju.edu.cn/" + title + "/list" + String(page) + ".htm")
        let request = URLRequest(url: listUrl!)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request,
                                        completionHandler: {(data, response, error) -> Void in
            if error != nil{
                print(error.debugDescription)
                self.isError = true
            } else {
                self.pageText = String(data: data!, encoding: String.Encoding.utf8)!
                
                if self.pageCount == 0{
                    let r = self.pageText.range(of: "<em class=\"all_pages\">")
                    
                    let startIndex = self.pageText.index(r!.upperBound, offsetBy: 0)
                    let endIndex = self.pageText.index(r!.upperBound, offsetBy: 1)
                    
                    var pageStr = self.pageText[startIndex...endIndex]
                    if pageStr.hasSuffix("<") {
                        pageStr = pageStr.dropLast()
                    }
                    
                    self.pageCount = Int(pageStr)!
                }
                
                do {
                    let doc: Document = try SwiftSoup.parse(self.pageText)
                    //print(try doc.text())
                    
                    let  node = doc.getChildNodes()[1].getChildNodes()[2].getChildNodes()[21].getChildNodes()[1].getChildNodes()[1].getChildNodes()[3].getChildNodes()[1].getChildNodes()[3].getChildNodes()[1].getChildNodes()[1].getChildNodes()[1].getChildNodes()[1]
                    
                    var i = 1
                    while i < node.getChildNodes().count{
                        self.titles.append((try node.getChildNodes()[i].getChildNodes()[1].getChildNodes()[0].getChildNodes()[0] as! TextNode).text())
                        
                        self.dates.append((try node.getChildNodes()[i].getChildNodes()[3].getChildNodes()[0] as! TextNode).text())
                        
                        self.urls.append("https://itsc.nju.edu.cn" + (try node.getChildNodes()[i].getChildNodes()[1].getChildNodes()[0].attr("href")))
                        i = i + 2
                    }
                    
                    print("News Table " + title + " Page " + String(page) + " of " + String(self.pageCount) + " Loaded")
                    DispatchQueue.main.async {
                        self.tableView.reloadData() // 在主线程中刷新UI
                    }
                    self.isError = false
                } catch Exception.Error(let type, let message) {
                    print(message)
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
    
    func prepareData(){
        let title = self.title
        self.loadPageData(page: 1, title: title!)
        var i = 2
        
        let queue = DispatchQueue(label: "myqueue")
        queue.async {
            while i <= self.pageCount{
                self.loadPageData(page: i, title: title!)
                i = i + 1
            }
        }
    }
    
    func errorHandle(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "错误", message: "连接失败，请检查您的网络", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        self.prepareData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.prepareData()
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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titles.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! ListTableViewCell
        
        // Configure the cell...
        
        cell.title.text! = self.titles[indexPath.row]
        cell.detail.text! = self.dates[indexPath.row]
        cell.url = self.urls[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var des = segue.destination as! ContentViewController
        des.tempContentTitle = (sender as! ListTableViewCell).title.text!
        des.tempUrl = (sender as! ListTableViewCell).url
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
