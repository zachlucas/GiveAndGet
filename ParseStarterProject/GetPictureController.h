//
//  GetPictureController.h
//  GiveAndGet
//
//  Created by Zach Lucas on 4/1/14.
//
//

#import <UIKit/UIKit.h>


@interface GetPictureController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *displayPicView;

@end
