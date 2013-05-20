//
//  Device.m
//  VSCore, (C) VoipSwitch
//
//  This file is part of VSCore, which is distributed under BSD-new license.
//  Created by Andrzej Górski on 12/17/10.
//

#import "UIDevice+machine.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice(machine)

- (NSString *)machine
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *name = malloc(size);
	sysctlbyname("hw.machine", name, &size, NULL, 0);
	NSString *machine = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
	free(name);
	return machine;
}
@end