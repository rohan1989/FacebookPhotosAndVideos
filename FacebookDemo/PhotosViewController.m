//
//  PhotosAndvideoViewController.m
//  FacebookDemo
//
//  Created by Rohan Sonawane on 20/04/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import "PhotosViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface PhotosViewController ()
{
    NSArray *imagesLinkArray;
    __weak IBOutlet UIScrollView *photosScrollView;
    __weak IBOutlet UILabel *swipeForMoreLabel;
    
}
@end

@implementation PhotosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil WithImageLinkArray:(NSArray *)_imageLinkArray
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        imagesLinkArray = [[NSArray alloc] initWithArray:_imageLinkArray];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if([imagesLinkArray count] > 1)
    {
        [swipeForMoreLabel setHidden:FALSE];
    }
    [self initializeView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir-Light" size:30.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

- (void)initializeView
{
    CGFloat imageX = 10.0f;
    for (NSString *imageLink in imagesLinkArray) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setFrame:CGRectMake(imageX, 20.0f, [[UIScreen mainScreen] bounds].size.width - 20, photosScrollView.frame.size.height - 69)];
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setFrame:CGRectMake(0, 0, 200, 200)];
        [imageView addSubview:activityIndicatorView];
        activityIndicatorView.center = CGPointMake(imageView.center.x - 10, imageView.center.y - 10);
        [activityIndicatorView startAnimating];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageLink] placeholderImage:nil options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [activityIndicatorView stopAnimating];
            if(error)
            {
                NSLog(@"Error: %@", error);
            }
        }];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [self addShadow:imageView.layer];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [photosScrollView addSubview:imageView];
        imageX+=[[UIScreen mainScreen] bounds].size.width;
    }
    
    [photosScrollView setContentSize:CGSizeMake((([[UIScreen mainScreen] bounds].size.width) * [imagesLinkArray count]), photosScrollView.frame.size.height - 69)];
}


- (void)addShadow:(CALayer *)_layer
{
    _layer.masksToBounds = NO;
    _layer.shadowOffset = CGSizeMake(5, 5);
    _layer.shadowRadius = 5;
    _layer.shadowOpacity = 0.5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
