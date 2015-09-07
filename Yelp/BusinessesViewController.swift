//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var businesses: [Business]!
    var searchBar : UISearchBar!
    var refreshControl: UIRefreshControl!
    var categories: [String]?
    var sort: YelpSortMode?
    var distance: Float?
    var deals: Bool?
    var term: String = ""
    var locationManager: CLLocationManager!
    var location: String = ""
    
    func filtersViewController(filterViewController: FilterViewController, params: [String: AnyObject]) {
        categories = params["categories"] as? [String]
        sort = YelpSortMode(rawValue: params["sort"] as! Int)
        deals = params["deals"] as? Bool
        distance = params["distance"] as? Float
        term = searchBar.text
        searchWithTerm(term, sort: sort, categories: categories, deals: deals, distance: distance)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let oldLocation = self.location
        let location = locations.last as! CLLocation
        
        self.location = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
        if oldLocation == "" {
            searchWithTerm(term, sort: sort, categories: categories, deals: deals, distance: distance)
        }
    }
    
    func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: Float?){
        let hud = AMTumblrHud(frame: CGRectMake(((self.view.frame.size.width - 55) * 0.5), ((self.view.frame.size.height - 20) * 0.5), 55, 22))
        self.view.alpha = 0.3
        self.view.addSubview(hud)
        hud.showAnimated(true)
        Business.searchWithTerm(term, sort: sort, categories: categories, deals: deals, distance: distance,location: location) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            hud.hide()
            UIView.transitionWithView(self.view, duration: 0.2, options: (UIViewAnimationOptions.CurveLinear | UIViewAnimationOptions.AllowUserInteraction), animations: { () -> Void in
                self.view.alpha = 1
            }, completion: nil)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        term = searchText
        searchWithTerm(term, sort: sort, categories: categories, deals: deals, distance: distance)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.searchBar.isFirstResponder()){
            self.searchBar.resignFirstResponder()
        }
        let actualPosition = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - tableView.frame.size.height
        if (actualPosition >= contentHeight) {
            businesses?.extend(businesses)
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar = UISearchBar()
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search for something"
        self.navigationItem.titleView = self.searchBar
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 240
        if (CLLocationManager.locationServicesEnabled()){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController is UINavigationController {
            let navigationController = segue.destinationViewController as! UINavigationController
            let filtersViewController = navigationController.topViewController as! FilterViewController
            filtersViewController.delegate = self
        }
        else {
            if let tableCell = sender as? UITableViewCell{
                let tableCell = sender as! UITableViewCell
                let indexPath = tableView.indexPathForCell(tableCell)!
                
                let business = businesses![indexPath.row]
                
                let mapViewController = segue.destinationViewController as! MapViewController
                mapViewController.business = business
            }
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
            self.searchWithTerm(self.term, sort: self.sort, categories: self.categories, deals: self.deals, distance: self.distance)
        })
    }
    
}
