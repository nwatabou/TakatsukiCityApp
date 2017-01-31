//
//  CommentViewController.swift
//  TakatsukiEventApp
//
//  Created by 仲西 渉 on 2016/11/24.
//  Copyright © 2016年 nwatabou. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {
    
    var selectEventTitle:String!
    var eventData:[[String]]!
    var facilityData:[[String]]!
    
    @IBOutlet weak var titleBarText: UINavigationItem!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var addinfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ..< eventData.count {
            if(eventData[i][1] == selectEventTitle) {
                titleBarText.title = eventData[i][1]
                commentLabel.text = ("\(eventData[i][7])")
                dateLabel.text = ("日時 \n\(eventData[i][3]) \n \(eventData[i][4]) ~ \(eventData[i][5])")
                locationLabel.text = ("場所 : \(eventData[i][2])")
                if(eventData[i][6] == "0") {
                    costLabel.text = "無料"
                }else{
                    costLabel.text = ("参加費 : \(eventData[i][6])円")
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
