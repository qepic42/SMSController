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
		
		[self motionLog:@"fail"];
		
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

-(void)speekText:(NSString *)text{
	
	NSSpeechSynthesizer *syn = [[NSSpeechSynthesizer alloc] init];
	NSString *voiceID = [[NSSpeechSynthesizer availableVoices] objectAtIndex:20];
    [syn setVoice:voiceID];
	
	[syn startSpeakingString:text];
	[syn release];
	
}

// Start or stop calculating
-(IBAction)pushEnter:(id)sender{
	
	if ([[enterButton title]isEqualToString:@"Stop"]) {
		[enterButton setTitle:@"Start"];
		self.mode = 0;
		
	//	[self speekText:@"stop sudden motion observer"];
		
		[self cleanDisplay];
	}else if([[enterButton title]isEqualToString:@"Start"]){
		[enterButton setTitle:@"Stop"];
		self.mode = 1;
		
		[self speekText:@"start sudden motion observer"];
		
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
	xValue = (xValue - 0.1);
	zValue = (zValue - 1.04);
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
	
	//Values für resultMotion
	/*
	 rmx
	 rmy
	 rmz
	 */
	// Try some calculations
	self.resultMotion = ((xValue + yValue + zValue)*10);
	//NSLog(@"Result: %f",resultMotion);
	
	// Set the result to the indicator
	[smsIndicator setDoubleValue:self.resultMotion];
	[self securityStuff];
	[self logMovement];
}

-(void)securityStuff{
	if ([smsSound state] == NSOnState ){ 
		NSSound *warningSound = [NSSound soundNamed:@"SMSControllerSoundWarning"];
		NSSound *alarmSound = [NSSound soundNamed:@"SMSControllerSoundAlarm"];
		
		if (self.resultMotion >= 2 && self.resultMotion <= 3) {
			//NSLog(@"Warning");
			if ([warningSound isPlaying] == YES ||[alarmSound isPlaying] == YES) {
			}else {
				[self speekText:@"warning"];
				[warningSound play];
			}
		}else if (self.resultMotion >= 3) {
			//NSLog(@"ALARM");
			if ([warningSound isPlaying] == YES ||[alarmSound isPlaying] == YES) {
			}else {
				[self speekText:@"alarm"];
				[alarmSound play];
			}
		}
		
	}

	
}

-(void)logMovement{
	if ([smsLog state] == NSOnState ){
		[self motionLog:[NSString stringWithFormat:@"%@: %f",@"total movement",self.resultMotion]];
	}
}

// Make a loop to get the SMS data
-(void)loopData{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	SMSTester *smsTester = [[[SMSTester alloc]init]autorelease];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	
	while (self.mode == 1) {
		[center postNotificationName:@"sendData" object:nil userInfo:nil];
		[NSThread sleepForTimeInterval:0.1];
	}
	
	[pool release];
}

-(NSString *)logDate{
	NSDate *now = [NSDate date];
	return [NSString stringWithFormat:@"%@",now];
}

-(void)motionLog:(NSString *)text{
	
	NSString *homeDir = NSHomeDirectory();
    NSString* fullPath = [homeDir stringByAppendingPathComponent:@"/Library/Logs/MovementSecurity	.log"];
	
	NSString *oldContent = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
	
	if (oldContent == nil) {
		[[NSFileManager defaultManager] createFileAtPath:fullPath contents:nil attributes:nil];
		NSLog(@"Logfile created");
		NSString *new = [NSString stringWithFormat:@"%@: %@",[self logDate],text];
		[new writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}else {
		NSString *new = [NSString stringWithFormat:@"%@: %@",[self logDate],text];
		
		NSString *content = [NSString stringWithFormat:@"%@\n%@",oldContent,new];
		
		[content writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
	
}

// Clean display by pressing 'stop'
-(void)cleanDisplay{
	[xField setStringValue:@""];
	[yField setStringValue:@""];
	[zField setStringValue:@""];
	[smsIndicator setDoubleValue:0];
}

@end
