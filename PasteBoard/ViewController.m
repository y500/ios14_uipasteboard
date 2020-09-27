//
//  ViewController.m
//  PasteBoard
//
//  Created by wentian on 2020/9/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat pointY = 100;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, pointY, self.view.frame.size.width - 20, 60)];
    label1.textColor = [UIColor blackColor];
    label1.text = @"9👈幅治内容 Http:/T$AJg8c4IfW3q$打開👉绹..寶👈【贵州茅台酒 茅台 飞天53度酱香型白酒收藏 500ml*1单瓶装送礼高度】";
    label1.numberOfLines = 0;
    label1.adjustsFontSizeToFitWidth = YES;
    label1.tag = 1001;
    [self.view addSubview:label1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"check" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(10, pointY+70, self.view.frame.size.width - 20, 60);
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 2;
    button.layer.borderColor = [[UIColor greenColor] CGColor];
    [button addTarget:self action:@selector(pasteBoardCheckTaobao) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, pointY + 150, self.view.frame.size.width - 20, 40)];
    label2.textColor = [UIColor blackColor];
    label2.text = @"1 http:/123abc";
    label2.tag = 1002;
    label2.numberOfLines = 0;
    label2.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:label2];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"check" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    button2.frame = CGRectMake(10, pointY+200, self.view.frame.size.width - 20, 60);
    button2.layer.borderWidth = 1;
    button2.layer.cornerRadius = 2;
    button2.layer.borderColor = [[UIColor greenColor] CGColor];
    [button2 addTarget:self action:@selector(pasteBoardCheckLike) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self pasteBoardCheckWithText:nil];
}

- (void)pasteBoardCheckTaobao {
    UILabel *label = (UILabel*)[self.view viewWithTag:1001];
    [self pasteBoardCheckWithText:label.text];
}

- (void)pasteBoardCheckLike {
    UILabel *label = (UILabel*)[self.view viewWithTag:1002];
    [self pasteBoardCheckWithText:label.text];
}

- (void)pasteBoardCheckWithText:(NSString *)text {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    
    if (text.length > 0) {
        [board setString:text];
    }
    
    [board detectPatternsForPatterns:[NSSet setWithObjects:UIPasteboardDetectionPatternProbableWebURL, UIPasteboardDetectionPatternNumber, UIPasteboardDetectionPatternProbableWebSearch, nil]
                   completionHandler:^(NSSet<UIPasteboardDetectionPattern> * _Nullable set, NSError * _Nullable error) {
        
        BOOL hasNumber = NO, hasURL = NO;
        for (NSString *type in set) {
            if ([type isEqualToString:UIPasteboardDetectionPatternProbableWebURL]) {
                hasURL = YES;
            } else if ([type isEqualToString:UIPasteboardDetectionPatternNumber]) {
                hasNumber = YES;
            }
        }
        
        if (hasNumber && hasURL) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"%@\n%@", [board string], @"符合淘宝的读取标准"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}


@end
