//
//  MemeEditor.swift
//  MaeMae
//
//  Created by David Fierstein on 5/22/15.
//  Copyright (c) 2015 davidiad. All rights reserved.

import UIKit

class MemeEditor: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIGestureRecognizerDelegate {
    
    //MARK:- Constants
    // detect the type of device. iPads need a popover, not modal view
    enum UIUserInterfaceIdiom: Int {
        case Unspecified
        case Phone
        case Pad
    }
    
    let model: MemeModel = MemeModel()
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    let thumbnailWidth : CGFloat = 100.0 // Size of Thumbnail image in Table of Saved Memes
    
    //MARK:- Vars
    var keyboardHeight: CGFloat?
    
    var currentMeme: Meme?
    var currentMemeIndex: Int? // will normally be nil, unless coming from editing the meme in the Detail View
    var currentFontSize: CGFloat? // to save the font size, if changed by user via font size slider
    
    var memeView: UIView?
    var imageView: UIImageView?
    var topTextfield: UITextField!
    var bottomTextfield: UITextField!
    
    var renderedImage: UIImage!
    var thumbnail: UIImage! // thumbnail to use in table view cells.
    var bg: UIImage! // background image to add texture to table view cells. Not currently in use.
    
    // set a bool to track when device is in Landscape mode and picking an image
    // because in that case, since the image picker is always in portrait mode, the view bounds will not match the landscape orientation when running updateMemeView(), and therefore near to be switched (width for height)
    var pickingImageInLandscape: Bool = false
    
    //MARK:- Outlets
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var slider: UISlider!
    
    //MARK:- Actions
    
    @IBAction func tapToHideBars(sender: AnyObject) {
        var targetAlpha: CGFloat = 0.0
        if bottomBar.alpha < 0.5 {
            targetAlpha = 0.8
        }
        UIView.animateWithDuration(0.3) {
            self.bottomBar.alpha = targetAlpha
            self.topBar.alpha = targetAlpha
        }
    }
    
    @IBAction func cancelMemeEditor(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCam(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        saveMeme()
        let shareViewController = UIActivityViewController(activityItems: [renderedImage], applicationActivities: nil)

        // modify code so it will work on my iPhone 5s running iOS 7 (work in iOS 7 to a point, but not completely)
        if iOS7 {
            // set the completion handler for iOS 7 (deprecated in favor of completionWithItemsHandler in iOS 8)
            shareViewController.completionHandler = {(activity, completed) in
                if (completed) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    // In iOS7, is dismissing the activity controller before having a chance to choose an activity. But can still hit the cancel button to get to Saved Memes
                }
            }
        } else { // iOS8 or above
            
            // set the completion handler
            shareViewController.completionWithItemsHandler = {(activity, completed, items, error) in
                if (completed) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                // Display
                presentViewController(shareViewController, animated: true, completion: nil)

            } else { // not an iPhone or Ipod, must be an iPad...
                // Needs to be presented as Popover to work on iPad
                shareViewController.modalPresentationStyle = .Popover
                shareViewController.preferredContentSize = CGSizeMake(360.0, 700.0)
                let popoverMenuViewController = shareViewController.popoverPresentationController
                presentPopoverFromBarButtonItem(sender, permittedArrowDirections: .Any, animated: true)
                popoverMenuViewController?.permittedArrowDirections = .Any
                popoverMenuViewController?.sourceView = self.view
                popoverMenuViewController?.sourceRect = CGRect(origin: CGPoint(x: 30, y: 920 ), size: UIScreen.mainScreen().bounds.size)
                presentViewController (
                    shareViewController,
                    animated: true,
                    completion: nil)
            }
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        let fontsize = CGFloat(sender.value)
        updateFontSize(fontsize)
    }
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the Meme textfields
        topTextfield = createTextfield()
        bottomTextfield = createTextfield()
        
        view.bringSubviewToFront(bottomBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)

        subscribeToKeyboardNotifications()
        subscribeToRotationNotifications()

        // Set the currentMeme
        if currentMemeIndex == nil { // Create a new Meme object
            if currentMeme == nil {
                currentMeme = Meme()
            }
        } else {
            retrieveMeme(currentMemeIndex!)
        }
        
        topTextfield.text = currentMeme?.topText
        bottomTextfield.text = currentMeme?.bottomText
        
        shareButton.enabled = currentMeme?.originalImage != nil
        updateMemeView()
        updateFontSize(currentMeme!.fontsize)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeToKeyboardNotifications()
        unsubscribeToRotationNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Helper functions
    
    func createTextfield() -> UITextField {
        let textRect = CGRectMake(0, 0, view.bounds.width - 20, 58)
        let textfield = UITextField(frame: textRect)
        textfield.delegate = memeTextFieldDelegate
        textfield.setTranslatesAutoresizingMaskIntoConstraints(false)
        return textfield
    }
    
    func retrieveMeme(index: Int) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        currentMeme = appDelegate.memes[index]
    }
    
    func updateFontSize(fontsize: CGFloat) {
        let strokewidth = Double( -1.0 * (((0.25 - ((fontsize - 20)/450))) * fontsize)  )
        currentMeme?.fontsize = fontsize
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        let memeTextAttributes = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: fontsize)!,
            NSStrokeWidthAttributeName: NSNumber(double: strokewidth)]
        topTextfield.defaultTextAttributes = memeTextAttributes
        bottomTextfield.defaultTextAttributes = memeTextAttributes
        // set the slider value to match the current font size
        slider.value = Float(fontsize)
        //topTextfield.contentVerticalAlignment = .Top
    }
    
    func presentPopoverFromBarButtonItem(item: UIBarButtonItem,
        permittedArrowDirections arrowDirections: UIPopoverArrowDirection,
        animated: Bool) {
    }

    //MARK:- Image Picker functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            currentMeme?.originalImage = image
            currentMeme?.topText = topTextfield.text
            currentMeme?.bottomText = bottomTextfield.text
            renderThumbnail(image)
            // If updating an existing meme, then save the new image, and its thumbnail, so they aren't overwritten when the meme is retrieved during ViewWillAppear
            if currentMemeIndex != nil {
                saveMeme()
            }
            checkPickingInLandscape()
            shareButton.enabled = true
        }
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        checkPickingInLandscape()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Because the image picker and camera always stay in portrait mode, we need to check whether the image picker/camera is being used in landscape orientation. Then check for that in updateMemeView()
    func checkPickingInLandscape() {
        if UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight {
            pickingImageInLandscape = true
        }
    }
    
    // MARK:- Meme functions
    
    func saveMeme() {
        // Create the memed image
        renderMemedImage()
        
        // ensure that cellSize has at least a default value
        let defaultCellSize = CGSizeMake(100, 100)
        var meme = Meme(originalImage: currentMeme?.originalImage, memedImage: renderedImage!, thumbnail: currentMeme?.thumbnail, bg: bg, topText: topTextfield.text!, bottomText: bottomTextfield.text, fontsize: currentMeme!.fontsize, cellSize: defaultCellSize)
    
        // Get a reference to the App Delegate, where the memes array is stored
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        if currentMemeIndex != nil { // We are editing an existing meme
            appDelegate.memes[currentMemeIndex!] = meme
        } else { // We are creating a brand new meme
            appDelegate.memes.append(meme)
        }
    }
    
    func updateMemeView() {
        // Create, or recreate, the view of the meme, including:
        // memeView, imageView (inside meme view, holds the image), the textfields and their constaints
        
        // If an image does exist, calculate the ratios for image adjustment to fit the sceen
        if let img = currentMeme?.originalImage {
            removePreviousViews() // clean up the programmatically created views, before creating new ones
            
            // pass image and view bounds in to the Model, and get back a CGRect for the memeFrame
            var bounds: CGRect
            // Because image picker/camera is always in portrait mode, we need to switch the width/height values if we are updating the Meme view while in landscape orientation
            if pickingImageInLandscape {
                bounds = CGRectMake(0.0, 0.0, view.bounds.height, view.bounds.width)
            } else {
                bounds = view.bounds
            }
            let memeFrame = model.scaleFrame(img, bounds: bounds)
            memeView = UIView(frame: memeFrame)
            // Add an image view to hold the image, at the correct, scaled, size
            imageView = UIImageView(frame: CGRectMake(0, 0, memeFrame.width, memeFrame.height))
            view.addSubview(memeView!)
            memeView!.contentMode = .ScaleAspectFit
            imageView!.contentMode = .ScaleAspectFit
            imageView!.image = img
            memeView!.addSubview(imageView!)
            memeView!.sendSubviewToBack(imageView!)
            
        } else {
            // There is no image yet, so set the memeView to default values
            // Full width of screen, and the height somewhat less to account for toolbars
            memeView = UIView(frame: CGRectMake(0.0, 74.0, view.bounds.size.width, view.bounds.size.height - 148.0))
            view.addSubview(memeView!)
        }
        
        //Put the textfields inside memeView so they can be constrained to near the top & the bottom of the memeView
        memeView!.addSubview(topTextfield)
        memeView!.addSubview(bottomTextfield)
        topTextfield.superview!.removeConstraints(topTextfield.constraints())
        bottomTextfield.superview!.removeConstraints(bottomTextfield.constraints())
        // to ensure that the toolbars/textfields are on top of the view
        view.bringSubviewToFront(topBar)
        view.bringSubviewToFront(bottomBar)
        memeView!.bringSubviewToFront(topTextfield)
        memeView!.bringSubviewToFront(bottomTextfield)
        
        // Create and add the Textfield constraints
        let horizontalConstraintTOP = NSLayoutConstraint(item: topTextfield, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: memeView!, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        memeView!.addConstraint(horizontalConstraintTOP)
        
        let verticalConstraintTOP = NSLayoutConstraint(item: topTextfield, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: memeView!, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 7)
        memeView!.addConstraint(verticalConstraintTOP)
        
        let widthConstraintTOP = NSLayoutConstraint(item: topTextfield, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: memeView!.bounds.size.width - 20)
        memeView!.addConstraint(widthConstraintTOP)
        
        let horizontalConstraintBOTTOM = NSLayoutConstraint(item: bottomTextfield, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: memeView!, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        memeView!.addConstraint(horizontalConstraintBOTTOM)
        
        let verticalConstraintBOTTOM = NSLayoutConstraint(item: bottomTextfield, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: memeView!, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -7)
        memeView!.addConstraint(verticalConstraintBOTTOM)
        
        let widthConstraintBOTTOM = NSLayoutConstraint(item: bottomTextfield, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: memeView!.bounds.size.width - 20)
        memeView!.addConstraint(widthConstraintBOTTOM)
        
        // reset the bool that tracks whether we are in landscape when picking an image
        pickingImageInLandscape = false
    }
    
    // update the Meme Editor when the device is rotated, to display the Meme properly
    func rotated() {
        // Note: When app is 1st launched, rotation notification triggers an extra unneeded updateMemeView here (in addition to calling from ViewWillAppear)
        updateMemeView()
    }
    
    // remove old views before adding new ones with updated constraints ans dimensions
    func removePreviousViews() {
        if imageView != nil {
            imageView?.removeFromSuperview()
        }
        if memeView != nil {
            memeView?.removeFromSuperview()
        }
    }

    func renderMemedImage() {
        UIGraphicsBeginImageContextWithOptions(memeView!.bounds.size, true, 0.0)
        memeView!.drawViewHierarchyInRect(memeView!.bounds, afterScreenUpdates: true)
        renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func renderThumbnail(image: UIImage) {
        let thumbnailScale = thumbnailWidth / image.size.width
        let thumbnailView = UIView(frame: CGRectMake(0, 0, thumbnailScale * image.size.width, thumbnailScale * image.size.height))
        let thumbnailIV = UIImageView(frame: thumbnailView.frame)
        thumbnailView.contentMode = .ScaleAspectFit
        thumbnailIV.contentMode = .ScaleAspectFit
        thumbnailIV.image = image
        view.addSubview(thumbnailView)
        thumbnailView.addSubview(thumbnailIV)
        UIGraphicsBeginImageContext(thumbnailView.frame.size)
        thumbnailView.drawViewHierarchyInRect(thumbnailView.bounds, afterScreenUpdates: true)
        thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        currentMeme?.thumbnail = thumbnail // assuming currentMeme must exist for unwrapping
        UIGraphicsEndImageContext()
        thumbnailView.removeFromSuperview()
    }
    
    //MARK:- Gesture Recognizer functions
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // Don't let tap GR hide tool bars if a textfield is being touched for editing
        if touch.view == topTextfield || touch.view == bottomTextfield {
            return false
        }
        // If text is being edited, and touch is elsewhere on screen, don't hide tool bars
        if topTextfield.isFirstResponder() || bottomTextfield.isFirstResponder() {
            return false
        }
        // Also don't hide toolbars if a tool or button is being used
        for subview in bottomBar.subviews {
            if touch.view == subview as! UIView {
                return false
            }
        }
        for subview in topBar.subviews {
            if touch.view == subview as! UIView {
                return false
            }
        }
        // Anywhere else on the screen, allow the tap gesture recognizer to hideToolBars
        return true
    }
    
    // Cancels textfield editing when user touches outside the textfield
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if bottomTextfield.isFirstResponder() || topTextfield.isFirstResponder() {
            view.endEditing(true)
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    // MARK: - Notifications
    
    func subscribeToRotationNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func unsubscribeToRotationNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextfield.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if keyboardHeight != nil && bottomTextfield.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        // TODO: -What if the user turns the device, and keyboard height changes while the keyboard is up?
        //TODO: What if the keyboard is in split view?
        keyboardHeight = keyboardSize.CGRectValue().height
        return keyboardHeight!
    }

}