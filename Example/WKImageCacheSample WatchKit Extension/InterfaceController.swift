//
//  InterfaceController.swift
//  WKImageCacheSample WatchKit Extension
//
//  Created by Mathias Köhnke on 23/04/15.
//  Copyright (c) 2015 Mathias Koehnke. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var button1: WKInterfaceButton!
    @IBOutlet weak var button2: WKInterfaceButton!
    @IBOutlet weak var button3: WKInterfaceButton!
    @IBOutlet weak var button4: WKInterfaceButton!
    @IBOutlet weak var button5: WKInterfaceButton!
    @IBOutlet weak var button6: WKInterfaceButton!
    @IBOutlet weak var button7: WKInterfaceButton!
    @IBOutlet weak var button8: WKInterfaceButton!
    @IBOutlet weak var button9: WKInterfaceButton!
    @IBOutlet weak var label: WKInterfaceLabel!
    
    var caching : [WKInterfaceButton : String] = [WKInterfaceButton : String]()
    let pictureBaseName = "picture"
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        let debugCacheSize = NSProcessInfo.processInfo().environment["DEBUG_CACHE_SIZE"] as! String
        setTitle("Cache: \(debugCacheSize)")
    }
    
    override func willActivate() {
        super.willActivate()
        
        for (index, button) in enumerate(self.buttons()) {
            delay(Double(index) * 0.5) {
                let imageName = "\(self.pictureBaseName)\(index + 1)"
                let cacheKey = button.setCachedBackgroundImage(UIImage(named: imageName)!)
                self.caching[button] = cacheKey
                self.updateAppearance()
                
                if (index == self.buttons().count - 1) {
                    self.label.setHidden(true)
                }
            }
        }
    }

    func buttons() -> [WKInterfaceButton] {
        return [button1, button2, button3, button4, button5, button6, button7, button8, button9]
    }
    
    func updateAppearance() {
        let cachedImages = WKInterfaceButton.cachedImages()
        let keys = cachedImages.keys
        for (index, button) in enumerate(buttons()) {
            let key = self.caching[button]
            if let _key = key, val: AnyObject = cachedImages[_key] {
                button.setTitle("")
                button.setEnabled(false)
            } else {
                button.setTitle("+")
                button.setEnabled(true)
            }
        }
    }

    func buttonTapped(button : WKInterfaceButton) {
        label.setHidden(false)
        let index = find(self.buttons(), button)
        caching[button] = button.setCachedBackgroundImage(UIImage(named: "\(pictureBaseName)\(index! + 1)")!)
        updateAppearance()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.label.setHidden(true)
        })
    }
    
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    @IBAction func button1Tapped() { buttonTapped(button1) }
    @IBAction func button2Tapped() { buttonTapped(button2) }
    @IBAction func button3Tapped() { buttonTapped(button3) }
    @IBAction func button4Tapped() { buttonTapped(button4) }
    @IBAction func button5Tapped() { buttonTapped(button5) }
    @IBAction func button6Tapped() { buttonTapped(button6) }
    @IBAction func button7Tapped() { buttonTapped(button7) }
    @IBAction func button8Tapped() { buttonTapped(button8) }
    @IBAction func button9Tapped() { buttonTapped(button9) }
}
