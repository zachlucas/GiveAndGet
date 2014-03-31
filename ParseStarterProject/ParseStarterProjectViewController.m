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
    _messageText.returnKeyType = UIReturnKeySend;
    
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
            
            if ([objects count] == NULL){
                NSLog(@"No unseen messages to get...");
                
                _sentHeader.text = @"Sent!  Here's your response:";
                _mainLabel.text = @"Test message!";
                _sentBy.text = @"Sent by: Zach";
                _mainLabel.backgroundColor = [self colorWithHexString:@"dc99b8"];
                _mainLabel.textColor = [UIColor whiteColor];
                
                [self sendMessage];
                
            }
            else{
                // Getting a random message:
                NSUInteger randomIndex = arc4random() % [objects count];
                
                NSLog(@"Random message: %@",[objects[randomIndex] objectForKey:@"message"]);
                NSLog(@"Random id: %@",[objects[randomIndex] objectId]);
                
                _sentHeader.text = @"Sent!  Here's your response:";
                _mainLabel.text = [objects[randomIndex] objectForKey:@"message"];
                _sentBy.text = [@"Sent by: " stringByAppendingString:[objects[randomIndex] objectForKey:@"name"]];
                _mainLabel.backgroundColor = [self colorWithHexString:@"dc99b8"];
                _mainLabel.textColor = [UIColor whiteColor];
                
                NSString *objectId = [objects[randomIndex] objectId];
                
                [query getObjectInBackgroundWithId:objectId block:^(PFObject *gameScore, NSError *error) {
                    
                    // Now let's update it with some new data. In this case, only cheatMode and score
                    // will get sent to the cloud. playerName hasn't changed.
                    
                    gameScore[@"seen"] = @"yes";
                    [gameScore saveInBackground];
                    
                }];
                
                [self sendMessage];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    

}
- (IBAction)keyPressed:(id)sender {
    if (_messageText.text.length < 51) {
        NSMutableString* aString = [NSMutableString stringWithFormat:@"("];
        [aString appendFormat:@"%d", _messageText.text.length];
        [aString appendString:@"/50)"];
        _charCounter.text = aString;
    }
}

- (void) sendMessage{
    
    if (_messageText.text.length < 5){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Too short"
                                                       message: @"Your message must be at least 5 characters!"
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
    }
    
    else{
        PFObject *testObject = [PFObject objectWithClassName:@"Message"];
        testObject[@"name"] = @"Anonymous";
        testObject[@"seen"] = @"no";
        testObject[@"message"] = self.messageText.text;
        [testObject saveInBackground];

        NSLog(@"Data Sending: %@",self.messageText.text);
    }
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}
    
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)messageText
{
    NSLog(@"FDSF");
    [self mainButton:(@"3")];
    return YES;
}

@end