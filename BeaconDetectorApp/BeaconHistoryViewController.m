#import "BeaconHistoryViewController.h"

@interface BeaconHistoryViewController ()

@end

@implementation BeaconHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"検知履歴";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"クリア" style:UIBarButtonItemStylePlain target:self action:@selector(clearHistoryTapped:)];
    
    [self loadDetections];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDetections];
}

- (void)loadDetections {
    self.detections = [[BeaconDataManager sharedManager] getAllDetections];
    [self.tableView reloadData];
}

- (void)setupTableView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (IBAction)clearHistoryTapped:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"履歴削除" message:@"すべての検知履歴を削除しますか？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"削除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[BeaconDataManager sharedManager] clearAllDetections];
        [self loadDetections];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.detections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HistoryCell"];
    }
    
    BeaconDetection *detection = self.detections[indexPath.row];
    
    // メインテキスト：UUID/Major/Minor
    cell.textLabel.text = [NSString stringWithFormat:@"UUID: %@\nMajor: %@, Minor: %@", 
                          detection.uuid, detection.major, detection.minor];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
    // サブテキスト：検知日時とRSSI/距離
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"ja_JP"];
    
    NSString *dateString = [formatter stringFromDate:detection.detectedAt];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nRSSI: %ld, 距離: %.2fm", 
                                dateString, (long)detection.rssi, detection.accuracy];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end