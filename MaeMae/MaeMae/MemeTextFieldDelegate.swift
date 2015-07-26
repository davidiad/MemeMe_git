//
//  MemeTextFieldDelegate.swift
//  MaeMae
//
//  Created by David Fierstein on 6/10/15.
//  Copyright (c) 2015 davidiad. All rights reserved.
//

import Foundation
import UIKit

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    let defaultText = "MEME TEXT GOES HERE"

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var result = true
        // credit to globalnerdy.com/2015/01/03/how-to-program-an-ios-text-field-that-takes-only-numeric-input-with-a-maximum-length
        // for tutorial how to limit allowed text
        let textToCheck = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if count(string) > 0 {
            let entryNotTooLong = count(textToCheck) < 50
            result = entryNotTooLong
        }
        textField.text = textField.text.uppercaseString
        return result
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.clearButtonMode = .Always
        textField.textAlignment = NSTextAlignment.Center
        textField.placeholder = defaultText
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 18
        textField.autocapitalizationType = .AllCharacters
        textField.autocorrectionType = .No
        
        // While editing, set a background color for the meme text, so the user has a cue that they are editing text
        let bgcolor = UIColor(hue: 0.12, saturation: 0.2, brightness: 0.9, alpha: 0.7)
        textField.backgroundColor = bgcolor
        textField.layer.cornerRadius = 8.0;
        // Only remove default text, not user entered text
        if textField.text == defaultText {
            textField.text = ""
        }
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Get rid of the bg color when done editing
        textField.backgroundColor = UIColor.clearColor()
        textField.clearButtonMode = .Never
        textField.text = textField.text.uppercaseString
    }
    
    // When the clear button is tapped...
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
