//
//  ContentViewController.swift
//  ITSC
//
//  Created by yantonglu on 2021/11/14.
//

import UIKit
import SwiftSoup

class ContentViewController: UIViewController {
    @IBOutlet weak var contentTitle: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var mainText: UITextView!
    
    var tempMainText:NSMutableAttributedString = NSMutableAttributedString(string: "")
    
    var pageText = ""
    var isError = false
    var tempContentTitle = ""
    var tempTime = ""
    var tempUrl = ""
    
    func getText(node:Node)->String{
        // 递归找到图片
        do{
            if try node.attr("src") != "" && node.attr("width") != "" && node.attr("height") != "" {
                let url = try node.attr("src")
                let w = try node.attr("width")
                let h = try node.attr("height")
                if UIDevice.current.orientation.isLandscape {
                    self.addImage(url: "https://itsc.nju.edu.cn" + url, w: 600, h: 600 * Int(h)! / Int(w)!)
                } else {
                    self.addImage(url: "https://itsc.nju.edu.cn" + url, w: 300, h: 300 * Int(h)! / Int(w)!)
                }
                
                return ""
            } else if try node.attr("src") != "" {
                let url = try node.attr("src")
                if UIDevice.current.orientation.isLandscape {
                    self.addImage(url: "https://itsc.nju.edu.cn" + url, w: 600, h: 450)
                } else {
                    self.addImage(url: "https://itsc.nju.edu.cn" + url, w: 300, h: 225)
                }
                return ""
            }
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error1")
        }
        
        
        // 递归找到文本
        if node is TextNode{
            return (node as! TextNode).text()
        }
        if node.getChildNodes().count == 0{
            return ""
        }
        else {
            var ret = ""
            for child in node.getChildNodes(){
                ret.append(contentsOf: getText(node: child))
            }
            return ret
        }
    }
    
    func addImage(url:String, w:Int, h:Int){
        
        let attachment = NSTextAttachment()
        do {
            attachment.image = UIImage(data: try Data(contentsOf: URL(string: url)!))
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error2")
            print(url)
        }
        let attachmentImage = NSAttributedString(attachment: attachment)
        attachment.bounds = .init(x: 0, y: 0, width: w, height: h)
        self.tempMainText.append(attachmentImage)
        self.tempMainText.append(NSAttributedString(string: "\n\n"))
    }
    
    func loadPageData(){
        let semaphore = DispatchSemaphore(value: 0) //使用信号量进行同步
        let contentUrl = URL(string:tempUrl)
        let request = URLRequest(url: contentUrl!)
        
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
                    let findIndex = splitArray.firstIndex(where: { (str) -> Bool in
                        return (str.hasPrefix("发布时间"))
                    })!
                    self.tempTime = splitArray[findIndex]
                    self.tempTime.insert(contentsOf: "  ", at: (self.tempTime.range(of: "浏览次数")!.lowerBound))
                    
                    let node = doc.getChildNodes()[1].getChildNodes()[2].getChildNodes()[21].getChildNodes()[1].getChildNodes()[1].getChildNodes()[1].getChildNodes()[7].getChildNodes()[1].getChildNodes()[0]
                    
                    var i = 0
                    while i < node.getChildNodes().count{
                        let para = node.getChildNodes()[i]
                        //print("para " + String(i))
                        //print(para)
                        var paraText = self.getText(node: para)
                        paraText = paraText.trimmingCharacters(in: CharacterSet.whitespaces)
                        if(paraText != "") {
                            self.tempMainText.append(NSAttributedString(string: "\t" + paraText + "\n\n"))
                        }
                            
                        //print("    " + paraText)
                        
                        i = i + 1
                    }
                    
                    self.isError = false
                } catch Exception.Error(let type, let message) {
                    print(message)
                } catch {
                    print("error3")
                }
            }
            semaphore.signal()
        }) as URLSessionTask
        dataTask.resume()
        //使用resume方法启动任务
        
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        loadPageData()
        self.contentTitle.text = tempContentTitle
        self.time.text = tempTime
        self.mainText.attributedText = tempMainText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.isError{
            let alert = UIAlertController(title: "错误", message: "连接失败，请检查您的网络", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
