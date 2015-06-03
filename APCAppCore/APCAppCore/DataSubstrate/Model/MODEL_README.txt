MODEL_README:  Notes on how to use our CoreData infrastructure


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



CORE DATA NOTES
---------------

1) Datasubstrate has two managed object contexts: mainContext & persistentContext.

2) mainContext should be used ONLY by viewControllers and view related classes. mainContext is a child context of persistentContext.

3) persistentContext has the associated persistentStore. Please DO NOT do any blocking activities in this context. For doing work in the background, create a local child context of the persistentContext . Use the below code sample to create a local child context.

    NSMananagedObjectContext * localContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    localContext.parentContext = <dataSubstrate>.persistentContext;

4) When you are not on mainContext, you should ALWAYS do CRUD (Create, Read, Update, Delete) operations in `performBlock` or `performBlockAndWait` methods. Code snippet:

    [localContext performBlockAndWait:^{
        < CRUD code here >
    }];

5) For creating new managed objects use `newObjectForContext:` category method. DO NOT use alloc init. Code sample:

    APCTask * task = [APCTask newObjectForContext:context];

6) For saving managed objects, use `saveToPersistentStore:` category method.

    NSError * error;
    [<instance of managed object> saveToPersistentStore:&error];

7) For reading managed objects from core data use `request` category method and set appropriate NSPredicates and NSSortDescriptors. Code sample:

    NSFetchRequest * request = [APCTask request];
    request.predicate = [NSPredicate predicateWithFormat:@"uid == %@",taskID];
    NSError * error;
    NSArray * managedObjects = [<appropriate context> executeFetchRequest:request error:&error];






