#import <Accounts/Accounts.h>

@interface ParseStarterProjectViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *messageText;
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UILabel *sentBy;
@property (strong, nonatomic) IBOutlet UILabel *sentHeader;
@property (strong, nonatomic) IBOutlet UILabel *charCounter;
@property (strong, nonatomic) IBOutlet UILabel *mainHeader;

@property(nonatomic) UIReturnKeyType returnKeyType;

@property (strong, nonatomic) IBOutlet UIViewController *picSender;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *sendingAs;
@property (strong, nonatomic) IBOutlet UITextView *mainTextView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *responseIndicator;
@property (strong, nonatomic) IBOutlet UIButton *customHandleButton;

@end
