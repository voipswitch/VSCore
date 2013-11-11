//
//  CommonDefines.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 01.10.2012.
//

#ifndef VSCore_CommonDefines_h
#define VSCore_CommonDefines_h

#define releaseAndNil(x) [x release]; x = nil

#define SafeFree(x) if(x!=0x0){ free(x); x = 0x0; }

#define SafeRelease(x) if(x!=nil){[x release]; x = nil; }

#define SafeCFRelease(x) if(x!=nil){CFRelease(x); x = nil;}
#define RGB(r,g,b,a)  [UIColor colorWithRed:(double)(r)/255.0f green:(double)(g)/255.0f blue:(double)(b)/255.0f alpha:(a)]

/*
 * hexadecimal format must be 0xTTRRGGBB where TT is transparency RR is red color GG is green color and BB is Blue color
 * for example black color in hexadecimal format is 0xff000000
*/
#define hexColor(color)  RGB((double)((color) >> 16 & 0xff), (double)((color) >> 8 & 0xff),(double)((color) & 0xff), (color) >> 24 & 0xff)

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

#define safeBlockRelease(a) if (a != nil){ Block_release(a); a = nil;}

#define safeBlockCopy(a, b) safeBlockRelease(a); a = Block_copy(b)

#endif
