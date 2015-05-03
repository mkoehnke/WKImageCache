//
// WKImageCache.swift
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
import Darwin

public enum CacheType {
    case FIFO
    case LRU
}

private let DefaultCacheType : CacheType = .FIFO

public extension WKInterfaceImage {
    public func setCachedImage(image : UIImage, compression : CGFloat = 0.6, cacheType : CacheType = DefaultCacheType) -> String {
        return setCachedImageData(UIImageJPEGRepresentation(image, compression), cacheType: cacheType)
    }
    
    public func setCachedImageData(imageData : NSData, cacheType : CacheType = DefaultCacheType) -> String {
        return ImageCache.setCachedImageData(imageData, cacheType: cacheType, cachedBlock: { (key) -> Void in
            self.setImageNamed(key)
        })
    }
    
    public class func cachedImages() -> [NSObject : AnyObject] {
        return WKInterfaceDevice.currentDevice().cachedImages
    }
}


public extension WKInterfaceButton {
    
    public func setCachedBackgroundImage(image : UIImage, compression : CGFloat = 0.6, cacheType : CacheType = DefaultCacheType) -> String {
        return setCachedBackgroundImageData(UIImageJPEGRepresentation(image, compression), cacheType: cacheType)
    }
    
    public func setCachedBackgroundImageData(imageData : NSData, cacheType : CacheType = DefaultCacheType) -> String {
        return ImageCache.setCachedImageData(imageData, cacheType: cacheType, cachedBlock: { (key) -> Void in
            self.setBackgroundImageNamed(key)
        })
    }
    
    public class func cachedImages() -> [NSObject : AnyObject] {
        return WKInterfaceDevice.currentDevice().cachedImages
    }
}

private class ImageCache {
    
    private class func setCachedImageData(imageData : NSData, cacheType : CacheType, cachedBlock: (key : String) -> Void) -> String {
        ImageCache.cacheType = cacheType
        
        let imageKey = imageData.MD5() as String
        if (ImageCache.imageExists(imageKey)) {
            cachedBlock(key : imageKey)
            if (ImageCache.cacheType == .LRU) {
                ImageCache.addTimeStamp(NSDate().timeIntervalSinceReferenceDate, key: imageKey)
            }
        } else {
            ImageCache.addCachedImageWithData(imageData, key: imageKey)
            cachedBlock(key : imageKey)
        }
        return imageKey
    }
    
    private class func imageExists(name : String) -> Bool {
        var exists: Bool = false
        dispatch_sync(lockQueue) {
            exists = WKInterfaceDevice.currentDevice().cachedImages[name] != nil
        }
        return exists
    }

    private class func addTimeStamp(timestamp : NSTimeInterval, key : String) {
        getTimeStamps().setObject(timestamp, forKey: key)
        NSUserDefaults.standardUserDefaults().setObject(getTimeStamps(), forKey: cacheKey)
    }
    
    private class func removeTimeStamp(key : String) {
        getTimeStamps().removeObjectForKey(key)
        NSUserDefaults.standardUserDefaults().setObject(getTimeStamps(), forKey: cacheKey)
    }

    private class func addCachedImageWithData(data : NSData, key : String) {
        dispatch_sync(lockQueue) {
            var success = false
            do {
                let debugCacheSize = NSProcessInfo.processInfo().environment["DEBUG_CACHE_SIZE"] as? String
                let cachedImages = WKInterfaceDevice.currentDevice().cachedImages
                if let _debugCacheSize = debugCacheSize where cachedImages.count >= _debugCacheSize.toInt() {
                    self.DLog("Hit debug size")
                    success = false
                } else {
                    self.DLog("Adding \(key) to cache")
                    success = WKInterfaceDevice.currentDevice().addCachedImageWithData(data, name: key)
                }
                
                if (success == false) {
                    self.removeImageWithCacheStrategy(self.cacheType)
                    
                    // There seems to be a race condition in the WatchKit cache during bulk adding/removing images
                    // especially with the same name. Therefore this delay as a workaround.
                    usleep(400000)
                }
            } while (success == false)
            self.addTimeStamp(NSDate().timeIntervalSinceReferenceDate, key: key)
        }
    }
    
    private class func removeCachedImage(key : String) {
        removeTimeStamp(key)
        WKInterfaceDevice.currentDevice().removeCachedImageWithName(key)
    }
    
    private class func removeImageWithCacheStrategy(cacheType : CacheType) {
        if contains([.FIFO, .LRU], cacheType) {
            var imageName : String?
            var imageTimeStamp : NSTimeInterval = 0.0
            for (key, timestamp) in getTimeStamps() {
                if (imageTimeStamp == 0.0 || imageTimeStamp > timestamp.doubleValue) {
                    imageName = key as? String
                    imageTimeStamp = timestamp.doubleValue
                }
            }
            if let _imageName = imageName {
                DLog("Removing cached image with key \(_imageName)")
                removeCachedImage(_imageName)
            } else {
                DLog("No image found to remove. Clearing cache to avoid inconsistency ...");
                getTimeStamps().removeAllObjects()
                NSUserDefaults.standardUserDefaults().setObject(getTimeStamps(), forKey: cacheKey)
                WKInterfaceDevice.currentDevice().removeAllCachedImages()
            }
        }
    }
    
    private static var cacheType : CacheType = DefaultCacheType
    private static let cacheKey = "com.mathiaskoehnke.wkimagecache"
    private static let lockQueue = dispatch_queue_create(cacheKey, nil)
    private static var timeStamps : NSMutableDictionary?
    
    private class func getTimeStamps() -> NSMutableDictionary {
        if let _timeStamps = timeStamps {
            return _timeStamps
        }
        
        var defaults = NSUserDefaults.standardUserDefaults()
        timeStamps = defaults.objectForKey(cacheKey) as? NSMutableDictionary
        if let _timeStamps = timeStamps {
            return _timeStamps
        }
        
        timeStamps = NSMutableDictionary()
        return timeStamps!
    }
    
    private class func DLog(message: String, function: String = __FUNCTION__) {
        #if DEBUG
            println("\(function): \(message)")
        #endif
    }
}

private extension NSData {
    func MD5() -> NSString {
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let md5Buffer = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLength)
        
        CC_MD5(bytes, CC_LONG(length), md5Buffer)
        var output = NSMutableString(capacity: Int(CC_MD5_DIGEST_LENGTH * 2))
        for i in 0..<digestLength {
            output.appendFormat("%02x", md5Buffer[i])
        }
        
        return NSString(format: output)
    }
}