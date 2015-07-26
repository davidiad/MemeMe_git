//
//  MemeCollectionViewController.swift
//  MaeMae
//
//  Created by David Fierstein on 6/4/15.
//  Copyright (c) 2015 davidiad. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    //MARK:- Vars and Constants
    let reuseIdentifier = "Cell"
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var memes: [Meme]!
    
    //MARK:- View Lifecycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        // Uncomment the following line to preserve selection between presentations
        clearsSelectionOnViewWillAppear = false

        // Register cell classes
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewWillAppear(animated: Bool) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        memes = appDelegate.memes
        collectionView?.reloadData()
        // If there are no saved memes, go directly to the meme editor so a meme can be created
        if memes.count == 0 {
            openMemeEditor()
        }
    }
    
    //MARK:- Meme functions
    func openMemeEditor() {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        var memeEditor = storyboard.instantiateViewControllerWithIdentifier("MemeEditor") as! MemeEditor
        presentViewController(memeEditor, animated: true, completion: nil)
    }
    
    func insertNewObject(sender: AnyObject) {
        openMemeEditor()
    }

    // MARK:- UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        // Configure the cell
        let meme = memes[indexPath.item]
        // constraints have been set on the image in IB so that there are a couple of pixels outline around each image
        
        // autoconstraints conflicts with constraints, avoid warnings by setting:
        //(credit to Junda Ong, samwize.com, for pointing out that this needs to be set on the cell contentView
        cell.contentView.setTranslatesAutoresizingMaskIntoConstraints(false) // gets rid of autoconstraint breakage warning, but now we need to set the image size explicitly so it doesn't extend past the cell frame
        let cellImageIV = UIImageView(frame: CGRectMake(2, 2, meme.cellSize.width - 4, meme.cellSize.height - 4))
        cellImageIV.image = meme.memedImage
        // Remove any previous subviews from the cell before adding the new one
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        cell.addSubview(cellImageIV)
        
        let hueValue = MemeModel().backgroundHue(indexPath.row)
        let color = UIColor(hue: hueValue, saturation: 0.35, brightness: 0.9, alpha: 1)
        cell.backgroundColor = color
        
        // Add some shadow to the collection view cells
        cell.layer.shadowColor = UIColor(hue: 0.7, saturation: 0.65, brightness: 0.125, alpha: 1).CGColor
        cell.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        cell.layer.shadowOpacity = 0.8
        cell.layer.shadowRadius = 7
        cell.layer.masksToBounds = true
        cell.clipsToBounds = false
        
        return cell
    }

    // MARK:- UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailController.currentMeme = memes[indexPath.item]
        detailController.hidesBottomBarWhenPushed = true
        let selectedMeme = memes[indexPath.item]
        detailController.currentMeme = selectedMeme
        detailController.currentMemeIndex = indexPath.item
        navigationController!.pushViewController(detailController, animated: true)
    }

}

//MARK:- Extension

extension MemeCollectionViewController : UICollectionViewDelegateFlowLayout {
    
    // Determine the size for each cell in Collection View
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            // allow 5 or so images side by side if device is an iPad
            var numColumns: CGFloat = 5.0
            // if device is a phone, let only 3 or so images side by side because iPhone is most typically viewed portrait orientation
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                numColumns = 3.0
            }
            // if the device is a smaller (5s or lower) iphone, allow 2 images per row
            if view.bounds.size.width < 321.0 {
                numColumns = 2.0
            }
            var maxWidth = (view.bounds.size.width / numColumns) - 24.0

            // Find the scale for the image. The height will vary, but the width will always stay the same
            let meme = memes[indexPath.item]
            let cellMemedImage = meme.memedImage
            var size = cellMemedImage!.size
            let cellScale = maxWidth / size.width
            size.width = maxWidth + 8
            size.height  = (cellScale * size.height) + 8
            memes[indexPath.item].cellSize = size
            return size
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return sectionInsets
    }
}
