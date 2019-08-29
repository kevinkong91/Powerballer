//
//  ViewController.swift
//  Powerballer
//
//  Created by Kevin Kong on 1/12/16.
//  Copyright © 2016 Kevin Kong. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Data
    
    var session: NSURLSession!
    
    var managedObjectContext:NSManagedObjectContext!
    
    lazy var previousNumbers = [Drawing]()
    lazy var myNumbers = [NSManagedObject]()
    
    lazy var textToShare = String()
    
    
    // Basic UI
    
    var navigationBar: UINavigationBar!
    
    var backgroundColor: UIColor!
    let font = "GothamRounded-Medium"
    let fontBold = "GothamRounded-Bold"
    
    lazy var introLabelTimer = NSTimer()
    var introLabel: UILabel!
    
    var imageView: UIImageView!
    
    // Generating numbers
    
    lazy var newNumbers = [String]()
    lazy var powerballNumber = String()
    
    var generateNumbersElements: [UIView]!
    lazy var numbersLabel = UILabel()
    lazy var powerballLabel = UILabel()
    
    var saveNumbersButton: UIButton!
    var jackpotLabel: UILabel!
    
    var generateNumbersButton: UIButton!
    
    
    // Menu / other views
    lazy var blurView = UIVisualEffectView()
    var segmentedControl: UISegmentedControl!
    var previousWinnersTableView: UITableView!
    var myNumbersTableView: UITableView!
    var dataSourceLabel: UILabel!
    var shareButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        // App Delegate / CoreData
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        
        // Web Services
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        
        // Title
        navigationBar = UINavigationBar(frame: CGRectMake(0,0,view.frame.width,44))
        navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage()
        navigationBar.translucent = true
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: fontBold, size: 14)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "menu")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "showPreviousWinningNumbers")
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.title = "powerballer".uppercaseString
        navigationBar.items = [navigationItem]
        
        
        
        // Init background
        self.backgroundColor = UIColor.randomColor()
        self.view.backgroundColor = self.backgroundColor
        
        
        //let adBar = UIButton()
        
        // Intro Label
        let padding:CGFloat = 10
        
        introLabel = UILabel()
        introLabel.font = UIFont(name: font, size: 25)
        introLabel.textAlignment = .Center
        introLabel.adjustsFontSizeToFitWidth = true
        introLabel.textColor = UIColor.whiteColor()
        introLabel.frame.size = CGSizeMake(view.frame.width - padding * 2, 60)
        introLabel.center = CGPointMake((view.frame.width) / 2, view.frame.height / 2)
        introLabel.alpha = 1
        
        generateIntroText()
        introLabelTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "generateIntroText", userInfo: nil, repeats: true)
        
        
        
        
        
        
        
        
        //
        // MAIN VIEW
        //
        
        
        // Screen Size - dynamic formatting
        let size = UIScreen.mainScreen().bounds.size
        let currentDeviceIsSmall = size.height < 568
        
        
        let iconOriginY:CGFloat = currentDeviceIsSmall ? 100 : 150
        let descriptionLabelOriginY:CGFloat = currentDeviceIsSmall ? 60 : 90
        let infoLabelOriginY:CGFloat = currentDeviceIsSmall ? 15 : 25
        
        
        
        // Icon
        
        imageView = UIImageView()
        imageView.frame.size = CGSizeMake(60, 60)
        imageView.center = CGPointMake(view.frame.width / 2, view.frame.height / 2 - iconOriginY)
        imageView.alpha = 0
        
        
        
        
        
        //
        // Number generation view
        //
        
        let circleSize:CGFloat = 0.16 * view.frame.width
        
        // Numbers
        numbersLabel.font = UIFont(name: fontBold, size: 25)
        numbersLabel.textAlignment = .Center
        numbersLabel.adjustsFontSizeToFitWidth = true
        numbersLabel.textColor = UIColor.whiteColor()
        numbersLabel.frame = CGRectMake(padding * 2, view.frame.height / 2 - 30, view.frame.width - circleSize - padding * 6, 60)
        numbersLabel.alpha = 0
        
        
        // Powerball Label
        let fontSize:CGFloat = numbersLabel.font.valueForKey("pointSize") as! CGFloat
        powerballLabel.font = UIFont(name: fontBold, size: fontSize)
        powerballLabel.textColor = UIColor.whiteColor()
        powerballLabel.textAlignment = .Center
        powerballLabel.frame = CGRectMake(numbersLabel.frame.maxX + padding * 1.5, view.frame.height / 2 - circleSize / 2, circleSize, circleSize)
        powerballLabel.layer.cornerRadius = powerballLabel.frame.height / 2
        powerballLabel.layer.masksToBounds = true
        powerballLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        powerballLabel.alpha = 0
        
        
        
        
        
        
        // Jackpot &
        // Your chances:
        let currentJackpotLabel = UILabel()
        let yourChancesLabel = UILabel()
        let cashValueLabel = UILabel()
        
        for label in [currentJackpotLabel, yourChancesLabel, cashValueLabel] {
            
            let text = label == yourChancesLabel ? "your chances:" : "current jackpot:"
            let centerX = label == yourChancesLabel ? (view.frame.width * 3/4) : (view.frame.width / 4)
            
            label.text = text.uppercaseString
            label.font = UIFont(name: fontBold, size: 12)
            label.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            label.textAlignment = .Center
            label.sizeToFit()
            label.center = CGPointMake(centerX, view.frame.height / 2 + descriptionLabelOriginY)
            label.alpha = 0
        }
        
        cashValueLabel.text = ""
        cashValueLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        cashValueLabel.font = UIFont(name: font, size: 10)
        cashValueLabel.center = CGPointMake(cashValueLabel.center.x, yourChancesLabel.frame.maxY + infoLabelOriginY * 2)
        
        
        let probabilityLabel = UILabel()
        jackpotLabel = UILabel()
        
        for label in [jackpotLabel, probabilityLabel] {
            
            let text = label == jackpotLabel ? "" : "1 in 292,201,338"
            let centerX = label == jackpotLabel ? (view.frame.width / 4) : (view.frame.width * 3/4)
            
            label.text = text
            label.font = UIFont(name: fontBold, size: 18)
            label.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.7)
            label.textAlignment = .Center
            label.adjustsFontSizeToFitWidth = true
            label.frame.size = CGSizeMake(view.frame.width / 2 - 20, 20)
            label.center = CGPointMake(centerX, yourChancesLabel.frame.maxY + infoLabelOriginY)
            label.alpha = 0

        }
        
        
        
        // Update Current Jackpot
        Lottery.fetchJackpotWinnings({ (jackpot, cashValue) -> Void in
            if let jackpot = jackpot, cashValue = cashValue {
                
                self.jackpotLabel.text = jackpot
                
                cashValueLabel.text = "\(cashValue) CV"
            }
        })
        
        
        
        
        
        
        // Buttons
        
        generateNumbersButton = UIButton()
        generateNumbersButton.setTitle("Start".uppercaseString, forState: .Normal)
        generateNumbersButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        generateNumbersButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.4), forState: .Highlighted)
        generateNumbersButton.titleLabel!.font = UIFont(name: fontBold, size: 16)
        generateNumbersButton.frame = CGRectMake(0, view.frame.height - 80, view.frame.width, 80)
        generateNumbersButton.addTarget(self, action: "startGenerating", forControlEvents: .TouchUpInside)
        generateNumbersButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        
        
        // SAVE button
        saveNumbersButton = UIButton()
        saveNumbersButton.setTitle("SAVE", forState: .Normal)
        saveNumbersButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.4), forState: .Normal)
        saveNumbersButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.1), forState: .Highlighted)
        saveNumbersButton.titleLabel!.font = UIFont(name: fontBold, size: 18)
        saveNumbersButton.frame.size = CGSizeMake(250, 20)
        saveNumbersButton.center = CGPointMake(view.frame.width / 2, generateNumbersButton.frame.minY - 25)
        saveNumbersButton.addTarget(self, action: "saveCurrentNumbers", forControlEvents: .TouchUpInside)
        saveNumbersButton.alpha = 0
        
        
        
        
        
        
        // Elements to be added in after tapping START button
        
        generateNumbersElements = [numbersLabel, powerballLabel, saveNumbersButton, currentJackpotLabel, jackpotLabel, cashValueLabel, yourChancesLabel, probabilityLabel]
        
        
        
        // Add to view
        for item in [navigationBar, imageView, introLabel, numbersLabel, powerballLabel, generateNumbersButton, saveNumbersButton, currentJackpotLabel, jackpotLabel, cashValueLabel, yourChancesLabel, probabilityLabel] {
            view.addSubview(item)
        }
        
        
        
        
        
        
        
        
        
        // Previous Winning Numbers
        
        
        // Create black blur
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = CGRectMake(0, 0, view.frame.width,  view.frame.height)
        blurView.alpha = 0
        
        let navBar = UINavigationBar(frame: CGRectMake(0, 0, view.frame.width, 44))
        navBar.tintColor = UIColor.whiteColor()
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.translucent = true
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "x-mark")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "closeView")
        let leftItem = UINavigationItem()
        leftItem.leftBarButtonItem = closeButton
        
        navBar.items = [leftItem]
        
        blurView.addSubview(navBar)
        
        
        
        // Segmented Control
        let items = [
            "Previous Winners".uppercaseString,
            "My Numbers".uppercaseString
        ]
        
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.tintColor = UIColor.whiteColor()
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: font, size: 12)!], forState: .Normal)
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: self.backgroundColor], forState: .Selected)
        segmentedControl.frame = CGRectMake(padding, navBar.frame.height + 5, view.frame.width - padding * 2, 25)
        segmentedControl.addTarget(self, action: "indexChanged:", forControlEvents: .ValueChanged)
        segmentedControl.selectedSegmentIndex = 0
        
        
        
        // TableView
        
        previousWinnersTableView = UITableView()
        myNumbersTableView = UITableView()
        
        for table in [previousWinnersTableView, myNumbersTableView] {
            
            let tag = table == previousWinnersTableView ? 0 : 1
            let allowsSelection = table == myNumbersTableView
            
            table.delegate = self
            table.dataSource = self
            table.frame = CGRectMake(0, navBar.frame.height + 44, view.frame.width, view.frame.height / 2)
            table.registerClass(NumberCell.self, forCellReuseIdentifier: NSStringFromClass(NumberCell))
            table.separatorStyle = .None
            table.allowsSelection = allowsSelection
            table.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.05)
            table.tag = tag
        }
        
        previousWinnersTableView.delegate = self
        previousWinnersTableView.dataSource = self
        previousWinnersTableView.frame = CGRectMake(0, navBar.frame.height + 44, view.frame.width, view.frame.height / 2)
        previousWinnersTableView.registerClass(NumberCell.self, forCellReuseIdentifier: NSStringFromClass(NumberCell))
        previousWinnersTableView.separatorStyle = .None
        previousWinnersTableView.allowsSelection = false
        previousWinnersTableView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.05)
        previousWinnersTableView.tag = 0
        
        
        // data source
        dataSourceLabel = UILabel()
        dataSourceLabel.text = "data source: NYC Gov".uppercaseString
        dataSourceLabel.textAlignment = .Center
        dataSourceLabel.font = UIFont(name: font, size: 10)
        dataSourceLabel.frame = CGRectMake(0, previousWinnersTableView.frame.maxY + 10, view.frame.width, 12)
        dataSourceLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        
        
        
        // Share button
        shareButton = UIButton()
        shareButton.setTitle("SHARE", forState: .Normal)
        shareButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        shareButton.titleLabel!.font = UIFont(name: fontBold, size: 18)
        shareButton.layer.borderWidth = 1.5
        shareButton.layer.borderColor = UIColor.whiteColor().CGColor
        shareButton.layer.masksToBounds = true
        shareButton.layer.cornerRadius = 3.0
        shareButton.backgroundColor = UIColor.clearColor()
        shareButton.frame = CGRectMake(padding, dataSourceLabel.frame.maxY + 25, view.frame.width - padding * 2, 50)
        shareButton.addTarget(self, action: "showShareView", forControlEvents: .TouchUpInside)
        
        
        
        // Signature
        
        
        let signature = UILabel()
        signature.text = "2016 © Kevin Kong"
        signature.font = UIFont(name: font, size: 14)
        signature.textColor = UIColor.whiteColor()
        signature.textAlignment = .Center
        signature.frame = CGRectMake(0, view.frame.height - 28, view.frame.width, 28)
        
        
        
        
        
        
        
        // My Numbers
        
        
        
        
        
        
        
        for item in [segmentedControl, previousWinnersTableView, dataSourceLabel, shareButton, signature] {
            blurView.addSubview(item)
        }
        
        
        
        
        fetchSavedNumbers()
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    
    
    
    //
    // MARK: UITableViewDataSource
    //
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return self.previousNumbers.count
        } else {
            return max(1, self.myNumbers.count)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.tag == 1 && self.myNumbers.isEmpty {
            
            let cell = UITableViewCell()
            
            // If no numbers are saved yet
            cell.textLabel!.text = "No numbers saved!\nTap to test your luck."
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "generateTappedFromBlurView")
            cell.addGestureRecognizer(tapGesture)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NumberCell)) as! NumberCell
            
            if tableView.tag == 0 {
                
                cell.numbers = self.previousNumbers[indexPath.row].numbers
                cell.dates = self.previousNumbers[indexPath.row].date
                
            } else {
                
                let numbers = self.myNumbers[indexPath.row]
                
                if let themNumbers = numbers.valueForKey("numbers") as? String {
                    cell.numbers = themNumbers
                }
                
                if let themDates = numbers.valueForKey("date") as? NSDate {
                    cell.dates = themDates
                }
            }
            
            return cell
            
        }
        
    }
    
    
    
    
    
    //
    // MARK: UITableViewDelegate
    //
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.font = UIFont(name: fontBold, size: 15)
        cell.textLabel?.frame.size = CGSizeMake(view.frame.width, 90)
        cell.textLabel?.textAlignment = .Center
        cell.textLabel?.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        cell.textLabel?.numberOfLines = 0
        
        
        if !self.myNumbers.isEmpty {
            
            let selectedBgView = UIView(frame: cell.frame)
            selectedBgView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.1)
            cell.selectedBackgroundView = selectedBgView
            
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    var myNumberIsSelected = false
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        myNumberIsSelected = true
        
        
        // Edit Share Text
        let myNumbers = self.myNumbers[indexPath.row]
        if let numbers = myNumbers.valueForKey("numbers") as? String {
            self.textToShare = "Wish me luck with these numbers! \(numbers) #PowerBaller"
        }
        
        // Toggle Share Button
        self.toggleShareButton()
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        myNumberIsSelected = false
        
        // Edit Share Text
        self.textToShare = "Wanna try your luck? Become a #PowerBaller"
        
        // Toggle Share Button
        self.toggleShareButton()
    }
    
    
    internal func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if (cell?.selected ?? false) {
            // Deselect manually
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            tableView.delegate!.tableView?(tableView, didDeselectRowAtIndexPath: indexPath)
            return nil
        }
        
        return indexPath
    }
    
    
    
    // Edits
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if tableView.tag == 1 {
            
            // If not empty, then should return true (can edit)
            return !self.myNumbers.isEmpty
            
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.tag == 1 {
            return .Delete
        } else {
            return .None
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.tag == 1 {
            
            if editingStyle == .Delete {
                
                // remove the deleted item from the model
                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let context:NSManagedObjectContext = appDelegate.managedObjectContext
                
                context.deleteObject(self.myNumbers[indexPath.row] as NSManagedObject)
                self.myNumbers.removeAtIndex(indexPath.row)
                
                do {
                    try context.save()
                } catch {
                    
                    let errorAlert = UIAlertController(title: "Error while saving", message: "We could not save your changes. Please try again later!", preferredStyle: .Alert)
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                    
                }
                
                
                // remove the deleted item from the `UITableView`
                if self.myNumbers.isEmpty {
                    
                    // Show the "No numbers" notif
                    let cell = tableView.cellForRowAtIndexPath(indexPath)!
                    cell.fadeOut(0.3, delay: 0) { f in
                        self.myNumbersTableView.reloadData()
                    }
                    
                } else {
                    self.myNumbersTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                
                
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    //
    // MARK: Methods
    //
    
    
    

    
    var startedGeneratingNumbers = false
    
    
    // Generate tapped
    
    func generateTappedFromBlurView() {
        
        self.closeView()
        
        if self.startedGeneratingNumbers == false {
            self.startGenerating()
        } else {
            self.showNextSetOfNumbers()
        }
        
    }
    
    
    
    // kick off the generation
    
    func startGenerating() {
        
        startedGeneratingNumbers = true
        
        introLabel.fadeOut(0.5, delay: 0) { (f) -> Void in
            
            // Stop the timer
            self.introLabelTimer.invalidate()
            
            // Fade out the intro
            self.introLabel.removeFromSuperview()
            
            
            
            // Fade in the labels
            for item in self.generateNumbersElements {
                item.fadeIn()
            }
            
            //Format button
            self.generateNumbersButton.setTitle("Generate".uppercaseString, forState: .Normal)
            self.generateNumbersButton.removeTarget(self, action: "startGenerating", forControlEvents: .TouchUpInside)
            self.generateNumbersButton.addTarget(self, action: "showNextSetOfNumbers", forControlEvents: .TouchUpInside)
            
            
            // Start animating image
            self.animateImage()
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "animateImage", userInfo: nil, repeats: true)
            
        }
        
        
        
        self.showNextSetOfNumbers()
    }
    
    
    
    // Animate the next set of numbers in
    
    internal func showNextSetOfNumbers() {
        
        // Morph color
        UIView.animateWithDuration(0.6) { () -> Void in
            
            self.backgroundColor = UIColor.randomColor()
            self.view.backgroundColor = self.backgroundColor
            
        }
        
        // Fade out current Numbers
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.numbersLabel.alpha = 0
            self.powerballLabel.alpha = 0
            
            }) { (finished) -> Void in
                
                // Change numbers
                (self.newNumbers, self.powerballNumber) = self.generateNumbers()
                self.numbersLabel.text = self.newNumbers.joinWithSeparator("   ")
                self.powerballLabel.text = self.powerballNumber
                
                // Fade back in
                self.numbersLabel.fadeIn()
                self.powerballLabel.fadeIn()

                // Format save button
                if self.saveNumbersButton.enabled == false {
                    self.resetSaveNumbersButton()
                    self.saveNumbersButton.enabled = true
                    self.saveNumbersButton.alpha = 1
                }
                
        }
        
        
    }
    
    
    
    
    
    // Random Numbers
    
    
    private func generateNumbers() -> ([String], String) {
        
        
        var numbers = [String]()
        
        
        // Generate 5 numbers
        for var i = 0; i < 5; i++ {
            
            var randomNumber = String(arc4random_uniform(69) + 1)
            
            // Keep making until no repeats
            while numbers.contains(randomNumber) {
                randomNumber = String(arc4random_uniform(69) + 1)
            }
            
            numbers.append(randomNumber)
        }
        
        let powerballNumber:String = String(arc4random_uniform(26) + 1)
        
        return (numbers, powerballNumber)
        
    }
    
    
    
    
    
    // Random Text
    
    internal func generateIntroText() {
        
        self.introLabel.text = generateString()
        
        self.introLabel.fadeIn(0.2, delay: 0) { fini in
            self.introLabel.fadeOut(0.2, delay: 3.6, completion: nil)
        }
        
    }
    
    
    var stringIndex:Int = 0
    private func generateString() -> String {
        let strings = [
            "Fortune favors the Bold",
            "Try your luck",
            "Time is money",
            "What's to lose?",
            "Live your dream",
            "A dollar and a dream",
            "You never know",
            "Live on the wild side"
        ]
        
        let string = strings[stringIndex]
        
        if stringIndex < strings.count - 1 {
            stringIndex++
        } else if stringIndex == strings.count - 1 {
            stringIndex = 0
        }
        
        return string
        
    }
    
    
    
    
    // Random Image
    
    internal func animateImage() {
        
        self.generateImage()
        
        self.imageView.fadeIn(0.2, delay: 0) { fini in
            self.imageView.fadeOut(0.2, delay: 3.6, completion: nil)
        }
        
    }
    
    var imageIndex = 0
    private func generateImage() {
        
        let images = [
            "Bill",
            "Bills",
            "Dice",
            "Dollar",
            "Money-Bag",
            "Piggy-Bank",
        ]
        
        let image = images[imageIndex]
        
        if imageIndex < images.count - 1 {
            imageIndex++
        } else if imageIndex == images.count - 1 {
            imageIndex = 0
        }
        
        self.imageView.contentMode = .ScaleAspectFit
        self.imageView.image = UIImage(named: image)!
    }
    
    
    
    
    // Save numbers to CoreData
    
    internal func saveCurrentNumbers() {
        
        if !self.newNumbers.isEmpty && !self.powerballNumber.isEmpty {
            
            
            var allNumbers = self.newNumbers
            allNumbers.append(self.powerballNumber)
            let allNumbersString = allNumbers.joinWithSeparator(" ")
            
            
            let entity =  NSEntityDescription.entityForName("Numbers",
                inManagedObjectContext:managedObjectContext)
            
            let numbers = NSManagedObject(entity: entity!,
                insertIntoManagedObjectContext: managedObjectContext)
            
            if self.myNumbers.contains(numbers) {
                
            } else {
                
                numbers.setValuesForKeysWithDictionary([
                    "date": NSDate(),
                    "numbers": allNumbersString
                    ])
                
                
                do {
                    
                    try self.managedObjectContext!.save()
                    self.myNumbers.append(numbers)
                    self.myNumbersTableView.reloadData()
                    
                    
                    // Hide button
                    self.saveNumbersButton.alpha = 0.5
                    self.saveNumbersButton.enabled = false
                    
                    
                    
                    // Success!
                    self.saveNumbersButton.setTitle("Success!".uppercaseString, forState: .Normal)
                    
                    
                } catch {
                    // Error!
                    self.saveNumbersButton.setTitle("Error!".uppercaseString, forState: .Normal)
                }
                
            }
            
            
        }
        
        
    }
    
    func resetSaveNumbersButton() {
        self.saveNumbersButton.setTitle("SAVE", forState: .Normal)
    }
    
    
    // Fetch saved numbers
    
    func fetchSavedNumbers() {
        
        // Managed Context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        // Fetch Data
        let fetchRequest = NSFetchRequest(entityName: "Numbers")
        
        // Handle Data
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            self.myNumbers = results as! [NSManagedObject]
            self.myNumbersTableView.reloadData()
            
            
        } catch {
            
            self.saveNumbersButton.setTitle("Error!", forState: .Normal)
            NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "resetSaveNumbersButton", userInfo: nil, repeats: false)
        }
    }
    
    
    
    
    
    
    //
    // Segue
    //
    
    
    func showPreviousWinningNumbers() {
        
        if self.previousNumbers.isEmpty {
            
            // Apple API
            let request = NSURLRequest(URL: NSURL(string: "https://data.ny.gov/api/views/d6yy-54nr/rows.json?accessType=DOWNLOAD")!)
            let dataTask = self.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                if let data = data {
                    
                    
                    if let jsonObject = NSJSONSerialization.JSONObjectWithData(data, options: []) {
                        
                        var drawingsObjects = [Drawing]()
                        let drawingsArray = jsonObject["data"].array!
                        
                        // Only the 25 most recent drawings
                        for drawing in drawingsArray[0..<25] {
                            let dateString = drawing[8].stringValue
                            let numbers = drawing[9].stringValue
                            
                            
                            // Formatted date
                            let formatter = NSDateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                            
                            var dateToAdd = NSDate()
                            
                            if let date = formatter.dateFromString(dateString) {
                                dateToAdd = date
                            }
                            
                            
                            let drawingToAdd = Drawing(date: dateToAdd, numbers: numbers)
                            
                            drawingsObjects.append(drawingToAdd)
                        }
                        
                        return drawingsObjects

                        
                    }
                    
                    
                    
                }
                
            })
            
            
            dataTask.resume()
            
            // Alamofire version
            
            Lottery.fetchPreviousWinners { (drawings) -> Void in
                if let drawings = drawings {
                    self.previousNumbers = drawings
                    self.previousWinnersTableView.reloadData()
                }
            }
        }
        
        // Dynamically change font color
        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: self.backgroundColor], forState: .Selected)
        
        // Add views
        self.view.addSubview(self.blurView)
        self.blurView.fadeIn(0.3)
    }
    
    func closeView() {
        self.blurView.fadeOut(0.3, delay: 0) { (f) -> Void in
            self.blurView.removeFromSuperview()
        }
    }
    
    
    func indexChanged(sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            
            self.myNumbersTableView.fadeOut(0.2, delay: 0) { f in
                
                // Remove Numbers Table
                self.myNumbersTableView.removeFromSuperview()
                
                // Add Previous Numbers Table
                self.blurView.addSubview(self.previousWinnersTableView)
                self.previousWinnersTableView.fadeIn()
                
                // Data source label
                self.blurView.addSubview(self.dataSourceLabel)
                self.dataSourceLabel.fadeIn()
                
            }
            
        case 1:
            
            
            // Data source label
            self.dataSourceLabel.fadeOut()
            
            // Table
            self.previousWinnersTableView.fadeOut(0.2, delay: 0) { f in
                
                // Remove Numbers Table
                self.previousWinnersTableView.removeFromSuperview()
                
                // Add Previous Numbers Table
                self.blurView.addSubview(self.myNumbersTableView)
                self.myNumbersTableView.fadeIn()
                
            }
            
        default:
            break;
        }
        
        // Dynamically change font color
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: self.backgroundColor], forState: .Selected)
        
    }
    
    
    
    
    // Share Button
    
    
    func toggleShareButton(){
        let bgColor = myNumberIsSelected ? UIColor.whiteColor().colorWithAlphaComponent(0.8) : UIColor.clearColor()
        let title = myNumberIsSelected ? "SHARE THESE NUMBERS" : "SHARE THE FUN"
        let titleColor = myNumberIsSelected ? self.backgroundColor : UIColor.whiteColor()
        let titleColorHighlighted = myNumberIsSelected ? self.backgroundColor.colorWithAlphaComponent(0.2) : UIColor.whiteColor().colorWithAlphaComponent(0.2)
        
        shareButton.backgroundColor = bgColor
        shareButton.setTitleColor(titleColor, forState: .Normal)
        shareButton.setTitleColor(titleColorHighlighted, forState: .Highlighted)
        shareButton.setTitle(title, forState: .Normal)
    }
    
    func showShareView() {
        
        let excludedActivityItems = [
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList
        ]
        
        let activityViewController = UIActivityViewController(activityItems: [self.textToShare as NSString], applicationActivities: nil)
        activityViewController.excludedActivityTypes = excludedActivityItems
        presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    

}


//
// UITableViewCell
//

class NumberCell: UITableViewCell {
    
    var numbers: String! {
        didSet {
            updateUI()
        }
    }
    
    var dates: NSDate! {
        didSet {
            updateDate()
        }
    }
    
    var datesLabel: UILabel!
    var numbersLabel: UILabel!
    var powerballLabel: UILabel!
    
    func updateUI() {
        
        if var numbers = numbers {
            
            let padding:CGFloat = 15
            let circleSize:CGFloat = 45
            
            // Numbers
            if (numbersLabel == nil) {
                
                self.shouldIndentWhileEditing = false
                
                let size = UIScreen.mainScreen().bounds
                
                contentView.backgroundColor = UIColor.clearColor()
                contentView.frame = CGRectMake(0, 0, size.width, 70)
                
                numbersLabel = UILabel()
                numbersLabel.font = UIFont(name: "GothamRounded-Bold", size: 14)
                numbersLabel.textAlignment = .Center
                numbersLabel.adjustsFontSizeToFitWidth = true
                numbersLabel.textColor = UIColor.whiteColor()
                numbersLabel.frame = CGRectMake(contentView.frame.width - padding * 2 - circleSize - 120, contentView.frame.height / 2 - 30, 120, 60)
                numbersLabel.backgroundColor = UIColor.clearColor()
                
                contentView.addSubview(numbersLabel)
                
            }
            
            
            
            // Powerball Label
            if (powerballLabel == nil) {
                powerballLabel = UILabel()
                powerballLabel.font = UIFont(name: "GothamRounded-Bold", size: 13)
                powerballLabel.textColor = UIColor.whiteColor()
                powerballLabel.textAlignment = .Center
                powerballLabel.frame = CGRectMake(numbersLabel.frame.maxX + padding, contentView.frame.height / 2 - circleSize / 2, circleSize, circleSize)
                powerballLabel.layer.cornerRadius = powerballLabel.frame.height / 2
                powerballLabel.layer.masksToBounds = true
                powerballLabel.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
                
                contentView.addSubview(powerballLabel)
            }
            
            
            //
            // Data
            //
            
            // Split off the last Powerball num
            let numberArray = numbers.characters.split{$0 == " "}.map(String.init)
            
            // Trim the string
            for var i = 0; i < 3; i++ {
                numbers.removeAtIndex(numbers.endIndex.predecessor())
            }
            
            // Join the string again with a larger space
            let numbersText = numberArray[0..<numberArray.count - 1].joinWithSeparator("   ")
            
            numbersLabel.text = numbersText
            powerballLabel.text = numberArray[5]
            
        }
        
    }
    
    func updateDate() {
        
        
        if let dates = self.dates {
            
            
            // Numbers
            if (datesLabel == nil) {
                
                let padding:CGFloat = 15
                
                datesLabel = UILabel()
                datesLabel.font = UIFont(name: "GothamRounded-Bold", size: 13)
                datesLabel.textAlignment = .Left
                datesLabel.adjustsFontSizeToFitWidth = true
                datesLabel.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
                datesLabel.frame = CGRectMake(padding, 0, contentView.frame.width / 2 - padding * 3, contentView.frame.height)
                datesLabel.backgroundColor = UIColor.clearColor()
                
                contentView.addSubview(datesLabel)
                
            }
            
            
            // Formatted date
            let formatter = NSDateFormatter()
            formatter.dateStyle = .MediumStyle
            datesLabel.text = formatter.stringFromDate(dates)
            
            
            
            
        }
        
    }
    
}


//
// EXTENSIONS
//

extension UIColor {
    static func randomColor() -> UIColor {
        let r = randomCGFloat()
        let g = randomCGFloat()
        let b = randomCGFloat()
        
        let red = max(r - 0.2, 0.0)
        let green = max(g - 0.2, 0.0)
        let blue = max(b - 0.2, 0.0)
        
        // If you wanted a random alpha, just create another
        // random number for that too.
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    class func randomCGFloat() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}


extension UIView {
    
    // Fade in
    
    func fadeIn(duration: NSTimeInterval = 0.3, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    // Fade out
    
    func fadeOut(duration: NSTimeInterval = 0.3, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void)? = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}
