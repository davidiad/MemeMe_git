//
//  MemeModel.swift
//  MaeMae
//
//  Created by David Fierstein on 7/6/15.
//  Copyright (c) 2015 davidiad. All rights reserved.
//

import Foundation
import UIKit

// Model of MVC design pattern

class MemeModel {
    
    func scaleFrame(image: UIImage, bounds: CGRect) -> CGRect {
        let widthRatio = bounds.size.width / image.size.width
        let heightRatio = bounds.size.height / image.size.height
        let scale = widthRatio < heightRatio ? widthRatio : heightRatio
        let resizedWidth = scale * image.size.width
        let resizedHeight = scale * image.size.height
        let verticalShift = (bounds.size.height - resizedHeight) / 2
        let horizontalShift = (bounds.size.width - resizedWidth) / 2
        // memeView is sized to hold the scaled image
        let frame =  CGRectMake(horizontalShift, verticalShift, resizedWidth, resizedHeight)
        return frame
    }
    
    func backgroundHue(indexValue: Int) -> CGFloat {
        var hueValue = (CGFloat(indexValue) * 0.083) + 0.08
        while hueValue > 1 {
            hueValue -= 0.87
        }
        return hueValue
    }
}
