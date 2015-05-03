# WKImageCache
For images you create in your WatchKit extension but use frequently, Apple recommends caching those images on the device and refer to them by name. There are some basic functions like **addCachedImage:name:** or **removeCachedImageWithName:** to manage this. This is nice, but you have to take care of removing old images to free up a full cache (about 5MB per app) all by yourself. 

The WKImageCache doesn't replace that cache, it's merely a wrapper that tries to solve this problem. If the user wants to add a new image and the cache is full, the WKImageCache automatically removes previous images based on currently two strategies, **FIFO** and **LRU**.

**Take a look at the Example project to see how to use it.**

# Requirements
WKImageCache requires iOS8.2 or above.

# Installation
Copy the **WKImageCache.swift** file to your Swift project and add it to your target. After that you need to (if not already exists) create a bridging header by choosing File > New > File > iOS > Source > Header File and name it *projectname-bridging-header.h*. Then add the following line and you're good to go:

```swift
#import <CommonCrypto/CommonCrypto.h>
```

# Usage



# License
WKImageCache is available under the MIT license. See the LICENSE file for more info.

# Recent Changes
The release notes can be found [here](https://github.com/mkoehnke/WKImageCache/releases).
