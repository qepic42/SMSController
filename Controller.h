//
//  Controller.h
//  smslib
//
//  Created by Jan Galler on 20.02.11.
//  Copyright 2011 PQ-Developing.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SMSTester;
@interface Controller : NSObject {
	IBOutlet id xField;
	IBOutlet id yField;
	IBOutlet id zField;
	IBOutlet id enterButton;
	IBOutlet id smsIndicator;
	IBOutlet id smsWindow;
	IBOutlet id smsSound;
	
	SMSTester *smsTester;
	int mode;
	double resultMotion;
}

@property()int mode;
@property()double resultMotion;

-(IBAction)pushEnter:(id)sender;
-(void)setFloatValues:(NSNotification *)notification;
-(void)loopData;
-(void)cleanDisplay;
-(void)securityStuff;
-(void)speekText:(NSString *)text;

@end
