//
//  StudentInformationTableViewCell.swift
//  On the Map
//
//  Created by nekki t on 2015/12/29.
//  Copyright © 2015年 next3. All rights reserved.
//

import UIKit

class StudentInformationTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var mediaURLLabel: UILabel!
    @IBOutlet weak var countryFlag: UIImageView!
    
    var countryName : String? {
        didSet {
            dispatch_async(dispatch_get_main_queue(), {
                if let name = self.countryName {
                    // Just for the cases I've noticed from test data... Sorry, I can't cover all for the time sake...
                    if name == "united-states" {
                        self.countryFlag.image = UIImage(named: "america")
                    } else if name == "costa-rica" {
                        self.countryFlag.image = UIImage(named: "costarica")
                    } else if name == "south-africa" {
                        self.countryFlag.image = UIImage(named: "south_africa")
                    } else if name == "new-zealand" {
                        self.countryFlag.image = UIImage(named: "newzealand")
                    } else {
                        self.countryFlag.image = UIImage(named: name)
                    }
                    self.studentNameLabel.text = self.studentNameLabel.text! + "-" + name
                }
                else {
                    self.studentNameLabel.text = self.studentNameLabel.text
                    self.countryFlag.image = UIImage(named: "united-nations")
                }
            })
        }
    }
    
    
    var studentInformation = StudentInformation() {
        didSet {
            studentNameLabel.text = studentInformation.firstName! + " " + studentInformation.lastName!
            mediaURLLabel.text = studentInformation.mediaURL!
        }
    }
}
