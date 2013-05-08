//
//  DDXMLElement+Helper.m
//  Vippie
//
//  Created by ichi on 12-07-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DDXMLElement+Helper.h"

@implementation DDXMLElement (Helper)

-(DDXMLElement *)nodeForXPath:(NSString *)path
{
	DDXMLElement *tempElement = self;
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"" options:0 range:NSMakeRange(0,1)];
	NSArray *array = [path componentsSeparatedByString:@"/"];
	for(NSString *name in array)
	{
		NSArray *tempElementsArray = [tempElement elementsForName:name];
		if([tempElementsArray count] > 0)
		{
			tempElement = [tempElementsArray objectAtIndex:0];
		}
		else
		{
			return nil;
		}
	}
	return tempElement;
}

@end
