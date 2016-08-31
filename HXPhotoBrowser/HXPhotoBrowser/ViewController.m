//
//  ViewController.m
//  HXPhotoBrowser
//
//  Created by hanx on 16/8/29.
//  Copyright © 2016年 hanx. All rights reserved.
//

#import "ViewController.h"
#import "PhotoBrowserViewController.h"


@interface ViewController ()

@property (nonatomic,strong) NSArray *arrayImageUrlStr;

@property (nonatomic,strong) NSMutableArray *arrayViews;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    float topMargin = 60;
    float margin = 20;
    float size = ([UIScreen mainScreen].bounds.size.width - 4 * 20) / 3;
    for (int i = 0; i < self.arrayImageUrlStr.count; i++) {
        int row = i / 3;
        int col = i % 3;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(margin + (margin + size) * col, topMargin + (margin + size) * row, size, size)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.tag = i;
        NSString *urlStr = self.arrayImageUrlStr[i];
        imageView.userInteractionEnabled = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:[urlStr stringByReplacingOccurrencesOfString:@".jpg" withString:@"_1107-602.jpg"]] placeholderImage:nil options:SDWebImageRetryFailed];
        [self.view addSubview:imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getBigPic:)];
        [imageView addGestureRecognizer:tap];
        [self.arrayViews addObject:imageView];
    }
    
}


- (void)getBigPic:(UIGestureRecognizer *)recognizer{
    recognizer.view.hidden = YES;
    UIView *backView = [[UIView alloc]initWithFrame:self.view.bounds];
    backView.alpha = 0.0;
    backView.backgroundColor = [UIColor blackColor];
    [UIView animateWithDuration:0.3 animations:^{
        backView.alpha = 1.0;
    }];
    [self.view addSubview:backView];
    PhotoBrowserViewController *photoViewController = [PhotoBrowserViewController photoBrowserWithSelectedIndex:recognizer.view.tag urls:self.arrayImageUrlStr parentImageViews:self.arrayViews];
  
    [self presentViewController:photoViewController animated:YES completion:^{
        recognizer.view.hidden = NO;
        [backView removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(NSMutableArray *)arrayViews{
    if(!_arrayViews){
        _arrayViews = [NSMutableArray array];
    }
    return _arrayViews;
}

-(NSArray *)arrayImageUrlStr{
    if (!_arrayImageUrlStr) {//_1107-602
        _arrayImageUrlStr = @[@"http://www.sinaimg.cn/dy/slidenews/4_img/2016_35/704_2002418_397006.gif",
                              @"http://pic.sjjiasu.com/upload/20160818/14/57b5551b00094.jpg",
                              @"http://pic.sjjiasu.com/upload/20160818/14/57b554f489a29.jpg",
                              @"http://pic.sjjiasu.com/upload/20160818/14/57b55544c4e10.jpg",
                              @"http://pic.sjjiasu.com/upload/20160818/14/57b551ba98c01.jpg",
                              @"http://pic.sjjiasu.com/upload/20160818/13/57b54b1d52086.jpg",
                              @"http://pic.sjjiasu.com/upload/20160818/14/57b55352b58ea.jpg",
                              @"http://img5.duitang.com/uploads/item/201503/14/20150314134158_exzJM.thumb.224_0.jpeg"];
    }
    return _arrayImageUrlStr;
}


@end
