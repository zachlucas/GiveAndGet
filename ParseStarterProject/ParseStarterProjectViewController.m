#import "ParseStarterProjectViewController.h"
#import <Parse/Parse.h>
#import "GetPictureController.h"

@implementation ParseStarterProjectViewController

NSString *nameToUseWhenSendingMessage = @"";
NSString *twitterUsername = @"";
NSString *tempUN = @"";

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
    
    self.mainTextView.delegate = self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)goBackToTheMainScreen:(UIStoryboardSegue *)segue {
    //nothing goes here
}

- (void)textViewDidBeginEditing:(UITextView *)mainTextView {
    if ([_mainTextView.text isEqualToString:@"be nice!"]){
        _mainTextView.text = @"";
        _mainTextView.textColor = [UIColor blackColor];
    }
}

- (BOOL)textView:(UITextView *)mainTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (_mainTextView.text.length < 141) {
        _charCounter.text = [NSString stringWithFormat:@"(%d/140)",_mainTextView.text.length];
    }
    else{
        _charCounter.textColor = [UIColor redColor];
        _charCounter.text = [NSString stringWithFormat:@"(%d/140)",_mainTextView.text.length];
    }
    return true;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"mainScreenToPictureScreen"]){
        UINavigationController *destination = [segue destinationViewController];
        
        GetPictureController *picController = (GetPictureController*)[destination topViewController];
        
        picController.usernameToSendWithPic = nameToUseWhenSendingMessage;
        
        //segue.destinationViewController
    }
}

NSString *objectID;

- (IBAction)mainButton:(id)sender {
    
    [_responseIndicator startAnimating];
    
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
                _mainLabel.backgroundColor = [self colorWithHexString:@"ca9ae1"];
                _sentBy.backgroundColor = [self colorWithHexString:@"ca9ae1"];
                _mainLabel.textColor = [UIColor whiteColor];
                
               // NSString *objectId = [objects[randomIndex] objectId];
                
                objectID = [objects[randomIndex] objectId];
                
                [self sendMessage];
                [_responseIndicator stopAnimating];
                [query getObjectInBackgroundWithId:[objects[randomIndex] objectId] block:^(PFObject *changeToSeen, NSError *error) {
                    
                    // Now let's update it with some new data. In this case, only cheatMode and score
                    // will get sent to the cloud. playerName hasn't changed.
                    
                    changeToSeen[@"seen"] = @"yes";
                    [changeToSeen saveInBackground];
                    // TODO:  Fix this!!!
                    if (error){
                        [changeToSeen saveInBackground];
                    }
                }];
                
                
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    

}
- (IBAction)keyPressed:(id)sender {
    if (_messageText.text.length < 51) {
        _charCounter.text = [NSString stringWithFormat:@"(%d/50)",_messageText.text.length];
    }
}

- (void) sendMessage{
    
    if (_mainTextView.text.length < 5){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Too short"
                                                       message: @"Your message must be at least 5 characters!"
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
    }
    
    else{
        PFObject *testObject = [PFObject objectWithClassName:@"Message"];
        if ([nameToUseWhenSendingMessage isEqualToString:@""]){
            testObject[@"name"] = @"Anonymous";
        }
        else{
            if (tempUN.length == 0){
                NSLog(@"tempUN zeroooo");
                testObject[@"name"] = nameToUseWhenSendingMessage;
            }
            else{
                testObject[@"name"] = tempUN;
            }
        }
        testObject[@"seen"] = @"no";
        testObject[@"message"] = self.mainTextView.text;
        [testObject save];

        NSLog(@"Data Sending: %@",self.mainTextView.text);
    }
    self.mainTextView.text = @"";
    [self.view endEditing:YES];
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
- (IBAction)picClicked:(id)sender {
    [self presentViewController:_picSender animated:YES completion:nil];
}
- (IBAction)backToMain:(id)sender {
    NSLog(@"trying to go back");
    self.view = _mainView;
}

- (void)getTwitterAccountInformation
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"un:%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.accountType);
                nameToUseWhenSendingMessage = twitterAccount.username;
                tempUN = twitterAccount.username;
            }
        }
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (tempUN.length == 0){
            _sendingAs.text = @"Sending as: @AnonTweeter";
            tempUN = @"@AnonTweeter";
            nameToUseWhenSendingMessage = tempUN;
        }
        else{
            _sendingAs.text = [NSString stringWithFormat:@"Sending as: @%@", tempUN];
            nameToUseWhenSendingMessage = [NSString stringWithFormat:@"@%@",tempUN];
            tempUN = nameToUseWhenSendingMessage;
        }
    });
   
}
- (IBAction)getTwitterHandle:(id)sender {
    [self getTwitterAccountInformation];
    NSLog(@"second un: %@",twitterUsername);
}




@end
