# WKImageCache

### UPDATE: WKImageCache was originally written for watchOS 1.0. I'm no longer using it in any project, but will still accept pull requests for improvements.

For images you create in your WatchKit extension but use frequently, Apple recommends caching those images on the device and refer to them by name. There are some basic functions like **addCachedImage:name:** or **removeCachedImageWithName:** to manage this. This is nice, but you have to take care of removing old images to free up a full cache (about 5MB per app) all by yourself. 

The WKImageCache doesn't replace that cache, it's merely a simple wrapper that tries to solve this problem. If the user wants to add a new image and the cache is full, the WKImageCache automatically removes previous images based on currently two strategies, **FIFO** and **LRU**.

**Take a look at the Example project to see how to use it.**

# Requirements
WKImageCache requires iOS8.2 or above.

# Installation
Copy the **WKImageCache.swift** file to your Swift project and add it to your target. After that you need to (if not already exists) create a bridging header by choosing File > New > File > iOS > Source > Header File and name it *projectname-bridging-header.h*. Then add the following line and you're good to go:

```objective-c
#import <CommonCrypto/CommonCrypto.h>
```

# Usage
WKImageCache provides extensions for three interface types that currently support displaying images: *WKInterfaceImage*, *WKInterfaceButton* and *WKInterfaceGroup*.

For example, if you want to display an image (using the WKInterfaceImage) and cache it for later usage, you would use the following method:

```swift
interfaceImage.setCachedImage(image)
```

The image will be compressed, transmitted and added to the cache. If the image is already chached, this version will be used. There are additional (optional) parameters that you can use for adjusting the behaviour:

```swift
interfaceImage.setCachedImage(image, compression: 0.6, cacheType: .LRU)
```
* The compression (0.6 is default) is applied to the image before transmitting it. The lower the compression value, the faster the transmission.
* The default cache type is *FIFO*, which means that the oldest image in the cache will be removed if there's no space left. Alternatively, you can use *LRU*, which discards the least recently used images first. 

If the image is available as NSData, use this function:

```swift
interfaceImage.setCachedImageData(data)
```

The functions for WKInterfaceButton and WKInterfaceGroup are called 

- *setCachedBackgroundImage(image : UIImage)* 
- *setCachedBackgroundImageData(image : UIImage)* 

and work equally.

# License
WKImageCache is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/WKImageCache/releases).

# TODO
- Code Documentation