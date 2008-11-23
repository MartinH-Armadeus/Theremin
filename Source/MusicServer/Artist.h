/*
 Copyright (C) 2006-2007  Patrik Weiskircher
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
 MA 02110-1301, USA.
 */

#import <Cocoa/Cocoa.h>

extern NSString *gUnknownArtistName;

#define TR_S_UNKNOWN_ARTIST	NSLocalizedString(@"Unknown Artist", @"Unknown Artist")

@interface Artist : NSObject {
	NSString *mName;
	int mSQLIdentifier;
}
- (id) init;
- (void) dealloc;

- (NSString *) description;

- (NSString *) name;
- (int) SQLIdentifier;
- (NSNumber *) CocoaSQLIdentifier;

- (void) setName:(NSString *)aName;
- (void) setSQLIdentifier:(int)aInteger;
@end
