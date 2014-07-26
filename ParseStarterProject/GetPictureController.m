//
//  GetPictureController.m
//  GiveAndGet
//
//  Created by Zach Lucas on 4/1/14.
//
//

#import "GetPictureController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>

@interface GetPictureController () <UIAlertViewDelegate>

@end

@implementation GetPictureController

bool isPicThere = NO;
NSString *locationToSendPic = @"";
CLLocationManager *locationManager;
CLPlacemark *placemarkPic;
NSString *postalCodeToSendPic = @"";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //_doneButton.layer.cornerRadius = 5.0;
    _userIDFromPic = @"";
    //self.picProgressBar.hidden = true;
    isFullScreen = FALSE;
    // method exists...??
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgToFullScreen)];
    tap.delegate = self;
    
    [[_otherGetPicButton layer] setBorderWidth:1.0f];
    [[_otherGetPicButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [[_doneButton layer] setBorderWidth:1.0f];
    [[_doneButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Getting the imageview ready:
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 315, 120, 170)];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_imageView setClipsToBounds:YES];
    _imageView.userInteractionEnabled = YES;
    
    // For fullscreening the image:
    _downloadPicture.hidden = YES;
    _shareButton.hidden = YES;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgToFullScreen:)];
    tapper.numberOfTapsRequired = 1;
    [_imageView addGestureRecognizer:tapper];
    
    // Location information:
    if (locationToSendPic.length == 0){
        NSLog(@"finding location...");
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = 1000;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers; // 3 km
        [locationManager startUpdatingLocation];
        
        CLLocation *currentLocation = locationManager.location;
        CLGeocoder*geocoder;
        geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarkPics, NSError *error) {
            NSLog(@"Found placemarkPics: %@, error: %@", placemarkPics, error);
            if (error == nil && [placemarkPics count] > 0) {
                NSLog(@"looking for locality:");
                placemarkPic = [placemarkPics lastObject];
                locationToSendPic = placemarkPic.locality;
                postalCodeToSendPic = placemarkPic.postalCode;
                NSLog(@"The coordinates: %@",postalCodeToSendPic);
            } else {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
        
    }
    
    [locationManager stopUpdatingLocation];
    
    [self.view addSubview:_imageView];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction) showSavedMediaBrowser {
    [self startMediaBrowserFromViewController: self
                                usingDelegate: self];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

- (IBAction) showCameraUI {
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
    
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController:cameraUI animated:YES completion:nil];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    //[[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)goBackToText:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    [_imageIndicator startAnimating];
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Compressing the image:
        // TODO: Compress it even SMALLER:
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.0f);
        NSLog(@"This is the image size (in bytes): %lu",(unsigned long)[imageData length]);
        
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        
        PFObject *userPhoto = [PFObject objectWithClassName:@"Photo"];
        
        // Setting the user's name:
        if (_usernameToSendWithPic.length == 0){
            userPhoto[@"name"] = @"Anonymous";
        }
        else{
            userPhoto[@"name"] = _usernameToSendWithPic;
        }
        
        // Current User:
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            // do stuff with the user
            NSLog(@"user is active");
            userPhoto[@"userID"] = currentUser.objectId;
        } else {
            NSLog(@"no user signed in");
            userPhoto[@"userID"] = @"noID";
            // show the signup or login screen
        }
        
        // Setting the other attributes:
        userPhoto[@"imageFile"] = imageFile;
        userPhoto[@"seen"] = @"no";
        userPhoto[@"postalCode"] = postalCodeToSendPic;
        userPhoto[@"location"] = locationToSendPic;
        
        if ([[UIDevice currentDevice] name]){
        userPhoto[@"deviceName"] = [[UIDevice currentDevice] name];
        }
        else{
            userPhoto[@"deviceName"] = @"";
        }
        
        // Finding a photo that hasn't been seen
        PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
        [query whereKey:@"seen" equalTo:@"no"];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // Sending the image:
                [userPhoto.ACL setPublicWriteAccess:YES];
                
                [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    // For text below picture:
                    NSString *author = [[objects objectAtIndex:[objects count]-1] objectForKey:@"name"];
                    NSString *sentBy = [@"Sent by: " stringByAppendingString:author];
                    //NSString *timeSent = [[objects objectAtIndex:[objects count]-1] objectForKey:@"createdAt"];
                    // Getting and formatting the date:
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"MM/dd/yyyy"];
                    NSString *stringFromDate = [@" on: " stringByAppendingString:[formatter stringFromDate:[[objects objectAtIndex:[objects count]-1] createdAt]]];
                    
                    NSString *totalText = [sentBy stringByAppendingString:stringFromDate];
                    _successMessage.text = totalText;

                    // getting the image object
                    [query getObjectInBackgroundWithId:[[objects objectAtIndex:[objects count]-1] objectId] block:^(PFObject *textdu, NSError *error) {
                        if (!error) {
                            PFFile *imageFile = [textdu objectForKey:@"imageFile"];
                            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                if (!error) {
                                    // Showing the image
                                    UIImage *image = [UIImage imageWithData:data];
                                    // Begin a new image that will be the new image with the rounded corners
                                    // (here with the size of an UIImageView)
                                    UIGraphicsBeginImageContextWithOptions(_imageView.bounds.size, NO, 4.0);
                                    
                                    // Add a clip before drawing anything, in the shape of an rounded rect
                                    [[UIBezierPath bezierPathWithRoundedRect:_imageView.bounds
                                                                cornerRadius:5.0] addClip];
                                    // Draw your image
                                    [image drawInRect:_imageView.bounds];
                                    
                                    // Get the image, here setting the UIImageView image
                                    _imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                                    
                                    // Lets forget about that we were drawing
                                    UIGraphicsEndImageContext();
                                    
                                    // user that sent the photo:
                                    _userIDFromPic = [textdu objectForKey:@"userID"];
                                    
                                    //_imageView.image = image;
                                    isPicThere = YES;
                                    
                                    
                                    [query getObjectInBackgroundWithId:[[objects objectAtIndex:[objects count]-1] objectId] block:^(PFObject *changeToSeen, NSError *error) {
                                        
                                        // Now let's update it with some new data. In this case, only cheatMode and score
                                        // will get sent to the cloud. playerName hasn't changed.
                                        
                                        //changeToSeen[@"seen"] = @"yes";
                                        //[changeToSeen saveInBackground];
                                        [changeToSeen deleteInBackground];
                                        
                                        // Saves the image to the Parse cloud
                                        if (error){
                                            NSLog(@"Can't delete image");
                                            //[changeToSeen saveInBackground];
                                        }
                                    }];
                                    
                                    // Vibrates
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                    // Formatting the image:
                                    _imageView.layer.masksToBounds = NO;
                                    _imageView.layer.shadowOffset = CGSizeMake(0, 0);
                                    _imageView.layer.shadowRadius = 4;
                                    _imageView.layer.shadowOpacity = 0.4;
                                    _imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_imageView.bounds].CGPath;
                                    _imageView.layer.cornerRadius = 9.0;
                                    
                                    //[self imgToFullScreen:nil];
                                    [self performSelector:@selector(imgToFullScreen:) withObject:nil afterDelay:.5];
                                    [_imageIndicator stopAnimating];
                                    
                                }
                            }progressBlock:^(int percentDone) {
                                //self.picProgressBar.hidden = false;
                                //self.picProgressBar.progress = percentDone;
                                NSLog(@"ok percent done: %d",percentDone);
                            }];
                        }
                    }];
                }];
            }
        }];
        
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (
                                                 moviePath, nil, nil, nil);
        }
    }
    
    // dismisses the View controller:
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imgToFullScreen:(UITapGestureRecognizer*)sender {
    if (isPicThere){
        //self.picProgressBar.hidden = true;
        if (!isFullScreen) {
            [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
                //save previous frame
                prevFrame = _imageView.frame;
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenRect.size.width;
                CGFloat screenHeight = screenRect.size.height;
                //[_imageView setFrame:[[UIScreen mainScreen] bounds]];
                [_imageView setFrame:CGRectMake(0, 20, screenWidth, screenHeight-100)];
                self.view.backgroundColor = [UIColor darkGrayColor];
                _giveAPic.textColor = [UIColor darkGrayColor];
                _getAPic.textColor = [UIColor darkGrayColor];
                _andLabel.textColor = [UIColor darkGrayColor];
                _doneButton.backgroundColor = [UIColor darkGrayColor];
                [_doneButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                [_doneButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

            }completion:^(BOOL finished){
                isFullScreen = TRUE;
            }];
            _imageView.layer.shadowOpacity = 0;
            _downloadPicture.hidden = NO;
            _shareButton.hidden = NO;
            _logoButton.hidden = YES;
            _cameraButton.hidden = YES;
            _useExistingButton.hidden = YES;
            _doneButton.hidden = YES;
            _otherGetPicButton.hidden = YES;
            _flagButton.hidden = NO;
            //_successMessage.hidden = YES;
            return;
        }
        else{
            [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
                [_imageView setFrame:prevFrame];
                self.view.backgroundColor = [self colorWithHexString:@"ec9695"];
                _giveAPic.textColor = [UIColor whiteColor];
                _andLabel.textColor = [UIColor whiteColor];
                _getAPic.textColor = [UIColor whiteColor];
                _doneButton.backgroundColor = [self colorWithHexString:@"566380"];
                [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_doneButton setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];

            }completion:^(BOOL finished){
                isFullScreen = FALSE;
            }];
            _imageView.layer.shadowOpacity = 0.4;
            _downloadPicture.hidden = YES;
            _shareButton.hidden = YES;
            _logoButton.hidden = NO;
            _cameraButton.hidden = NO;
            _useExistingButton.hidden = NO;
            _doneButton.hidden = NO;
            _otherGetPicButton.hidden = NO;
            _flagButton.hidden = YES;
            return;
        }
    }
}
- (IBAction)downloadPictureClicked:(id)sender {
    NSLog(@"downloading pic");
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Camera Roll"
                                                   message: @"Image saved to Camera Roll"
                                                  delegate: self
                                         cancelButtonTitle:@"Okay"
                                         otherButtonTitles:nil,nil];
    
    
    
    UIImageWriteToSavedPhotosAlbum(_imageView.image, nil, nil, nil);
    
    [alert show];
}
- (IBAction)shareButtonClicked:(id)sender {
    NSLog(@"Sharing image");
    
    NSString *text = @"Look at this SILLY image! #GiveAndGet bit.ly/1r0Gbn0";
    
    UIImage *image = _imageView.image;
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, image]
     applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)logoClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Hello"
                                                   message: @"This silly little app was written by Zach Lucas!"
                                                  delegate: self
                                         cancelButtonTitle:@"Okey Dokey"
                                         otherButtonTitles:nil,nil];
    
    
    [alert show];
}
- (IBAction)flagButtonClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Flag User"
                                                   message: @"Are you sure that you want to flag this content as inappropriate?"
                                                  delegate: self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Yes"])
    {
        NSLog(@"Yes was selected.");
        
        PFUser* userToDelete = [PFQuery getUserObjectWithId:_userIDFromPic];
        NSLog(@"user to flag: %@",userToDelete.username);
        // Mods will delete users that are flagged:
        userToDelete[@"flagged"] = @"flagged";
        [userToDelete saveInBackground];
    }
    else if([title isEqualToString:@"No"])
    {
        NSLog(@"Button 2 was selected.");
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

@end
