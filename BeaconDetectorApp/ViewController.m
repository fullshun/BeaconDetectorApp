#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ビーコン検出アプリ";
    
    self.beaconManager = [BeaconManager sharedManager];
    self.beaconManager.delegate = self;
    
    [self updateUI];
}

- (void)updateUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.beaconManager.isDetecting) {
            [self.toggleDetectionButton setTitle:@"検知停止" forState:UIControlStateNormal];
            self.statusLabel.text = @"ビーコン検知中...";
        } else {
            [self.toggleDetectionButton setTitle:@"検知開始" forState:UIControlStateNormal];
            self.statusLabel.text = @"準備完了";
        }
    });
}

- (IBAction)toggleDetectionTapped:(id)sender {
    if (self.beaconManager.isDetecting) {
        [self.beaconManager stopRangingBeacons];
    } else {
        [self.beaconManager requestLocationPermission];
        
        NSString *uuidString = @"D546DF97-4757-47EF-BE09-3E2DCBDD0C77";
        NSNumber *major = @53493;
        NSNumber *minor = @65407;
        [self.beaconManager startRangingBeaconsWithUUID:uuidString major:major minor:minor identifier:@"MyBeaconRegion"];
    }
}

- (IBAction)showHistoryTapped:(id)sender {
    BeaconHistoryViewController *historyVC = [[BeaconHistoryViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:historyVC];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - BeaconManagerDelegate

- (void)didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (beacons.count > 0) {
            self.statusLabel.text = [NSString stringWithFormat:@"%lu個のビーコンを検出中", (unsigned long)beacons.count];
        } else {
            self.statusLabel.text = @"ビーコン検知中...";
        }
    });
}

- (void)didEnterRegion:(CLRegion *)region {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = @"ビーコン領域に入りました";
    });
}

- (void)didExitRegion:(CLRegion *)region {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = @"ビーコン領域から出ました";
    });
}

- (void)didFailWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = [NSString stringWithFormat:@"エラー: %@", error.localizedDescription];
    });
}

- (void)detectionStatusChanged:(BOOL)isDetecting {
    [self updateUI];
}

@end