//
//  GetPictureController.h
//  GiveAndGet
//
//  Created by Zach Lucas on 4/1/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface GetPictureController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>{
    
    UITapGestureRecognizer *tap;
    BOOL isFullScreen;
    CGRect prevFrame;
}
@property (weak, nonatomic) IBOutlet UIImageView *displayPicView;
@property (strong, nonatomic) IBOutlet UILabel *successMessage;
@property (nonatomic, strong) UIImageView *imageView;

@property (strong, nonatomic) NSString *usernameToSendWithPic;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageIndicator;
@property (strong, nonatomic) IBOutlet UILabel *giveAPic;
@property (strong, nonatomic) IBOutlet UILabel *andLabel;
@property (strong, nonatomic) IBOutlet UILabel *getAPic;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@end
