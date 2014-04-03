//
//  GetPictureController.h
//  GiveAndGet
//
//  Created by Zach Lucas on 4/1/14.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface GetPictureController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *displayPicView;
@property (strong, nonatomic) IBOutlet UILabel *successMessage;

@end
