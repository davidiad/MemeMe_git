//
//  MemeDetailViewController.swift
//  MaeMae
//
//  Created by David Fierstein on 6/2/15.
//  Copyright (c) 2015 davidiad. All rights reserved.

import UIKit

class MemeDetailViewController: UIViewController {
    
    //MARK: Vars
    
    var currentMeme: Meme?
    var currentMemeIndex: Int?
    var fontsize: CGFloat?
    
    //MARK: Outlets
    
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    //MARK: Actions
    
    @IBAction func hideBars(sender: AnyObject) {
        var targetAlpha: CGFloat = 0.0
        if bottomBar.alpha < 0.5 {
            targetAlpha = 0.8
        }
        UIView.animateWithDuration(0.3) {
            self.bottomBar.alpha = targetAlpha
            self.navigationController?.navigationBar.alpha = targetAlpha
        }
    }

    @IBAction func trashMeme(sender: UIBarButtonItem) {
        
        // Delete the meme from the memes array in the App Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        if currentMemeIndex != nil {
            appDelegate.memes.removeAtIndex(currentMemeIndex!)
        }
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func editMeme(sender: UIBarButtonItem) {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var memeEditor = storyboard.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditor
        memeEditor.currentMemeIndex = currentMemeIndex
        memeEditor.currentMeme = currentMeme
        memeEditor.currentFontSize = currentMeme?.fontsize
        presentViewController(memeEditor, animated: true, completion: nil)
    }
    
    //MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomBar.layer.opacity = 0.8
        navigationController?.navigationBar.alpha = 0.8
    }
    
    override func viewWillAppear(animated: Bool) {
        // after editing in the Meme Editor, and then returning, update the image.
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        if currentMemeIndex != nil {
            currentMeme! = appDelegate.memes[currentMemeIndex!]
            detailImage.image = currentMeme!.memedImage
            let hueValue = MemeModel().backgroundHue(currentMemeIndex!)
            // set bg color to same as sent memes color, but a bit lighter
            view.backgroundColor = UIColor(hue: hueValue, saturation: 0.25, brightness: 0.85, alpha: 1)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

