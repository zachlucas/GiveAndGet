#import "ParseStarterProjectViewController.h"
#import <Parse/Parse.h>

@implementation ParseStarterProjectViewController


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (IBAction)mainButton:(id)sender {
    

    
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"seen" equalTo:@"no"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d messages.", objects.count);
            // Do something with the found objects
            
            // Getting a random message:
            NSUInteger randomIndex = arc4random() % [objects count];
            
            NSLog(@"Random message: %@",[objects[randomIndex] objectForKey:@"message"]);
            NSLog(@"Random id: %@",[objects[randomIndex] objectId]);
            
            _mainLabel.text = [objects[randomIndex] objectForKey:@"message"];
            _sentBy.text = [@"Sent by: " stringByAppendingString:[objects[randomIndex] objectForKey:@"name"]];
            
            NSString *objectId = [objects[randomIndex] objectId];
            
            [query getObjectInBackgroundWithId:objectId block:^(PFObject *gameScore, NSError *error) {
                
                // Now let's update it with some new data. In this case, only cheatMode and score
                // will get sent to the cloud. playerName hasn't changed.
                
                gameScore[@"seen"] = @"yes";
                [gameScore saveInBackground];
                
            }];
            
            [self sendMessage];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    

}

- (void) sendMessage{
    PFObject *testObject = [PFObject objectWithClassName:@"Message"];
    testObject[@"name"] = @"zach";
    testObject[@"seen"] = @"no";
    testObject[@"message"] = self.messageText.text;
    [testObject saveInBackground];
    
    NSLog(@"Data Sending: %@",self.messageText.text);
}

@end
