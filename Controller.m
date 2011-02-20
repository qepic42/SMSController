//
//  Controller.m
//  smslib
//
//  Created by Jan Galler on 20.02.11.
//  Copyright 2011 PQ-Developing.com. All rights reserved.
//

#import "Controller.h"

@implementation Controller
@synthesize mode, resultMotion;

- (id) init
{
	self = [super init];
	if (self != nil) {
	
		
		// 0: Start-mode
		// 1: Stop-mode
		self.mode = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setFloatValues:)
													 name:@"setValues"
												   object:nil];
	}
	return self;
}

- (void)windowWillClose:(NSNotification *)aNotification {
	[NSApp terminate:self];
}

-(void)awakeFromNib{
	[smsWindow center];
	[smsWindow setDelegate:self];
}

// Start or stop calculating
-(IBAction)pushEnter:(id)sender{
	
	if ([[enterButton title]isEqualToString:@"Stop"]) {
		[enterButton setTitle:@"Start"];
		self.mode = 0;
		[self cleanDisplay];
	}else if([[enterButton title]isEqualToString:@"Start"]){
		[enterButton setTitle:@"Stop"];
		self.mode = 1;
		[self performSelectorInBackground:@selector(loopData) withObject:nil];
	}

}

// Set values to interface
-(void)setFloatValues:(NSNotification *)notification{
	
	// Get data
	double xValue = [[[notification userInfo]objectForKey:@"xValue"]floatValue];
	double yValue = [[[notification userInfo]objectForKey:@"yValue"]floatValue];
	double zValue = [[[notification userInfo]objectForKey:@"zValue"]floatValue];
	
	// Make them positiv
	xValue = sqrt(pow(xValue, 2));
	yValue = sqrt(pow(yValue, 2));
	zValue = sqrt(pow(zValue, 2));
	
	// Set values to the interface
	[xField setStringValue:[NSString stringWithFormat:@"%f",xValue]];
	[yField setStringValue:[NSString stringWithFormat:@"%f",yValue]];
	[zField setStringValue:[NSString stringWithFormat:@"%f",zValue]];

	/*
	NSLog(@"|X|:%f",xValue);
	NSLog(@"|Y|:%f",yValue);
	NSLog(@"|Z|:%f",zValue);
	*/
	 
	// Try some calculations
	resultMotion = xValue + yValue + zValue;
//	NSLog(@"Result: %f",resultMotion);
	
	// Set the result to the indicator
	[smsIndicator setDoubleValue:resultMotion];
}

// Make a loop to get the SMS data
-(void)loopData{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	SMSTester *smsTester = [[SMSTester alloc]init];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	while (self.mode == 1) {
		[center postNotificationName:@"sendData" object:nil userInfo:nil];
		[NSThread sleepForTimeInterval:0.1];
	}
	
	[pool release];
}

// Clean display by pressing 'stop'
-(void)cleanDisplay{
	[xField setStringValue:@""];
	[yField setStringValue:@""];
	[zField setStringValue:@""];
	[smsIndicator setDoubleValue:0];
}

@end
