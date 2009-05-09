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
#import <Sparkle/SUUpdater.h>
#import "Profile.h"

typedef enum {
	UpdateIntervalOnceADay = 1,
	UpdateIntervalOnceAWeek = 2,
	UpdateIntervalOnlyAtStartup = 3,
	UpdateIntervalNever = 4
} PWPreferencesUpdateInterval;

typedef enum {
	CoverArtProviderAmazonDe = 0,
	CoverArtProviderAmazonFr = 1,
	CoverArtProviderAmazonJp = 2,
	CoverArtProviderAmazonUk = 3,
	CoverArtProviderAmazonUs = 4
} PWPreferencesCoverArtProvider;

typedef enum {
	eAppleRemoteModeAlways		= 0,
	eAppleRemoteModeWhenFocused = 1,
	eAppleRemoteModeNever		= 2
} AppleRemoteMode;

typedef enum {
	eLibraryDoubleClickReplaces = 0,
	eLibraryDoubleClickAppends = 1,
} LibraryDoubleClickMode;

extern NSString *nCoverArtLocaleChanged;
extern NSString *nCoverArtEnabledChanged;

@interface PreferencesController : NSObject {	
	SUUpdater *mUpdater;
	
	Profile *_currentProfile;
}

- (id) initWithSparkleUpdater:(SUUpdater *)aSparkleUpdater;

- (Profile *) currentProfile;
- (void) setCurrentProfile:(Profile *)aProfile;
- (void) importOldSettings;
- (void) save;

// settings getters ( / setters )

- (PWPreferencesCoverArtProvider) coverArtProvider;
- (void) setCoverArtProvider:(PWPreferencesCoverArtProvider) aCoverArtProvider;

- (PWPreferencesUpdateInterval) updateInterval;
- (void) setUpdateInterval:(PWPreferencesUpdateInterval) aUpdateInterval;

- (void) setNoConfirmationNeededForDeletionOfPlaylist:(BOOL)aValue;
- (BOOL) noConfirmationNeededForDeletionOfPlaylist;

- (NSString *) coverArtLocale;

- (LibraryDoubleClickMode) libraryDoubleClickAction;

- (BOOL) coverArtEnabled;
- (void) setCoverArtEnabled:(BOOL)aValue;

- (BOOL) askedAboutCoverArt;
- (void) setAskedAboutCoverArt;

- (BOOL) pauseOnSleep;

- (NSString *) currentServerNameWithPort;

- (AppleRemoteMode) appleRemoteMode;

- (void) setPlaylistDrawerOpen:(BOOL)theValue;
- (BOOL) playlistDrawerOpen;

- (void) setPlaylistDrawerWidth:(float)theSize;
- (float) playlistDrawerWidth;

- (BOOL) showGenreInLibrary;
- (void) setShowGenreInLibrary:(BOOL)aValue;

@end