//
//  ButtonCardItemView.swift
//  Computopias
//
//  Created by Nate Parrott on 3/23/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit
import SafariServices
import AsyncDisplayKit

class ButtonCardItemView: CardItemView {
    override func setup() {
        super.setup()
        self.title = "Tap to edit..."
        opaque = false
        needsDisplayOnBoundsChange = true
    }
    
    override var needsNoView: Bool {
        get {
            return true
        }
    }
    
    override var defaultSize: GridSize {
        return GridSize(width: 3, height: 1)
    }
    
    override func constrainedSizeForProposedSize(size: GridSize) -> GridSize {
        return size
    }
    
    var link = ""
    
    override func tapped() -> Bool {
        if editMode {
            edit()
        } else {
            openLink()
        }
        return true
    }
    
    func edit() {
        let editor = UIAlertController(title: "Edit Button", message: "Choose a title and a link", preferredStyle: .Alert)
        editor.addTextFieldWithConfigurationHandler({ (let field) in
            field.placeholder = "Button title"
            field.text = self.title
            if field.text == "Tap to edit..." {
                field.text = ""
            }
            field.clearButtonMode = .Always
        })
        editor.addTextFieldWithConfigurationHandler({ (let field) in
            field.placeholder = "Link"
            field.text = self.link
            field.clearButtonMode = .Always
        })
        editor.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (_) in
            self.title = editor.textFields![0].text!
            self.link = editor.textFields![1].text ?? ""
        }))
        presentViewController(editor)
    }
    
    func openLink() {
        print("opening link: \(link)")
        if let firstChar = link.characters.first {
            if firstChar == "#".characters.first! {
                let s = link[1..<link.characters.count]
                (UIApplication.sharedApplication().delegate as! AppDelegate).navigateToRoute(Route.Hashtag(name: s))
            } else {
                var isURL = false
                if link.componentsSeparatedByString(" ").count > 1 {
                    isURL = false
                } else if let u = NSURL(string: link) where u.scheme != "" {
                    isURL = true
                } else if link.componentsSeparatedByString(".").count > 1 {
                    isURL = true
                }
                
                if link.componentsSeparatedByString(" ").count > 1 {
                    isURL = false
                }
                if link.componentsSeparatedByString(".").count == 1 {
                    isURL = false
                }
                if link.hasPrefix("sms://") || link.hasPrefix("bubble://") {
                    isURL = true
                }
                if isURL {
                    if var url = NSURL(string: link) {
                        if url.scheme == "" {
                            url = NSURL(string: "http://" + link)!
                        }
                        if url.scheme == "http" || url.scheme == "https" {
                            let safari = SFSafariViewController(URL: url)
                            presentViewController(safari)
                        } else {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                } else {
                    let alertVC = UIAlertController(title: nil, message: link, preferredStyle: .Alert)
                    alertVC.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (_) in
                        
                    }))
                    presentViewController(alertVC)
                }
            }
        }
    }
    
    override func importJson(json: [String : AnyObject]) {
        super.importJson(json)
        link = json["link"] as? String ?? ""
        title = json["title"] as? String ?? ""
    }
    
    override func toJson() -> [String : AnyObject] {
        var j = super.toJson()
        j["type"] = "button"
        j["title"] = title
        j["link"] = link
        return j
    }
    
    var title: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func drawParametersForAsyncLayer(layer: _ASDisplayLayer) -> NSObjectProtocol? {
        var attributes = [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor()
        attributes[NSFontAttributeName] = TextCardItemView.font.fontWithSize(generousFontSize)
        attributes[NSParagraphStyleAttributeName] = NSAttributedString.paragraphStyleWithTextAlignment(.Center)
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    override class func drawRect(bounds: CGRect, withParameters: NSObjectProtocol?, isCancelled: asdisplaynode_iscancelled_block_t, isRasterizing: Bool) {
        Appearance.transparentWhite.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: CardView.rounding).fill()
        let string = withParameters as! NSAttributedString
        string.drawVerticallyCenteredInRect(CardItemView.textInsetBoundsForBounds(bounds))
    }
}
