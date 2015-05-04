//
// InterfaceController.swift
//
// Copyright (c) 2015 Mathias Koehnke (http://www.mathiaskoehnke.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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
    
    var cacheKeys = [WKInterfaceButton : String]()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        setTitle("Cache: " + (NSProcessInfo.processInfo().environment["DEBUG_CACHE_SIZE"] as! String))
    }
    
    override func willActivate() {
        super.willActivate()
        for (index, button) in enumerate(self.buttons()) {
            delay(Double(index) * 0.5) {
                self.cacheKeys[button] = button.setCachedBackgroundImage(self.imageForIndex(index))
                self.updateAppearance()
                if (index == self.buttons().count - 1) {
                    self.label.setHidden(true)
                }
            }
        }
    }
    
    func updateAppearance() {
        let cachedImages = WKInterfaceButton.cachedImages()
        for (index, button) in enumerate(buttons()) {
            let key = self.cacheKeys[button]
            if let key = key, val: AnyObject = cachedImages[key] {
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
        cacheKeys[button] = button.setCachedBackgroundImage(imageForIndex(index!))
        updateAppearance()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.label.setHidden(true)
        })
    }
    
    func imageForIndex(index : Int) -> UIImage {
        let imageName = "picture" + String(index + 1)
        return UIImage(named: imageName)!
    }
    
    func buttons() -> [WKInterfaceButton] {
        return [button1, button2, button3, button4, button5, button6, button7, button8, button9]
    }
    
    private func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(delay * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), closure)
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
