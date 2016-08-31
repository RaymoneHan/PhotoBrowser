//
//  PhotoBrowserAnimator.m
//  HXPhotoBrowser
//
//  Created by hanx on 16/8/29.
//  Copyright © 2016年 hanx. All rights reserved.
//

#import "PhotoBrowserAnimator.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface PhotoBrowserAnimator()<UIViewControllerAnimatedTransitioning>

@end

@implementation PhotoBrowserAnimator{
    BOOL _isPresenting;
    PhotoBrowserPhotos *_photos;
}

#pragma mark - 构造函数
+ (instancetype)animatorWithPhotos:(PhotoBrowserPhotos *)photos {
    return [[self alloc] initWithPhotos:photos];
}

- (instancetype)initWithPhotos:(PhotoBrowserPhotos *)photos {
    self = [super init];
    if (self) {
        _photos = photos;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    _isPresenting = YES;
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    _isPresenting = NO;
    
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    _isPresenting ? [self presentTransition:transitionContext] : [self dismissTransition:transitionContext];
}

#pragma mark - 展现转场动画方法
- (void)presentTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    
    UIImageView *dummyIV = [self dummyImageView];
    UIImageView *parentIV = [self parentImageView];
    dummyIV.frame = [containerView convertRect:parentIV.frame fromView:parentIV.superview];
    [containerView addSubview:dummyIV];
    UIView *toView ;
    if ([[UIDevice currentDevice].systemVersion floatValue]<8.0) {
        UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        toView = toController.view;
    }else{
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    }
    
    [containerView addSubview:toView];
    toView.alpha = 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        dummyIV.frame = [self presentRectWithImageView:dummyIV];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [dummyIV removeFromSuperview];
            
            [transitionContext completeTransition:YES];
        }];
    }];
}

#pragma mark - PrivateMethods

- (CGRect)presentRectWithImageView:(UIImageView *)imageView {
    UIImage *image = imageView.image;
    
    if (image == nil) {
        return CGRectMake(0, (ScreenHeight - ScreenWidth) * 0.5, ScreenWidth, ScreenWidth);
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize imageSize = screenSize;
    
    imageSize.height = image.size.height * imageSize.width / image.size.width;
    
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    
    if (imageSize.height < screenSize.height) {
        rect.origin.y = (screenSize.height - imageSize.height) * 0.5;
    }
    
    return rect;
}

- (UIImageView *)dummyImageView {
    UIImage *image = [self dummyImage];
    UIImageView *iv;
    if (image) {
        iv = [[UIImageView alloc] initWithImage:image];
    }else{
        iv= [[UIImageView alloc]initWithFrame:CGRectMake(0, (ScreenHeight - ScreenWidth) * 0.5, ScreenWidth, ScreenWidth)];
        iv.backgroundColor = [UIColor lightGrayColor];
    }
    
    
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    
    return iv;
}

- (UIImage *)dummyImage {
    
    NSString *key = _photos.urls[_photos.selectedIndex];
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    
    if (image == nil) {
        image = _photos.parentImageViews[_photos.selectedIndex].image;
    }
    return image;
}

- (UIImageView *)parentImageView {
    return _photos.parentImageViews[_photos.selectedIndex];
}

#pragma mark - 解除转场动画方法
- (void)dismissTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    UIView *fromView;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        fromView = fromController.view;
    }else{
        fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    }
    UIImageView *dummyIV = [self dummyImageView];
    dummyIV.frame = [containerView convertRect:_fromImageView.frame fromView:_fromImageView.superview];
    dummyIV.alpha = fromView.alpha;
    [containerView addSubview:dummyIV];
    
    [fromView removeFromSuperview];
    
    UIImageView *parentIV = [self parentImageView];
    CGRect targetRect = [containerView convertRect:parentIV.frame fromView:parentIV.superview];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        dummyIV.frame = targetRect;
        dummyIV.alpha = 1.0;
    } completion:^(BOOL finished) {
        [dummyIV removeFromSuperview];
        
        [transitionContext completeTransition:YES];
    }];
}


@end
