MODEL_MIGRATION_README:  Notes on how to upgrade your CoreData model


----------
Copyright (c) 2015, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3.  Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
----------



We use CoreData "versioning."  This means we can change the data model at development time, and the CoreData infrastructure will try to upgrade the data on the user's device at run time.

This works "automatically" if your changes are very simple:  you add entities, or you add optional attributes to existing entities.

If you want to do anything more complex, you may need:
-   a "mapping model", telling CoreData what attributes to copy from the old entities to the new ones; and
-   a "migration policy," a class which computes the values of properties that can't be copied.

Here's how to do both the automatic and mapping-model-based conversions.


--------------
A. Add a new data model
--------------

For simple stuff, this is all you'll need.  For more complex stuff, you'll also need the stuff in section B.

Let's say we're on model version 4, and you're creating model version 5.

1.  Create the model file:
    a.  Click the model file for version 4 (APCModel 4.xcdatamodel)
    b.  Choose "Add Model Version" from Xcode's "Product" menu
    c.  Give the new model file an appropriate name, or accept the default (like "APCModel 5.xcdatamodel")

2.  Make it the "current" model:
    a.  Click the model container (APCModel.xcdatamodeld) in the Project view at left
    b.  In the File Inspector, set the "Model Version" to your new file ("APCModel 5")

3.  Start editing your model:
    a.  Click on your new model file ("APCModel 5.xcdatamodel")

4.  WATCH OUT FOR THIS XCODE BUG:

    Make sure you click on some file OTHER than the file you just created, and then click BACK to your new file, before editing it.

    Reason: Xcode seems to have a bug.  When you create the new model file, Xcode highlights it in the Project view, but DOES NOT CHANGE THE CONTENTS OF THE EDITOR WINDOW.  This makes it very easy to THINK you're editing your new file when you're actually changing the OLD file -- which really trashes everything about your data.




--------------
B. Add a custom migration for your data model
--------------

If you try to run the app with your new model, and you see some sort of "we can't upgrade your database" warning, your data probably requires a "migration policy."

For example, when I went from version 4 to version 5 (above), I created a new attribute called "uniqueId," and made it a "required" attribute.  When CoreData tried to migrate the old data, it didn't know how to generate that new uniqueId field.  (I wanted a UUID.)  So my migration failed.  The console log told me which fields it couldn't migrate.

So here's how I fixed it.  I learned this mostly from:

    http://9elements.com/io/index.php/customizing-core-data-migrations/
    https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmMappingOverview.html
    https://developer.apple.com/library/ios/documentation/Cocoa/Reference/NSMigrationManager_class/


Note:  before doing this, make sure YOU care about the things it's complaining about.  For example, for me, it once "complained" that it couldn't generate unique values for a certain string.  It was right:  I had made that string "required."  But that actually made me realize I wanted that string to be "optional."  I made that attribute optional, and presto, automatic conversion worked perfectly!



- - - - - - - -
Summary of what we're about to do
- - - - - - - -

1.  Create a Mapping Model which specifies how attributes from a version 4 file will be converted to (or invented for) a version 5 file (or whatever versions you're playing with).

2.  Create a class to do the calculations needed for that conversion.

3.  In that class, write one method for every attribute or relationship you need to create or convert.

4.  Tell the Mapping Model to use your new class.

5.  Tell the Mapping Model to use your new conversion method.

6.  Repeat steps 1-5 for every version of the model you might encounter.  For example, if your customers are using versions 1, 2, and 3 of your data model -- if you've released all those versions to the App Store -- and you're changing to version 5, you'll need to write Mapping Models converting EACH of those earlier versions to version 5.


- - - - - - - -
Details
- - - - - - - -

1.  Create a new Mapping Model:

    a.  Create a new Mapping Model file:  File > New > CoreData > MappingModel.
    b.  When it asks, tell it the version you're migrating from:  say, version 4.
    c.  When it asks, tell it the version you're migrating to:  say, version 5.
    d.  Save that file.  Name it after the versions you're mapping:  perhaps "APCMappingModel4ToModel5".  Use the default extension, ".xcmappingmodel".


2.  Inspect that file.  Here's what you'll see:

    a.  The file contains every entity, attribute, and relationship from version 4, and, by default, says to copy that data over to the same field or relationship in version 5.  THAT'S GREAT, and that's what we want.  The catch will be:  for NEW attributes and relationships, it won't know what values to give them.  And for attributes that have changed, its assumptions will be wrong.  So we'll write methods to generate, or fix, JUST THOSE ATTRIBUTES and relationships.  Leave everything else the way it is.

    b.  You might ask:  why can't I delete the entities, attributes, and relationships that I *don't* want it to convert, to make the file cleaner and simpler?  In theory, you can.  In practice, if any OTHER attributes relate to those, the automatic conversions may not do what you expect, or may not happen at all.  It's probably easier to just leave the file the way it is.


3.  Create a class to perform the "hard parts" of the migration:

    a.  Create a new class
    b.  Make it a subclass of NSEntityMigrationPolicy
    c.  Give it an appropriate name.  I called mine:

            APCDataMigrationPolicy_from_APCMedTrackerPrescription_v4_to_APCMedTrackerPrescription_v5

            (meaning:  "a bunch of methods for converting Prescription v4 objects to Prescription v5")


4.  In that class, write a method to generate the new attribute (or relationship) from the old one, or from the old object.  Presume you'll receive a pointer to the old object, and will return the value of the new attribute/relationship.  I'll show you how to send those values in a moment.  For example, if you're generating a new Color field, you might make a method called

            - (UIColor *) generateNewColorFromOldPrescription: (id) prescriptionFromModel4
            {
                // read the properties of the old object
                // generate the new color
                // return the new color
            }


5.  Tell the mapping model to use your new class:

    a.  Click the Mapping Model file.
    b.  In the list of entities, click the entity you're about to convert.
    c.  In the data inspector (command-option-3), enter your new class as the "custom policy."

        (This shows us why this class is called a "policy."  Your "policy" class is a physical embodiment of a set of principles and rules for converting something into something else.  The migration manager will instantiate one of these rule-beasties so that it (the manager) can follow those rules.)


6.  Tell the mapping model to use your new method:

    a.  Click the attribute or relationship you need to edit.

    b.  In its "value" field, you WANT to call the conversion method you wrote in step 4.  That method is a method of your Policy subclass, so the migration manager will execute a line of code like this:

            newColor = [yourMigrationPolicyObject getColorFromPrescription: myPrescription
                                                                 usingDate: myPrescription.startDate
                                                                  andColor: myPrescription.color];

        To make it do that, enter an expression like this in the "value" field:

            FUNCTION ($entityPolicy, "getColorFromPrescription:usingDate:andColor:", $source, $source.startDate, $source.color)

        From left to right, those two lines contain the same pieces:

            yourMigrationPolicyObject       = $entityPolicy
            <method name>                   = method name, wrapped in C-style quotation marks
            myPrescription                  = $source
            myPrescription.startDate        = $source.startDate
            myPrescription.color            = $source.color
        
        Those magic variables are:

            $entityPolicy           a magically-created instance of your converter class from step 3
            $source                 a pointer to the object being converted (for me, a Prescription)
            $source.<attribute>     a named attribute of $source, or a method call (i.e., a keypath)

        Here are some other magic variables:

            $destination            the object that $source is being converted into
            $manager                the object doing the conversion.  This is a gem:  it lets you
                                    access the ManagedObjectContexts being used to read the old
                                    objects and generate the new ones, which means you can run
                                    FetchRequests to inspect and generate data on either side
                                    of the conversion.


7.  Repeat steps 4 and 6 for every field or relationship you need to create or convert.

8.  Repeat steps 1-7 for EVERY VERSION of your data that you're likely to encounter.



For more information, I used these sources:
    http://9elements.com/io/index.php/customizing-core-data-migrations/
    https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreDataVersioning/Articles/vmMappingOverview.html
    https://developer.apple.com/library/ios/documentation/Cocoa/Reference/NSMigrationManager_class/


Have fun, and good luck!
