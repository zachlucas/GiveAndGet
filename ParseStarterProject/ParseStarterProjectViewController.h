@interface ParseStarterProjectViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *messageText;
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UILabel *sentBy;
@property (strong, nonatomic) IBOutlet UILabel *sentHeader;
@property (strong, nonatomic) IBOutlet UILabel *charCounter;

@property(nonatomic) UIReturnKeyType returnKeyType;

@property (strong, nonatomic) IBOutlet UIViewController *picSender;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@end
