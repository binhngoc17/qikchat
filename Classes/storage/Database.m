#import "Database.h"
#import "unistd.h"
#import "stdarg.h"
#import "Literals.h"

@interface Database (Private)
-(void) bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt;
-(Statement*) createStatement:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orVAList:(va_list)args;
-(BOOL) executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray*)arrayArgs orVAList:(va_list)args;
@end


@implementation Database (Private)


-(void) bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt
{
	int result = 0;
    
	if ((!obj) || ((NSNull *)obj == [NSNull null])) {
		result = sqlite3_bind_null(pStmt, idx);
	}
	
	// FIXME - someday check the return codes on these binds.
	else if ([obj isKindOfClass:[NSData class]]) {
		result = sqlite3_bind_blob(pStmt, idx, [obj bytes], (int)[obj length], SQLITE_STATIC);
	}
	else if ([obj isKindOfClass:[NSDate class]]) {
		result = sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
	}
	else if ([obj isKindOfClass:[NSNumber class]]) {
		
		if (strcmp([obj objCType], @encode(BOOL)) == 0) {
			result = sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
		}
		else if (strcmp([obj objCType], @encode(int)) == 0) {
			result = sqlite3_bind_int64(pStmt, idx, [obj longValue]);
		}
		else if (strcmp([obj objCType], @encode(long)) == 0) {
			result = sqlite3_bind_int64(pStmt, idx, [obj longValue]);
		}
		else if (strcmp([obj objCType], @encode(long long)) == 0) {
			result = sqlite3_bind_int64(pStmt, idx, [obj longLongValue]);
		}
		else if (strcmp([obj objCType], @encode(float)) == 0) {
			result = sqlite3_bind_double(pStmt, idx, [obj floatValue]);
		}
		else if (strcmp([obj objCType], @encode(double)) == 0) {
			result = sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
		}
		else {
			result = sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
		}
	}
	else {
		result = sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
	}
	
	if (result != SQLITE_OK) {
		NSLog(@"sqlite3_bind_*() returned %d, error: \"%@\" (error code %d).", result, [self lastErrorMessage], [self lastErrorCode]);
	}
}

-(Statement*) createStatement:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orVAList:(va_list)args
{
	int rc                 = 0;	sqlite3_stmt *pStmt    = NULL;
	Statement *statement = nil;
	
	rc = sqlite3_prepare_v2(db, [sql UTF8String], -1, &pStmt, 0);
	
	if (rc != SQLITE_OK) {
		NSLog(@"sqlite3_prepare_v2() returned %d, error: \"%@\" (error code %d).\nFor DB Query: %@.", rc, [self lastErrorMessage], [self lastErrorCode], sql);
		return nil;
	}
	
	// Bind parameters.
	id obj;
	int queryCount = sqlite3_bind_parameter_count(pStmt);
	
	if (arrayArgs) {
		DASSERT( (queryCount >= 0) && (queryCount == (int)[arrayArgs count]) );
	}
	
	for (int idx = 0; idx < queryCount; idx++) {
		if (arrayArgs) {
			obj = [arrayArgs objectAtIndex:idx];
		}
		else {
			obj = va_arg(args, id);
		}
		[self bindObject:obj toColumn:(idx+1) inStatement:pStmt];
	}
	
	statement = [[[Statement alloc] init] autorelease];
	[statement setStatement:pStmt];
	[statement setQuery:sql];
	return statement;
}

-(BOOL) executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray*)arrayArgs orVAList:(va_list)args {
	BOOL result = YES;
    Statement* statement = [self createStatement:sql withArgumentsInArray:arrayArgs orVAList:args];
    int res = [self executeStatement:statement.statement];
    result = (res == SQLITE_OK || res == SQLITE_DONE);
	
	return result;
}

@end // Database (Private)





//---------------------------------------------------------------------------------------------------------
@implementation Database

+(id) databaseWithPath:(NSString*)aPath
{
	return [[[self alloc] initWithPath:aPath] autorelease];
}


-(id) initWithPath:(NSString*)aPath
{
	if ((self =[super init])) {
		databasePath        = [aPath copy];
		startingThread      = [[NSThread currentThread] retain];
		db                  = nil;
	}
	
	return self;
}


-(void) dealloc
{
	[self close];
	
	[startingThread release];
	[databasePath release];
	
	[super dealloc];
}

+(NSString*) sqliteLibVersion
{
	return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}

-(NSString *) databasePath
{
	return databasePath;
}

-(sqlite3*) sqliteHandle
{
	return db;
}

-(BOOL) open
{
	DASSERT(db == NULL);
	int err = sqlite3_open([databasePath fileSystemRepresentation], &db);
	if(err != SQLITE_OK) {
		NSLog(@"error opening!: %d", err);
		return NO;
	}
	return YES;
}

#if SQLITE_VERSION_NUMBER >= 3005000
-(BOOL) openWithFlags:(int)flags
{
	DASSERT(db == NULL);
	int err = sqlite3_open_v2([databasePath fileSystemRepresentation], &db, flags, NULL /* Name of VFS module to use */);
	if(err != SQLITE_OK) {
		NSLog(@"error opening!: %d", err);
		return NO;
	}
	return YES;
}
#endif


-(BOOL) close
{
	DASSERT(db);
	
	int  rc;
	int retriesLeft = 3;
	while (retriesLeft > 0) {
		rc      = sqlite3_close(db);
		if (rc == SQLITE_OK) {
			db = nil;
			return YES;
		}
		NSLog(@"error closing!: %d", rc);
		retriesLeft--;
		usleep(1000);
	}
	
	return NO;
}

	
-(BOOL) rekey:(NSString*)key 
{
#pragma unused(key)	
#ifdef SQLITE_HAS_CODEC
	if (!key) {
		return NO;
	}
	
	int rc = sqlite3_rekey(db, [key UTF8String], strlen([key UTF8String]));
	
	if (rc != SQLITE_OK) {
		NSLog(@"error !: ");
	}
	
	return (rc == SQLITE_OK);
#else
	return NO;
#endif
}

-(BOOL) setKey:(NSString*)key 
{
#pragma unused(key)	
#ifdef SQLITE_HAS_CODEC
	if (!key) {
		return NO;
	}
	
	int rc = sqlite3_key(db, [key UTF8String], strlen([key UTF8String]));
	
	return (rc == SQLITE_OK);
#else
	return NO;
#endif
}

-(BOOL) goodConnection
{
	if (!db) return NO;
	
	ResultSet *rs = [self executeQuery:@"select name from sqlite_master where type='table'", nil];
	
	if (rs) {
		[rs close];
		return YES;
	}
	
	return NO;
}

-(NSString*) lastErrorMessage
{
	return [NSString stringWithUTF8String:sqlite3_errmsg(db)];
}

-(BOOL) hadError
{
	int lastErrCode = [self lastErrorCode];
	return (lastErrCode > SQLITE_OK && lastErrCode < SQLITE_ROW);
}

-(int) lastErrorCode
{
	return sqlite3_errcode(db);
}

-(sqlite_int64) lastInsertRowId
{
	return sqlite3_last_insert_rowid(db);
}

-(int) executeStatement:(sqlite3_stmt*)statement
{
	DASSERT(db);
	
	int rc=SQLITE_OK;
	int numberOfRetries = 3;
	while (numberOfRetries > 0) {
		// Call sqlite3_step() to run the virtual machine. Since the SQL being executed is
		// not a SELECT statement, we assume no data will be returned.
		rc = sqlite3_step(statement);
		
		if ( (rc == SQLITE_DONE) || (rc == SQLITE_ROW) ) {
			return rc;
		}
		else if (rc == SQLITE_BUSY) {
			usleep(300);
			NSLog(@"Databast busy, retry: %s", sqlite3_errmsg(db));
		}
		else {
			NSLog(@"sqlite3_step() returned %d: %s", rc, sqlite3_errmsg(db));
			return rc;
		}
		numberOfRetries--;		
	}
	return rc;
}

-(id) executeQuery:(NSString *)sql withArgumentsInArray:(NSArray*)arrayArgs orVAList:(va_list)args {
	NSLog(@"ExecuteQuery: %@", sql);
	
	Statement* statement = [self createStatement:sql withArgumentsInArray:arrayArgs orVAList:args];
	
	ResultSet* result = [ResultSet resultSetWithStatement:statement usingParentDatabase:self];
	[result setQuery:sql];
	
	return result;

}

-(id) executeQuery:(NSString*)sql, ... {

	va_list args;
	va_start(args, sql);
	id result = [self executeQuery:sql withArgumentsInArray:nil orVAList:args];
	va_end(args);
	
	return result;
}


-(id) executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments {
	return [self executeQuery:sql withArgumentsInArray:arguments orVAList:nil];
}


-(BOOL) executeUpdate:(NSString*)sql, ... {
	va_list args;
	va_start(args, sql);
	
	BOOL result = [self executeUpdate:sql withArgumentsInArray:nil orVAList:args];
	
	va_end(args);
	return result;
}


-(BOOL) executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments {
	return [self executeUpdate:sql withArgumentsInArray:arguments orVAList:nil];
}


-(BOOL) rollback {
	BOOL b = [self executeUpdate:@"ROLLBACK TRANSACTION;", nil];
	if (b) {
		inTransaction = NO;
	}
	return b;
}

-(BOOL) commit {
	BOOL b =  [self executeUpdate:@"COMMIT TRANSACTION;", nil];
	if (b) {
		inTransaction = NO;
	}
	return b;
}

-(BOOL) beginDeferredTransaction {
	BOOL b =  [self executeUpdate:@"BEGIN DEFERRED TRANSACTION;", nil];
	if (b) {
		inTransaction = YES;
	}
	return b;
}

-(BOOL) beginTransaction {
	BOOL b =  [self executeUpdate:@"BEGIN EXCLUSIVE TRANSACTION;", nil];
	if (b) {
		inTransaction = YES;
	}
	return b;
}

-(int)changes {
	return(sqlite3_changes(db));
}

@end



@implementation Statement

-(void)dealloc {
	[self close];
	[query release];
	[super dealloc];
}


-(void) close {
	if (statement) {
		sqlite3_finalize(statement);
		statement = 0x00;
	}
}

-(void) reset {
	if (statement) {
		sqlite3_reset(statement);
	}
}

-(sqlite3_stmt*) statement {
	return statement;
}

-(void)setStatement:(sqlite3_stmt *)value {
	statement = value;
}

-(NSString*) query {
	return query;
}

-(void)setQuery:(NSString *)value {
	if (query != value) {
		[query release];
		query = [value retain];
	}
}

-(NSString*) description {
	return query;
}


@end
