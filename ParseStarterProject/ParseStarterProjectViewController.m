#import "ParseStarterProjectViewController.h"
#import <Parse/Parse.h>
#import "GetPictureController.h"
#import <AudioToolbox/AudioServices.h>
#import <QuartzCore/QuartzCore.h>

@implementation ParseStarterProjectViewController

NSString *objectID;
NSString *nameToUseWhenSendingMessage = @"";
NSString *twitterUsername = @"";
NSString *tempUN = @"";
NSString *locationToSend = @"";
CLLocationManager *locationManager;
CLPlacemark *placemark;
NSString *postalCodeToSend = @"";
bool animate = YES;
NSString *colorToAnimate = @"a2b7e0";

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {    
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    // Potential blurred background?
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blurredRainbow.png"]];

    // Checking if the app has been run before
    NSString *flag = [[NSUserDefaults standardUserDefaults] stringForKey:@"has_been_run"];
    if (!flag) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Welcome To G&G!"
                                                       message: @"It's simple. You send a text or a picture message, and you get a random one in return. No texts or pictures are seen twice, as soon as they are seen they are removed from the almighty cloud!"
                                                      delegate: self
                                             cancelButtonTitle:@"Sounds good!"
                                             otherButtonTitles:nil,nil];
        
        
        [alert show];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"has_been_run"];
    
    _giveButton.alpha = 0.5;
    _giveButton.userInteractionEnabled = NO;
    _locationReceivedButton.layer.hidden = YES;
    
    
    [UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _useTwitterHandleButton.backgroundColor = [self colorWithHexString:@"b47281"];
        _givePicButton.backgroundColor = [self colorWithHexString:@"fd9eb2"];
        
    }completion:NULL];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self
                                   selector:@selector(MethodB:) userInfo:nil repeats:YES];
    // Enables control of the main TextView
    self.mainTextView.delegate = self;
}

- (void)MethodB:(NSTimer*)timer {
    if (animate == NO){

        [UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _useTwitterHandleButton.backgroundColor = [self colorWithHexString:@"b47281"];
            _givePicButton.backgroundColor = [self colorWithHexString:@"fd9eb2"];
            
        }completion:NULL];
        animate = YES;
    }
    else{
        [UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _useTwitterHandleButton.backgroundColor = [self colorWithHexString:@"fd9eb2"];
            _givePicButton.backgroundColor = [self colorWithHexString:@"b47281"];
            
        }completion:NULL];
        animate = NO;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)goBackToTheMainScreen:(UIStoryboardSegue *)segue {
    //nothing goes here
}

- (void)textViewDidBeginEditing:(UITextView *)mainTextView {
    // Allows for placeholder in TextView:
    if ([_mainTextView.text isEqualToString:@"be nice!"] || [_mainTextView.text isEqualToString:@"send another!"] || [_mainTextView.text isEqualToString:@"send anot her!"]){
        _mainTextView.text = @"";
        _mainTextView.textColor = [UIColor blackColor];
    }
}

- (BOOL)textView:(UITextView *)mainTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Checks text length:
    if (_mainTextView.text.length < 141) {
        _charCounter.textColor = [self colorWithHexString:@"d8d8d8"];
        _charCounter.text = [NSString stringWithFormat:@"(%lu/140)",(unsigned long)_mainTextView.text.length];
    }
    else{
        _charCounter.textColor = [UIColor redColor];
        _charCounter.text = [NSString stringWithFormat:@"(%lu/140)",(unsigned long)_mainTextView.text.length];
    }
    
    if (_mainTextView.text.length > 4 && _mainTextView.text.length < 141) {
        _giveButton.alpha = 1;
        _giveButton.userInteractionEnabled = YES;
    }
    else{
        _giveButton.alpha = 0.5;
        _giveButton.userInteractionEnabled = NO;
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


- (IBAction)mainButton:(id)sender {
    // If message is too short:
    if (_mainTextView.text.length < 5){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Too short"
                                                       message: @"Your message must be at least 5 characters!"
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
    }
    // If message is too long:
    else if(_mainTextView.text.length > 140){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Too Long"
                                                       message: @"Your message can't be longer than a tweet, silly."
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",nil];
        
        
        [alert show];
    }
    // if message is placeholder text:
    else if ([_mainTextView.text isEqualToString:@"send another!"] || [_mainTextView.text isEqualToString:@"be nice!"]){
        
    }
    // the message is juuust right!
    else{
        [_responseIndicator startAnimating];
        // finding messages that haven't been seen:
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query whereKey:@"seen" equalTo:@"no"];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                // Do something with the found objects
                
                // If there are no unseen objects:
                if ([objects count] == NULL){
                    NSLog(@"No unseen messages to get...");
                    
                    _sentHeader.text = @"Sent!  Here's your response:";
                    _mainLabel.text = @"Test message!";
                    _sentBy.text = @"Sent by: Zach";
                    _mainLabel.backgroundColor = [self colorWithHexString:@"e890a3"];
                    _mainLabel.textColor = [UIColor whiteColor];
                    
                    [self sendMessage];
                    
                }
                else{
                    // Getting a random message:
                    NSUInteger randomIndex = arc4random() % [objects count];
                    
                    NSLog(@"Random message: %@",[objects[0] objectForKey:@"message"]);
                    NSLog(@"Random id: %@",[objects[0] objectId]);
                    
                    _sentHeader.text = @"Sent!  Here's your response:";
                    _mainLabel.text = [objects[0] objectForKey:@"message"];
                    _locationReceived.text = [objects[0] objectForKey:@"location"];
                    if (_locationReceived.text.length > 0) {
                        _locationReceivedButton.layer.hidden = NO;
                    }
                    else{
                        _locationReceivedButton.layer.hidden = YES;
                    }
                    
                    
                    // Getting who message was sent by:
                    NSString *tempSentBy = [@"Sent by: " stringByAppendingString:[objects[0] objectForKey:@"name"]];

                    // Getting and formatting the date:
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MM/dd/yyyy"];
                    NSString *stringFromDate = [@" on: " stringByAppendingString:[formatter stringFromDate:[objects[randomIndex] createdAt]]];
                    
                    _sentBy.text = [tempSentBy stringByAppendingString:stringFromDate];
                    //_mainLabel.backgroundColor = [self colorWithHexString:@"e890a3"];
                    //_sentBy.backgroundColor = [self colorWithHexString:@"e890a3"];
                    _mainLabel.layer.borderColor = [self colorWithHexString:@"e890a3"].CGColor;
                    _mainLabel.layer.borderWidth = 3.0;
                    _mainLabel.textColor = [UIColor whiteColor];
                    
                    objectID = [objects[0] objectId];
                    
                    [objects[0] delete];
                    
                    [self sendMessage];
                    [_responseIndicator stopAnimating];
                    
                    
                    NSLog(@"Trying to delete %@", [objects[randomIndex] objectId]);
                                        
                    
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }

}

- (void) sendMessage{
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
    
    if (locationToSend.length > 0) {
        testObject[@"location"] = locationToSend;
        testObject[@"postalCode"] = postalCodeToSend;
    }
    else{
        testObject[@"location"] = @"";
        testObject[@"postalCode"] = @"";
    }
    
    [testObject.ACL setPublicWriteAccess:YES];
    [testObject save];

    NSLog(@"Data Sending: %@",self.mainTextView.text);
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    _mainTextView.text = @"send another!";
    _mainTextView.textColor = [UIColor grayColor];
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

- (IBAction)picClicked:(id)sender {
    [self presentViewController:_picSender animated:YES completion:nil];
}
- (IBAction)backToMain:(id)sender {
    self.view = _mainView;
}

- (void)getTwitterAccountInformation
{
    [_customHandleButton setTitle:@"Use a Custom Handle" forState:UIControlStateNormal];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"Twitter username: %@",twitterAccount.username);
                NSLog(@"Account type: %@",twitterAccount.accountType);
                NSLog(@"Full name: %@",twitterAccount.userFullName);
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

- (IBAction)customHandle:(id)sender {
    
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Custom Handle" message:@"Enter your custom handle:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    
    [av show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *handle = [alertView textFieldAtIndex:0].text;
        [_customHandleButton setTitle:[@"Using: " stringByAppendingString:handle] forState:UIControlStateNormal];
        _sendingAs.text = [@"Sending as: " stringByAppendingString:handle];
        nameToUseWhenSendingMessage = handle;
        tempUN = handle;
    }
}
- (IBAction)logoClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Hello"
                                                   message: @"This silly little app was written by Zach Lucas (@ZacharyLucas)"
                                                  delegate: self
                                         cancelButtonTitle:@"Okey Dokey"
                                         otherButtonTitles:nil,nil];
    
    
    [alert show];
}



- (IBAction)locationClicked:(id)sender {
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"locationIcon.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        locationToSend = @"";
        _locationLabel.text = @"";
    } else {
        [sender setImage:[UIImage imageNamed:@"locationIconSelected.png"] forState:UIControlStateNormal];
        [sender setSelected:YES];
        NSLog(@"finding location...");
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 1000;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers; // 3 km
        [locationManager startUpdatingLocation];
        
        CLLocation *currentLocation = locationManager.location;
        CLGeocoder*geocoder;
        geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            if (error == nil && [placemarks count] > 0) {
                NSLog(@"looking for locality:");
                placemark = [placemarks lastObject];
                locationToSend = placemark.locality;
                postalCodeToSend = placemark.postalCode;
                _locationLabel.text = locationToSend;
                NSLog(@"The coordinates: %@",postalCodeToSend);
            } else {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
    }
    
}

@end
