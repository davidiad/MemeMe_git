//
//  Meme.swift
//  MaeMae
//
//  Created by David Fierstein on 5/27/15.
//  Copyright (c) 2015 davidiad. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var originalImage: UIImage?
    var memedImage: UIImage?
    var thumbnail: UIImage?
    var bg: UIImage? // background image for table cells (not in use)
    var topText: String = "MEME TEXT GOES HERE"
    var bottomText: String = "MEME TEXT GOES HERE"
    var fontsize: CGFloat = 24.0
    var cellSize: CGSize = CGSizeMake(100, 100)
}
