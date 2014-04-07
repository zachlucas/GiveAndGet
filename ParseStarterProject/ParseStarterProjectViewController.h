#import <Accounts/Accounts.h>

@interface ParseStarterProjectViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *messageText;
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UILabel *sentBy;
@property (strong, nonatomic) IBOutlet UILabel *sentHeader;
@property (strong, nonatomic) IBOutlet UILabel *charCounter;

@property(nonatomic) UIReturnKeyType returnKeyType;

@property (strong, nonatomic) IBOutlet UIViewController *picSender;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *sendingAs;
@property (strong, nonatomic) IBOutlet UITextView *mainTextView;

@end
