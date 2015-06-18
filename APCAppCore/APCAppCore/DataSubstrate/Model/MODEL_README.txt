
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






