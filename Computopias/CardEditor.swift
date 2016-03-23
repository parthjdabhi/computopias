//
//  CardEditor.swift
//  Computopias
//
//  Created by Nate Parrott on 3/21/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class CardEditor: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var hashtag: String!
    var template: [String: AnyObject]?
    
    @IBOutlet var cardView: CardView!
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.backgroundColor = Appearance.colorForHashtag(hashtag)
        view.tintColor = cardView.backgroundColor
        if let t = template {
            // we already have a template, so don't allow editing it:
            collectionView.hidden = true
            cardView.importJson(t)
            for item in cardView.items {
                item.templateEditMode = false
                item.detachFromTemplate()
            }
        }
    }
    
    struct Item {
        var title: String
        var image: UIImage?
        var callback: () -> CardItemView!
    }
    
    let items: [Item] = [
        Item(title: "Label", image: UIImage(named: "label"), callback: { () -> CardItemView! in
            let l = TextCardItemView()
            l.staticLabel = true
            return l
        }),
        Item(title: "Text", image: UIImage(named: "editable_text"), callback: { () -> CardItemView! in
            let l = TextCardItemView()
            l.staticLabel = false
            return l
        }),
        Item(title: "Long text", image: nil, callback: { () -> CardItemView! in
            return nil
        }),
        Item(title: "Image", image: UIImage(named: "image"), callback: { () -> CardItemView! in
            let m = ImageCardItemView()
            delay(0, closure: { () -> () in
                m.insertMedia()
            })
            return m
        }),
        Item(title: "Profile", image: UIImage(named: "profile"), callback: { () -> CardItemView! in
            return ProfileCardItemView()
        }),
        Item(title: "Button", image: UIImage(named: "link"), callback: { () -> CardItemView! in
            return nil
        }),
        Item(title: "Counter", image: nil, callback: { () -> CardItemView! in
            return CounterCardItemView()
        }),
        Item(title: "Likes", image: nil, callback: { () -> CardItemView! in
            return LikeCounterCardItemView()
        }),
        Item(title: "Sound", image: UIImage(named: "audio"), callback: { () -> CardItemView! in
            return nil
        }),
        Item(title: "Timer", image: UIImage(named: "timer"), callback: { () -> CardItemView! in
            return nil
        }),
        Item(title: "Destruct", image: UIImage(named: "destruct"), callback: { () -> CardItemView! in
            return nil
        })
    ]
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CardEditorItemCell
        if let image = items[indexPath.item].image {
            cell.label.text = ""
            cell.imageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
        } else {
            cell.imageView.image = nil
            cell.label.text = items[indexPath.item].title
        }
        cell.label.backgroundColor = Appearance.colors[indexPath.item % Appearance.colors.count]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let itemView = items[indexPath.item].callback() {
            cardView.addSubview(itemView)
            var frame = CGRectMake(0, 0, itemView.defaultSize.width * cardView.gridCellSize.width, itemView.defaultSize.height * cardView.gridCellSize.height)
            if frame.size.width < 0 { frame.size.width = cardView.bounds.size.width }
            if frame.size.height < 0 { frame.size.height = cardView.bounds.size.height }
            itemView.frame = frame
        }
    }
    
    @IBAction func send() {
        let cardJson = cardView.toJson()
        let card = Data.firebase.childByAppendingPath("cards").childByAutoId()
        card.setValue(cardJson)
        
        let cardInfo: [String: AnyObject] = ["date": NSDate().timeIntervalSince1970, "negativeDate": -NSDate().timeIntervalSince1970, "cardID": card.key]
        Data.firebase.childByAppendingPath("hashtags").childByAppendingPath(hashtag).childByAppendingPath("cards").childByAutoId().setValue(cardInfo)
        
        Data.firebase.childByAppendingPath("all_hashtags").childByAppendingPath(hashtag).childByAppendingPath("hashtag").setValue(hashtag)
        Data.firebase.childByAppendingPath("all_hashtags").childByAppendingPath(hashtag).childByAppendingPath("negativeDate").setValue(-NSDate().timeIntervalSince1970)
        
        if template == nil {
            // save this as a template:
            Data.firebase.childByAppendingPath("templates").childByAppendingPath(hashtag).setValue(cardJson)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let padding = (collectionView.bounds.size.height - flowLayout.itemSize.height * 2) / 3
        flowLayout.minimumLineSpacing = padding
        flowLayout.minimumInteritemSpacing = padding
        
        let nCols = Int(ceil(Float(items.count) / 2.0))
        let contentWidth = CGFloat(nCols + 1) * padding + CGFloat(nCols) * flowLayout.itemSize.width
        let leftPadding = padding + max(0, (collectionView.bounds.size.width - contentWidth)/2)
        
        collectionView.contentInset = UIEdgeInsetsMake(padding, leftPadding, padding, padding)
    }
}

class CardEditorItemCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.layer.cornerRadius = label.bounds.size.height/2
        label.clipsToBounds = true
    }
}

