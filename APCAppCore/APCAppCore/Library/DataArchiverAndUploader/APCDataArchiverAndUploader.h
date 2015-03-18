//
//  APCDataArchiverAndUploader.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 If you think this class name is confusing, compared to
 other classes and functionality around the system,
 you're seeing the "truth" of it.  This class blends the
 features of several other classes in this project:  the
 APCDataArchiver in AppCore, the APHAirQualityDataModel
 in Asthma, and some other features from other uploaders
 around the AppCore.  Here's the history (as I see it),
 and the reason this new class exists:
 
 -  The AppCore DataArchiver was designed to create .zip
    files of Research Kit output.  It's been robustified,
    but stayed true to that need.  It did *not* address
    the need to upload data to Sage (probably because that
    need evolved independently).
 
 -  This meant that everyone that needs to upload anything
    does it in their own way.  They call the Archiver to
    .zip their stuff, and then ship it to Sage.
 
 -  The Asthma DataModel, a much more recent piece, combined
    pieces of all of that.  It used some evolving generalized
    pieces in the AppCore Archiver, and incorporated a
    streamlined version of uploader logic from other parts
    of the app.  It's also bound up (completely appropriately)
    with the needs of the Asthma app.
 
 -  This new class is being designed solely for the purpose
    of uploading one very specific chunk of data -- the
    output of the MedicationTracker.  However, since we can
    now see the above evolution, I think it makes sense to
    have a general-purpose archiver-and-uploader -- continuing
    the trend started by the Asthma Model class, and
    generalizing it further.
 
 So while I'll try hard NOT to overengineer this, I'll
 also try to keep it general enough that we can find 
 naturally-occurring subclass and superclass relationships
 among this new piece and the other pieces above.
 
 But I'm gonna start by literally copying-and-pasting
 the Asthma DataModel.  Thank you, Sir Programmer Dude
 Who Wrote And Refined That!  (We're supposed to take
 our names out of this code base, but, still -- credit
 where credit is due.  I happen to know 't'was a guy
 who wrote it.)
 */
@interface APCDataArchiverAndUploader : NSObject

+ (void) uploadOneDictionary: (NSDictionary *) dictionary;

@end
