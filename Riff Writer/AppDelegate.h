//
//  AppDelegate.h
//  Riff Writer
//
//  Created by Isaac Brown on 2/26/20.
//  Copyright © 2020 Isaac Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel* managedObjectModel;

-(NSURL*)applicationDocumentsDirectory;

@end

