//
//  MemeTableViewController.swift
//  MaeMae
//
//  Created by David Fierstein on 6/2/15.
//  Copyright (c) 2015 davidiad. All rights reserved.

import UIKit

class MemeTableViewController: UITableViewController {
    
    //MARK: Vars
    var memes: [Meme]!
    var selectedMemeRow: Int?
    
    //MARK:- View Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        navigationItem.leftBarButtonItem = editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(animated: Bool) {
        memes = appDelegate().memes
        // update the Table View from the data stored in appDelegate each time the view appears
        tableView?.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {

        // If there are no saved memes, go directly to the meme editor so a meme can be created
        super.viewDidAppear(true)
        if memes.count == 0 {
            openMemeEditor()
        }
    }
    
    //MARK:- Meme functions
    
    // helper func for accessing the meme data stored in AppDelegate
    func appDelegate() -> AppDelegate {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        return appDelegate
    }
    
    // configure cells for varying heights (while keeping image width the same)
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func openMemeEditor() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var memeEditor = storyboard.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditor
        presentViewController(memeEditor, animated: true, completion: nil)
    }
    
    // Add an object by going to the Meme Editor, where the new object will be added
    func insertNewObject(sender: AnyObject) {
        openMemeEditor()
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            // Get the new view controller
            var detailScene = segue.destinationViewController as! MemeDetailViewController
            detailScene.hidesBottomBarWhenPushed = true
            if let indexPath = tableView.indexPathForSelectedRow() {
                let selectedMeme = memes[indexPath.row]
                detailScene.currentMeme = selectedMeme
                detailScene.currentMemeIndex = indexPath.row
                detailScene.fontsize = selectedMeme.fontsize
            }
        }
    }
    
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MemeTableViewCell
        

        let meme = memes[indexPath.row] as Meme
        cell.topText!.text = meme.topText
        cell.bottomText!.text = meme.bottomText
        
        // Bring text above the divider background images
        cell.bringSubviewToFront(cell.topText)
        cell.bringSubviewToFront(cell.bottomText)
        
        // set the thumbnail image to the left of the cell
        cell.memeCellImageView.image = meme.thumbnail
        
        /*
        // Set up the (faded) background image for the cell (Not currently in use)
        let cellBounds = CGRect(x: 0, y: 0, width: view.frame.width, height: cell.bounds.height)
        let bgView = UIView(frame: cellBounds)
        bgView.clipsToBounds = true
        bgView.contentMode = .ScaleAspectFill
        let bgIV = UIImageView(frame: cellBounds)
        bgIV.clipsToBounds = true
        //bgIV.image = meme.bg
        bgIV.alpha = 1.0
        cell.backgroundView = bgView
        // altho cell bg color is set to white in IB, and works to lighten the bg in Simulator, the bg was not lightened on iPad mini without this line...
        //cell.backgroundColor = UIColor.whiteColor()
        */
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // set bg color here
        // get a sequence of pastel colors
        let hueValue = MemeModel().backgroundHue(indexPath.row)
        let color = UIColor(hue: hueValue, saturation: 0.35, brightness: 0.9, alpha: 1)
        cell.backgroundColor = color
        let gradient = CAGradientLayer().gradientColor(hueValue)
        gradient.frame = cell.bounds
        cell.backgroundView = UIView()
        cell.backgroundView!.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // remove the meme from the table
            memes.removeAtIndex(indexPath.row)
            // also update the data store that a meme is removed
            appDelegate().memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        selectedMemeRow = indexPath.row
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation:      UIInterfaceOrientation, duration: NSTimeInterval) {
    }
}

/*
    // Allow reordering of the table view cells, to do at some future time
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
*/

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

extension CAGradientLayer {
    
    func gradientColor(hueValue: CGFloat) -> CAGradientLayer {
        let lightestColor = UIColor(hue: hueValue, saturation: 0.23, brightness: 0.95, alpha: 1)
        let lighterColor = UIColor(hue: hueValue, saturation: 0.33, brightness: 0.925, alpha: 1)
        let darkerColor = UIColor(hue: hueValue, saturation: 0.4, brightness: 0.9, alpha: 1)
        
        let gradientColors: Array <AnyObject> = [lightestColor.CGColor, lighterColor.CGColor, darkerColor.CGColor, lighterColor.CGColor, lightestColor.CGColor]
        let gradientLocations: Array <AnyObject> = [0.0, 0.15, 0.5, 0.85, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
}

