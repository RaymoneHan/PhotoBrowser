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
    if (!_arrayImageUrlStr) {
        _arrayImageUrlStr = @[@"https://cdn.kekeyuyin.com/test/album/62b6fc7abbc37b6e61919f81a2f83388.png",
                              @"https://cdn.kekeyuyin.com/15291719991745_.pic.jpg",
                              @"https://cdn.kekeyuyin.com/test/album/0c1e7d01db80e4e5c6b1850d334792a6.png",
                              @"https://cdn.kekeyuyin.com/test/album/12bc983025e41c626b7ff71c7502b91d.png",
                              @"https://cdn.kekeyuyin.com/test/album/36f37ea1c58550de6b2e35ba1c965baf.png",
                              @"https://cdn.kekeyuyin.com/test/album/4006cf3f147d98dae45062b21380342e.png",
                              @"https://cdn.kekeyuyin.com/test/album/52e52bb051e6806ca159ada0341bc309.png",
                              @"https://cdn.kekeyuyin.com/test/album/576ce7a36c4a83f346ffb6e83a1ae40c.png"];
    }
    return _arrayImageUrlStr;
}


@end
