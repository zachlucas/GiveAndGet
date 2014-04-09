//
//  GetPictureController.m
//  GiveAndGet
//
//  Created by Zach Lucas on 4/1/14.
//
//

#import "GetPictureController.h"
#import <MobileCoreServices/UTCoreTypes.h>


@interface GetPictureController ()

@end

@implementation GetPictureController

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

    /*
    // Getting an image:
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query getObjectInBackgroundWithId:@"TqfX0R51sh" block:^(PFObject *textdu, NSError *error) {
             // do your thing with text
             if (!error) {
                 PFFile *imageFile = [textdu objectForKey:@"imageFile"];
                 [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                     if (!error) {
                         UIImage *image = [UIImage imageWithData:data];
                         _displayPicView.image = image;
                     }
                 }];
             }
         }];
    */
    
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
        _displayPicView.contentMode = UIViewContentModeScaleAspectFit;
        
        // Compressing the image:
        //NSData *imageData = UIImagePNGRepresentation(imageToSave);
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
        
        // Setting the other attributes:
        userPhoto[@"imageFile"] = imageFile;
        userPhoto[@"seen"] = @"no";
        // Sending the image:
        [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            _successMessage.text = @"Sent! Here's your response:";
            //_displayPicView.image = imageToSave;
            
            PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
            [query whereKey:@"seen" equalTo:@"no"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSLog(@"size:%lu",(unsigned long)[objects count]);
                    NSLog(@"%@",[[objects objectAtIndex:[objects count]-1] objectId]);
                    
                    [query getObjectInBackgroundWithId:[[objects objectAtIndex:[objects count]-1] objectId] block:^(PFObject *textdu, NSError *error) {
                        if (!error) {
                            PFFile *imageFile = [textdu objectForKey:@"imageFile"];
                            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                if (!error) {
                                    UIImage *image = [UIImage imageWithData:data];
                                    _displayPicView.image = image;
                                    
                                    
                                    [query getObjectInBackgroundWithId:[[objects objectAtIndex:[objects count]-1] objectId] block:^(PFObject *changeToSeen, NSError *error) {
                                        
                                        // Now let's update it with some new data. In this case, only cheatMode and score
                                        // will get sent to the cloud. playerName hasn't changed.
                                        
                                        changeToSeen[@"seen"] = @"yes";
                                        [changeToSeen saveInBackground];
                                        // TODO:  Fix this!!!
                                        if (error){
                                            [changeToSeen saveInBackground];
                                        }
                                    }];
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                    
                                }
                            }];
                        }
                    }];
                }
            }];
            
            [_imageIndicator stopAnimating];
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

@end
