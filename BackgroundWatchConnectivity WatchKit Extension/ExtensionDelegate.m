#import "ExtensionDelegate.h"

@interface ExtensionDelegate()

@property (nonatomic, strong) WCSession *session;
@property (nonatomic, strong) NSMutableArray<WKWatchConnectivityRefreshBackgroundTask *> *watchConnectivityTasks;

@end

@implementation ExtensionDelegate

#pragma mark - Actions

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks
{
	NSLog(@"Watch app woke up for background task");

	for (WKRefreshBackgroundTask *task in backgroundTasks) {
		if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
			[self handleBackgroundWatchConnectivityTask:(WKWatchConnectivityRefreshBackgroundTask *)task];
		} else {
			NSLog(@"Handling an unsupported type of background task");
			[task setTaskCompleted];
		}
	}
}

- (void)handleBackgroundWatchConnectivityTask:(WKWatchConnectivityRefreshBackgroundTask *)task
{
	NSLog(@"Handling WatchConnectivity background task");

	if (self.watchConnectivityTasks == nil)
		self.watchConnectivityTasks = [NSMutableArray new];
	[self.watchConnectivityTasks addObject:task];

	if (self.session.activationState != WCSessionActivationStateActivated)
		[self.session activateSession];
}

#pragma mark - Properties

- (WCSession *)session
{
	NSAssert([WCSession isSupported], @"WatchConnectivity is not supported");

	if (_session != nil)
		return (_session);

	_session = [WCSession defaultSession];
	_session.delegate = self;

	return (_session);
}

#pragma mark - WCSessionDelegate

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error
{
	switch(activationState) {
		case WCSessionActivationStateActivated:
			NSLog(@"WatchConnectivity session activation changed to \"activated\"");
			break;
		case WCSessionActivationStateInactive:
			NSLog(@"WatchConnectivity session activation changed to \"inactive\"");
			break;
		case WCSessionActivationStateNotActivated:
			NSLog(@"WatchConnectivity session activation changed to \"NOT activated\"");
			break;
	}
}

- (void)sessionWatchStateDidChange:(WCSession *)session
{
	switch(session.activationState) {
		case WCSessionActivationStateActivated:
			NSLog(@"WatchConnectivity session activation changed to \"activated\"");
			break;
		case WCSessionActivationStateInactive:
			NSLog(@"WatchConnectivity session activation changed to \"inactive\"");
			break;
		case WCSessionActivationStateNotActivated:
			NSLog(@"WatchConnectivity session activation changed to \"NOT activated\"");
			break;
	}
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *, id> *)userInfo
{
	/*
	 * NOTE:
	 * Even if this method only sets the task to be completed, the default
	 * WatchConnectivity session delegate still picks up the message
	 * without another call to handleBackgroundTasks:
	 */

	NSLog(@"Received message with counter value = %@", userInfo[@"counter"]);

	if (session.hasContentPending) {
		NSLog(@"Task not completed. More content pending...");
	} else {
		NSLog(@"No pending content. Marking all tasks (%ld tasks) as complete.", (unsigned long)self.watchConnectivityTasks.count);
		for (WKWatchConnectivityRefreshBackgroundTask *task in self.watchConnectivityTasks)
			[task setTaskCompleted];
		[self.watchConnectivityTasks removeAllObjects];
	}
}

@end
