VSCore
======

Core utility classes and common code library

3rd party parts.
================

In VSCore we use following 3rd party frameworks/libs:
* ASIHttpRequest (http://allseeing-i.com/ASIHTTPRequest)
* CocoaAsyncSocket (https://github.com/robbiehanson/CocoaAsyncSocket)
* CocoaLumberjack (https://github.com/robbiehanson/CocoaLumberjack)
* JSONKit (https://github.com/johnezang/JSONKit)
* KissXML (https://github.com/robbiehanson/KissXML)
* MiniZip & ZLib (http://www.winimage.com/zLibDll/minizip.html)
* Objective-Zip (https://github.com/flyingdolphinstudio/Objective-Zip)
* Reachability (http://developer.apple.com/library/ios/#samplecode/Reachability/Introduction/Intro.html)

Make sure you add dependencies / libraries required by this parts.

Installation & dependencies
===========================

VSCore compiles into framework which should be put into your project. You need also following project dependencies to make linker happy:
* MobileCoreServices.framework
* CFNetwork.framework
* SystemConfiguration.framework
* Security.framework
* libsqlite3.dylib

This document is still under work, it will be upgraded in near future. Feel free to contact us if you need some more clarifications in any parts.
