#import <UIKit/UIKit.h>
#import "BeaconManager.h"
#import "BeaconHistoryViewController.h"

@interface ViewController : UIViewController <BeaconManagerDelegate>

@property (nonatomic, strong) BeaconManager *beaconManager;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *toggleDetectionButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;

@end