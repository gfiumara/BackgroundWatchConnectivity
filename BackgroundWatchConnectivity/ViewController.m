#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) WCSession *session;

@property (weak, nonatomic) IBOutlet UIButton *activateSessionButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;

@end

@implementation ViewController

- (IBAction)activateSessionButtonPressed:(UIButton *)sender
{
	if (![WCSession isSupported]) {
		NSLog(@"WatchConnectivity is not supported");
		return;
	}

	if (self.session.activationState != WCSessionActivationStateActivated)
		[self.session activateSession];
}

- (WCSession *)session
{
	NSAssert([WCSession isSupported], @"WatchConnectivity is not supported");

	if (_session != nil)
		return (_session);

	_session = [WCSession defaultSession];
	_session.delegate = self;

	return (_session);
}

- (IBAction)sendMessageButtonPressed:(UIButton *)sender
{
	NSAssert([WCSession isSupported], @"WatchConnectivity is not supported");
	NSAssert(self.session != nil, @"WatchConnectivity session is nil");

	static NSUInteger counter = 0;
	[self.session transferUserInfo:@{@"counter" : @(counter++)}];
}

- (void)setActivationButtonEnabled:(BOOL)enabled
{
	dispatch_async(dispatch_get_main_queue(), ^() {
		self.activateSessionButton.enabled = enabled;
		self.sendMessageButton.enabled = !enabled;
	});
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

	[self setActivationButtonEnabled:(activationState != WCSessionActivationStateActivated)];
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

	[self setActivationButtonEnabled:(session.activationState != WCSessionActivationStateActivated)];
}

- (void)sessionDidBecomeInactive:(WCSession *)session
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self setActivationButtonEnabled:YES];
}

- (void)sessionDidDeactivate:(WCSession *)session
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self setActivationButtonEnabled:YES];
}

@end
