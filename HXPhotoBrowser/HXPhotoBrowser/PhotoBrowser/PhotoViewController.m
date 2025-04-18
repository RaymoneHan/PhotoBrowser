//
//  PhotoViewController.m
//  HXPhotoBrowser
//
//  Created by hanx on 16/8/29.
//  Copyright © 2016年 hanx. All rights reserved.
//
#define kIsFullWidthForLandScape YES
//图片缩放比例
#define kMinZoomScale 0.5f
#define kMaxZoomScale 2.0f
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "PhotoViewController.h"
#import "ProgressCircle.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface PhotoViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic,copy) NSString *imageStr;
@property (nonatomic,strong) UIImage *placeHolder;
@property (nonatomic,assign) BOOL isLoaded;
@property (nonatomic,strong) UIScrollView *backScroller;
@property (nonatomic, strong) ProgressCircle *progressCircle;

@end

@implementation PhotoViewController

#pragma mark - 构造函数

- (instancetype)initWithImage:(NSString *)imageStr index:(NSInteger)index
{
    return [self initWithImage:imageStr index:index placeHoldImage:nil];
}
- (instancetype)initWithImage:(NSString *)imageStr index:(NSInteger)index placeHoldImage:(UIImage*)image
{
    self = [super init];
    if (self) {
        self.index = index;
        self.imageStr = imageStr;
        self.placeHolder = image;
    }
    return self;
}

#pragma mark - LifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self loadImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - PrivateMethods

-(void)prepareUI{
    self.isLoaded = NO;
    self.backScroller = [[ UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.backScroller];
    self.backScroller.delegate = self;
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.imageView setBackgroundColor:[UIColor lightGrayColor]];
    self.imageView.image = self.placeHolder;
    [self.backScroller addSubview:self.imageView];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    [self.view addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:doubleTap];
    [self adjustFrames];
    [self.view addSubview:self.progressCircle];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    
    [self.view addGestureRecognizer:longPress];
}

-(void)loadImage{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageStr] placeholderImage:self.placeHolder options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        self.progressCircle.progress = receivedSize/(float)expectedSize;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self.progressCircle removeFromSuperview];
        [self adjustFrames];
        self.isLoaded = YES;
    }];
}

- (void)adjustFrames
{
    CGRect frame = self.backScroller.frame;
    if (self.imageView.image) {
        CGSize imageSize = self.imageView.image.size;
        CGRect imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        if (kIsFullWidthForLandScape) {
            CGFloat ratio = frame.size.width/imageFrame.size.width;
            imageFrame.size.height = imageFrame.size.height*ratio;
            imageFrame.size.width = frame.size.width;
        } else{
            if (frame.size.width<=frame.size.height) {
                
                CGFloat ratio = frame.size.width/imageFrame.size.width;
                imageFrame.size.height = imageFrame.size.height*ratio;
                imageFrame.size.width = frame.size.width;
            }else{
                CGFloat ratio = frame.size.height/imageFrame.size.height;
                imageFrame.size.width = imageFrame.size.width*ratio;
                imageFrame.size.height = frame.size.height;
            }
        }
        
        self.imageView.frame = imageFrame;
        self.backScroller.contentSize = self.imageView.frame.size;
        self.imageView.center = [self centerOfScrollViewContent:self.backScroller];
        
        
        CGFloat maxScale = frame.size.height/imageFrame.size.height;
        maxScale = frame.size.width/imageFrame.size.width>maxScale?frame.size.width/imageFrame.size.width:maxScale;
        maxScale = maxScale>kMaxZoomScale?maxScale:kMaxZoomScale;
        
        self.backScroller.minimumZoomScale = kMinZoomScale;
        self.backScroller.maximumZoomScale = maxScale;
        self.backScroller.zoomScale = 1.0f;
    }else{
        frame.origin = CGPointZero;
        self.imageView.frame = CGRectMake(0, (ScreenHeight - ScreenWidth) * 0.5, ScreenWidth, ScreenWidth);
        self.backScroller.contentSize = self.imageView.frame.size;
    }
    self.backScroller.contentOffset = CGPointZero;
    
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                       scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

-(ProgressCircle *)progressCircle{
    if (!_progressCircle) {
        _progressCircle = [[ProgressCircle alloc]initWithFrame:CGRectMake((ScreenWidth - 50)*0.5, (ScreenHeight - 50)*0.5, 50, 50)];
        [_progressCircle setBackgroundColor:[UIColor clearColor]];
    }
    return _progressCircle;
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *message = (error == nil) ? @"保存成功" : @"保存失败";
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil,nil];
//    [alert show];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btn = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler: nil];
    [alert addAction:btn];
    [self presentViewController:alert animated:true completion:nil];
    
}

- (void)saveImage {
    NSString *key = self.imageStr;
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

- (void)showTipsView {
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"无法保存" message:@"请到“设置”－“隐私”－“照片”选项中允许本应用访问您的照片" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:@"立即前往",nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法保存" message:@"请到“设置”－“隐私”－“照片”选项中允许本应用访问您的照片" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btn = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler: nil];
    [alert addAction:btn];
    
    UIAlertAction *go = [UIAlertAction actionWithTitle:@"立即前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:[[UIDevice currentDevice].systemVersion floatValue] >= 8.0 ? UIApplicationOpenSettingsURLString : @"prefs:root=photos"];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }];
    [alert addAction:go];
    [self presentViewController:alert animated:true completion:nil];
}

-(BOOL)isAuthor{
    PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus ];
    if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}


#pragma mark - Actions

-(void)tapImage:(UITapGestureRecognizer *)recognizer{
    if ([self.delegate respondsToSelector:@selector(imageDidClick)]) {
        if (self.backScroller.zoomScale > 1.0) {
            [self.backScroller setZoomScale:1.0 animated:YES];
        }
        [self.delegate imageDidClick];
    }
}

- (void)doubleTap:(UIGestureRecognizer *)recognizer{
    if (!self.isLoaded) {
        return;
    }
    CGPoint touchPoint = [recognizer locationInView:self.view];
    if (self.backScroller.zoomScale <= 1.0) {
        
        CGFloat scaleX = touchPoint.x + self.backScroller.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + self.backScroller.contentOffset.y;//需要放大的图片的Y点
        [self.backScroller zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
        
    } else {
        [self.backScroller setZoomScale:1.0 animated:YES]; //还原
    }
    
}

- (void)longPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSString *key = self.imageStr;
        UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
        
        if (image != nil){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法保存" message:@"请到“设置”－“隐私”－“照片”选项中允许本应用访问您的照片" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *btn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler: nil];
            [alert addAction:btn];
            
            UIAlertAction *go = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self saveImageAction];
            }];
            [alert addAction:go];
            [self presentViewController:alert animated:true completion:nil];
            
        }
    }
}

- (void)saveImageAction {
    if ([self isAuthor]) {
        [self saveImage];
    }else{
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            __weak typeof(self)weakSelf = self;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [weakSelf saveImage];
                } else {
                    [weakSelf showTipsView];
                }
            }];
        } else {
            [self showTipsView];
        }
    }
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    self.imageView.center = [self centerOfScrollViewContent:scrollView];
}

@end
