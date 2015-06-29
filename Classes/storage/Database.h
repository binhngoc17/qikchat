#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ResultSet.h"

@interface Database : NSObject
{
	sqlite3*               db;
	NSString*              databasePath;
	NSThread*              startingThread;
	BOOL                   inTransaction;
	BOOL                   isExiting;
}


+ (NSString*) sqliteLibVersion;
+ (id)databaseWithPath:(NSString*)inPath;

- (id)initWithPath:(NSString*)inPath;

- (BOOL) open;
#if SQLITE_VERSION_NUMBER >= 3005000
- (BOOL) openWithFlags:(int)flags;
#endif
- (BOOL) close;
- (BOOL) goodConnection;

// encryption methods.  You need to have purchased the sqlite encryption extensions for these to work.
- (BOOL) setKey:(NSString*)key;
- (BOOL) rekey:(NSString*)key;


- (NSString*) databasePath;
- (NSString*) lastErrorMessage;

- (int)  lastErrorCode;
- (BOOL) hadError;
- (sqlite_int64) lastInsertRowId;

- (sqlite3*) sqliteHandle;

- (int) executeStatement:(sqlite3_stmt*)statement;

- (BOOL) executeUpdate:(NSString*)sql, ...;
- (BOOL) executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;

- (id)   executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orVAList:(va_list)args; 
- (id)   executeQuery:(NSString*)sql, ...;
- (id)   executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;

- (BOOL) beginTransaction;
- (BOOL) beginDeferredTransaction;
- (BOOL) rollback;
- (BOOL) commit;

- (int)changes;
@end

@interface Statement : NSObject {
    sqlite3_stmt *statement;
    NSString *query;
}


- (void) close;
- (void) reset;

- (sqlite3_stmt *)statement;
- (void)setStatement:(sqlite3_stmt *)value;

- (NSString *)query;
- (void)setQuery:(NSString *)value;

@end
