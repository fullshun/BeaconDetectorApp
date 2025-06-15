#import <UIKit/UIKit.h>
#import "BeaconDataManager.h"
#import "BeaconDetection.h"

@interface BeaconHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<BeaconDetection *> *detections;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;

@end