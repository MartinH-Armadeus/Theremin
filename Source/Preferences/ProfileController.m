//
//  ProfileController.m
//  Theremin
//
//  Created by Patrik Weiskircher on 13.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ProfileController.h"
#import "PreferencesController.h"
#import "Profile.h"

#import "ImageTextCell.h"

const NSString *newProfileNameTemplate = @"Profile %d";
const NSString *cProfilesUserDefaultsPath = @"cProfilesUserDefaultsPath";

const NSString *nProfileControllerUpdatedProfiles = @"nProfileControllerUpdatedProfiles";

@interface ProfileController (PrivateMethods)
- (NSString *) newProfileName;
- (BOOL) profileNameIsUnique:(NSString *)aProfileName;

- (void) saveUIToProfile:(Profile *)aProfile;
- (void) loadProfileToUI:(Profile *)aProfile;
- (void) enableUIs:(BOOL)aValue;
- (void) loadPortToUI:(int)port usingMode:(ProfileMode)mode;

- (Profile *) selectedProfile;

- (ProfileMode) profileModeFromType;
@end

@implementation ProfileController
- (void) dealloc
{
	[_lastProfile release];
	[super dealloc];
}

- (void) enableUIs:(BOOL)aValue {
	[_description setEnabled:aValue];
	[_type setEnabled:aValue];
	[_hostname setEnabled:aValue];
	[_port setEnabled:aValue];
	[_password setEnabled:aValue];
	[_autoreconnect setEnabled:aValue];
}

- (void) saveUIToProfile:(Profile *)aProfile {
	[aProfile setDescription:[_description stringValue]];
	[aProfile setMode:[self profileModeFromType]];
	[aProfile setHostname:[_hostname stringValue]];
	[aProfile setPort:[_port intValue]];
	[aProfile setPassword:[_password stringValue]];
	[aProfile setAutoreconnect:[_autoreconnect state] == NSOnState];
	
	if ([aProfile mode] == eModeSqueezeCenter)
		[aProfile setUser:[_user stringValue]];
}

- (void) loadProfileToUI:(Profile *)aProfile {
	if ([aProfile description])
		[_description setStringValue:[aProfile description]];
	else
		[_description setStringValue:@""];
	
	[_type selectItemWithTag:[aProfile mode] == eModeMPD ? 0 : 1];
	
	if ([aProfile hostname])
		[_hostname setStringValue:[aProfile hostname]];
	else
		[_hostname setStringValue:@""];
	
	[self loadPortToUI:[aProfile port] usingMode:[aProfile mode]];
	
	if ([aProfile password])
		[_password setStringValue:[aProfile password]];
	else
		[_password setStringValue:@""];
	
	[_autoreconnect setState:[aProfile autoreconnect] ? NSOnState : NSOffState];

	[_user setEnabled:[aProfile mode] == eModeSqueezeCenter];
	if ([aProfile mode] == eModeSqueezeCenter && [aProfile user] != nil)
		[_user setStringValue:[aProfile user]];
	else
		[_user setStringValue:@""];
}

- (void) loadPortToUI:(int)port usingMode:(ProfileMode)mode {
	if (port == -1) {
		if (mode == eModeMPD)
			port = 6600;
		else if (mode == eModeSqueezeCenter)
			port = 9090;
	}
	
	[_port setStringValue:[NSString stringWithFormat:@"%d", port]];	
}

- (IBAction) typeChanged:(id)sender {
	[self loadPortToUI:[[self selectedProfile] port] usingMode:[self profileModeFromType]];
}

- (id) initWithCoder:(id)coder {
	self = [super initWithCoder:coder];
	[self setContent:[self profiles]];
	return self;
}

- (void) awakeFromNib {
	ImageTextCell *cell = [[[ImageTextCell alloc] init] autorelease];
	[cell setDataDelegate:self];
	[[[_tableView tableColumns] objectAtIndex:0] setDataCell:cell];
}

- (id) newObject {
	Profile *profile = [[Profile alloc] initWithDescription:[self newProfileName]];
	if ([[self content] count] == 0)
		[profile setDefault:YES];
	return profile;
}

- (NSString *) newProfileName {
	NSString *profile;
	int count = 1;
	
	do {
		profile = [NSString stringWithFormat:(NSString *)newProfileNameTemplate, count];
		count++;
	} while (![self profileNameIsUnique:profile]);
	
	return profile;
}

- (BOOL) profileNameIsUnique:(NSString *)aProfileName {
	NSArray *profiles = [self content];
	for (int i = 0; i < [profiles count]; i++)
		if ([[[profiles objectAtIndex:i] description] isEqualToString:aProfileName])
			return NO;
	return YES;
}


- (NSArray *) profiles {
	NSArray *data = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)cProfilesUserDefaultsPath];
	NSMutableArray *profiles = [NSMutableArray array];
	for (int i = 0; i < [data count]; i++)
		[profiles addObject:[Profile fromUserDefaults:[data objectAtIndex:i]]];
	return profiles;
}

- (Profile *) defaultProfile {
	for (int i = 0; i < [[self content] count]; i++)
		if ([[[self content] objectAtIndex:i] default])
			return [[self content] objectAtIndex:i];
	
	if ([[self content] count] > 0)
		return [[self content] objectAtIndex:0];
			
	return nil;
}

- (void) saveProfiles {
	if ([self selectedProfile])
		[self saveUIToProfile:[self selectedProfile]];
	
	NSArray *someProfiles = [self content];
	NSMutableArray *profiles = [NSMutableArray array];
	
	for (int i = 0; i < [someProfiles count]; i++) {
		@try {
			[[someProfiles objectAtIndex:i] savePassword];			
		} @catch (ProfilePasswordSavingException *exception) {
			[[NSAlert alertWithMessageText:@"Could not save password."
							 defaultButton:@"OK"
						   alternateButton:nil
							   otherButton:nil
				 informativeTextWithFormat:@"Please set at least a hostname or a description before setting a password."] runModal];
		}
		
		[profiles addObject:[[someProfiles objectAtIndex:i] toUserDefaults]];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:profiles forKey:(NSString *)cProfilesUserDefaultsPath];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)nProfileControllerUpdatedProfiles object:self];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	if (_lastProfile != nil)
		[self saveUIToProfile:_lastProfile];
	
	[self enableUIs:YES];
	
	Profile *profile = [self selectedProfile];
	[self loadProfileToUI:profile];
	
	[_lastProfile release];
	_lastProfile = [profile retain];
	
	[_defaultButton setEnabled:![self currentSelectionIsDefault]];
}

- (Profile *) selectedProfile {
	if ([_tableView selectedRow] == -1)
		return nil;
	return [[self content] objectAtIndex:[_tableView selectedRow]];	
}

- (ProfileMode) profileModeFromType {
	return [[_type selectedItem] tag] == 0 ? eModeMPD : eModeSqueezeCenter;
}

- (IBAction) setCurrentSelectionAsDefault:(id)sender {
	Profile *profile = [self selectedProfile];
	
	[[self defaultProfile] setDefault:NO];
	[profile setDefault:YES];
	
	[_defaultButton setEnabled:NO];
}

- (BOOL) currentSelectionIsDefault {
	return [[self selectedProfile] default];
}

- (BOOL) canRemove {
	if ([[self content] count] == 1)
		return NO;
	return [super canRemove];
}

- (IBAction) removeCurrentlySelectedProfile:(id)sender {
	[self removeObject:[self selectedProfile]];
	[self tableViewSelectionDidChange:nil];
}

- (NSImage*) iconForCell: (ImageTextCell*) cell data: (NSObject*) data {
	return nil;
}
- (NSString*) primaryTextForCell: (ImageTextCell*) cell data: (NSObject*) data {
	return [data description];
}

- (NSString*) secondaryTextForCell: (ImageTextCell*) cell data: (NSObject*) data {
	Profile *profile = (Profile *)data;
	NSString *mode = [profile mode] == eModeMPD ? @"MPD" : @"SqueezeCenter";
	if ([profile default])
		return [NSString stringWithFormat:@"%@ (Default)", mode];
	return mode;
}
@end
