//
//  FlickrPhotoCache.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/8/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "FlickrPhotoCache.h"

@interface FlickrPhotoCache()
@property (strong, nonatomic) NSMutableDictionary *cache;
@property (nonatomic, strong) NSString *cacheDir;
@property (nonatomic) NSUInteger cacheSize;
@end

#define MAX_CACHE_SIZE 10485760

@implementation FlickrPhotoCache
@synthesize cache = _cache;
@synthesize cacheSize = _cacheSize;
@synthesize cacheDir = _cacheDir;

static FlickrPhotoCache *instance;

- (NSString *)cacheDir
{
    // Set the cache directory
    if (_cacheDir == nil) {
        _cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Photos"];
    }
    return _cacheDir;
}

- (NSDictionary *)cache
{
    // Lazily instantiate the mutable dictionary
    if (_cache == nil) {
        _cache = [[NSMutableDictionary alloc]init];
    }
    return _cache;
}

- (NSUInteger)cacheSize
{
    // Add up the sizes of the files in the cache directory
    if (_cacheSize == 0) {
        NSError *error;
        NSArray *cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDir error:&error];
        if (error == nil) {
            for (NSString *file in cacheContents) {
                NSDictionary *attributes = [[NSFileManager defaultManager]attributesOfItemAtPath:[self.cacheDir stringByAppendingPathComponent:file] error:&error];
                _cacheSize += [[attributes objectForKey:NSFileSize] integerValue];
            }
        }
    }
    return _cacheSize;
}

- (id)init
{
    self = [super init];
    
    BOOL cacheDirPresent = [[NSFileManager defaultManager] fileExistsAtPath:self.cacheDir];
    NSError *error;
    if (cacheDirPresent) {
        // Look at the contents of the cache directory and reform the cache dictionary of photoId -> Photo File path
        NSArray *cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDir error:&error];
        if (error == nil) {
            for (NSString *file in cacheContents) {
                // Add entries into the cache
                NSString *filePath = [self.cacheDir stringByAppendingPathComponent:file];
                [self.cache setValue:filePath forKey:file];
            }
        } else {
            NSLog(@"Could not retrieve files in cache directory %@", error);
        }
    } else {
        // Create cache directory if it does not exist
        BOOL cacheCreated = [[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDir withIntermediateDirectories:NO attributes:nil error:&error];
        if (!cacheCreated) {
            NSLog(@"Failed to create cache directory %@", error);
        }
    }
    return self;
}

+ (FlickrPhotoCache *)instance
{
    // Only accessed from the main thread
    if (instance == nil) {
        instance = [[FlickrPhotoCache alloc] init];
    }
    return instance;
}

- (NSData *)getCachedFlickrPhoto:(NSString *)photoId
{
    // Get the file path for the given photo id
    NSString *photoFilePath = [self.cache valueForKey:photoId];
    NSData *photoData;
    if (photoFilePath != nil) {
        // Get the contents of the photo file
        photoData = [NSData dataWithContentsOfFile:photoFilePath];
    }
    return photoData;
}

- (BOOL)removeOldestEntry
{
    // Eviction mechanism by checking for the last modified file
    NSError *error;
    NSArray *cacheContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.cacheDir error:&error];
    NSDate *oldestDate;
    NSString *oldestFile;
    
    if (error == nil) {
        // Find the oldest file in the directory based on the last modified date attribute
        for (NSString *file in cacheContents) {
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.cacheDir stringByAppendingPathComponent:file] error:&error];
            NSDate *fileDate = [attributes objectForKey:NSFileModificationDate];
            if (oldestDate == nil || [fileDate compare:oldestDate] == NSOrderedAscending) {
                oldestDate = fileDate;
                oldestFile = file;
            }
        }
    }

    if (oldestFile) {
        NSDictionary *attributes = [[NSFileManager defaultManager]attributesOfItemAtPath:[self.cacheDir stringByAppendingPathComponent:oldestFile] error:&error];
        // Delete the oldest file and remove it from the cache
        BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:[self.cacheDir stringByAppendingPathComponent:oldestFile] error:&error];
        if (deleted) {
            [self.cache removeObjectForKey:oldestFile];
            self.cacheSize -= [[attributes objectForKey:NSFileSize] integerValue];
            return YES;
        }
        return NO;
    }
    return NO;
}

- (BOOL)addFlickrPhotoToCache:(NSString *)photoId withData:(NSData *)data
{
    if (photoId) {
        // Check the cache just to be sure
        if (![self.cache valueForKey:photoId]) {
            NSString *filePath = [self.cacheDir stringByAppendingPathComponent:photoId];
            // Save the photo data to the cache directory
            BOOL saved = [data writeToFile:filePath atomically:YES];
            if (saved) {
                NSError *error;
                NSDictionary *attributes = [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:&error];
                // Add the new file to the cache table
                [self.cache setValue:filePath forKey:photoId];
                self.cacheSize += [[attributes objectForKey:NSFileSize] integerValue];
                while (self.cacheSize > MAX_CACHE_SIZE) {
                    [self removeOldestEntry];
                };
                return YES;
            }
        }
    }
    return NO;
}

@end
