//
//  CommonDefines.h
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Bartłomiej Żarnowski on 01.10.2012.
//

#ifndef TheTostersCore_CommonDefines_h
#define TheTostersCore_CommonDefines_h

#define releaseAndNil(x) [x release]; x = nil

#define SafeFree(x) if(x!=0x0){ free(x); x = 0x0; }

#define SafeRelease(x) if(x!=nil){[x release]; x = nil; }

#define SafeCFRelease(x) if(x!=nil){CFRelease(x); x = nil;}

#define RGB(r,g,b,a)  [UIColor colorWithRed:(double)r/255.0f green:(double)g/255.0f blue:(double)b/255.0f alpha:a]

#endif
