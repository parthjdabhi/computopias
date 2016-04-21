//
//  NavigableViewController.swift
//  Computopias
//
//  Created by Nate Parrott on 3/28/16.
//  Copyright © 2016 Nate Parrott. All rights reserved.
//

import UIKit

class NavigableViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    // MARK: Routing
    class func FromRoute(route: Route) -> NavigableViewController! {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: NavigableViewController!
        switch route {
        case .Card(hashtag: let hashtag, id: let id): ()
            // TODO
            // vc = storyboard.instantiateViewControllerWithIdentifier("CardFeedViewController") as! CardFeedViewController
            // vc!.route = route
            // (vc as! CardFeedViewController).rows = [CardFeedViewController.RowModel.Card(id: id, hashtag: hashtag)]
        case .Hashtag(name: let hashtag):
            vc = HashtagCardsViewController()
            (vc as! HashtagCardsViewController).hashtag = hashtag
        case .HashtagsList:
            vc = storyboard.instantiateViewControllerWithIdentifier("GroupsList") as! GroupsListViewController
        default:
            vc = storyboard.instantiateViewControllerWithIdentifier("NavigableViewController") as! NavigableViewController
        }
        vc?.route = route
        return vc
    }
    
    var route: Route!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigableViewController._forceRefresh), name: Data.LoginDidCompleteNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NavigableViewController._forceRefresh), name: Data.BlockedUsersChangedNotification, object: nil)
    }
    
    var visible = false {
        didSet {
            _updating = visible && Data.getUID() != nil
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        _setupBarsAnimated(animated)
        visible = true
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        visible = false
    }
    
    // Mark: Data observing
    
    func _forceRefresh() {
        _updating = false
        _updating = visible && Data.getUID() != nil
    }
    
    var _updating = false {
        didSet(oldVal) {
            if oldVal != _updating {
                if _updating {
                    startUpdating()
                } else {
                    stopUpdating()
                }
            }
        }
    }
    
    func startUpdating() {
        
    }
    
    func stopUpdating() {
        
    }
    
    // MARK: Search bar/nav
    
    func _setupBarsAnimated(animated: Bool) {
        /*if self === navigationController?.viewControllers.first {
            let dummy = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
            navigationItem.leftBarButtonItem = dummy
        }*/
                
        let hasToolbar = getTabs() != nil
        if let tabs = getTabs() {
            let flex1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let flex2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            _tabBarButtonItems = tabs.map({ UIBarButtonItem(title: $0.0, style: .Plain, target: self, action: #selector(NavigableViewController.switchTab)) })
            _tabRoutes = tabs.map({ $0.1 })
            for (item, route) in zip(_tabBarButtonItems!, _tabRoutes!) {
                item.tintColor = (route.string == self.route.string) ? nil : UIColor.grayColor()
            }
            toolbarItems = [flex1] + _tabBarButtonItems! + [flex2]
        }
        navigationController?.setToolbarHidden(!hasToolbar, animated: animated)
    }
    
    func navigate(route: Route) -> NavigableViewController {
        let vc =  NavigableViewController.FromRoute(route)
        navigationController!.pushViewController(vc, animated: true)
        return vc
    }
    func navigateInPlace(route: Route) -> NavigableViewController {
        let vc =  NavigableViewController.FromRoute(route)
        let nav = navigationController!
        var vcs = nav.viewControllers
        vcs[vcs.count-1] = vc
        nav.viewControllers = vcs
        return vc
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let text = searchBar.text where text != "" {
            navigate(Route.fromString(text) ?? Route.Nothing)
        }
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.text = route.titleStringForNav
        searchBar.setShowsCancelButton(false, animated: true)
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    var isHome: Bool {
        get {
            return false
        }
    }
    
    // MARK: Tabs
    var _tabBarButtonItems: [UIBarButtonItem]?
    var _tabRoutes: [Route]?
    func switchTab(sender: UIBarButtonItem) {
        navigateInPlace(_tabRoutes![_tabBarButtonItems!.indexOf(sender)!])
    }
    
    func getTabs() -> [(String, Route)]? {
        return nil
    }
    
    class func homeTabs() -> [(String, Route)] {
        return [("Activity", Route.HashtagsList), ("Friends", Route.ProfilesList), ("New Stack", Route.CreateGroup)]
    }
    
    // MARK: Convenience
    func showAlert(text: String) {
        let a = UIAlertController(title: nil, message: text, preferredStyle: .Alert)
        a.addAction(UIAlertAction(title: "Okay", style: .Cancel, handler: nil))
        presentViewController(a, animated: true, completion: nil)
    }
    
    // MARK: Layout
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
