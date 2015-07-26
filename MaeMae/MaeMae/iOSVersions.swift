//
//  iOSVersions.swift
//  MaeMae
//
//  Created by David Fierstein on 6/10/15.
//  credit to AndrewCBancroft.com for providing this snippet to detect iOS version with Swift
//  Copyright (c) 2015 davidiad. All rights reserved.
//

import Foundation

let iOS7 = floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_7_1)
let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)