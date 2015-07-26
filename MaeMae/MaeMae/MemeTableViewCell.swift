//
//  MemeTableViewCell.swift
//  MaeMae
//
//  Created by David Fierstein on 6/19/15.
//  Copyright (c) 2015 davidiad. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {
        
    var meme: Meme?
        
    @IBOutlet weak var memeCellImageView: UIImageView!
        
    @IBOutlet weak var topText: UILabel!
        
    @IBOutlet weak var bottomText: UILabel!
        
}
