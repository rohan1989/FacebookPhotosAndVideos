//
//  VideosViewController.m
//  FacebookDemo
//
//  Created by Rohan Sonawane on 20/04/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import "VideosViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface VideosViewController ()
{
    NSMutableArray *videosArray;
    __weak IBOutlet UIScrollView *videosScrollView;
    __weak IBOutlet UILabel *swipeForMoreLabel;
    
}
@end

@implementation VideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchFacebookVideos];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir-Light" size:30.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fetchFacebookVideos
{
    [self checkVideosPermissions:^(BOOL hasGranted) {
       if(hasGranted)
       {
           NSDictionary *parameters = @{@"limit": @"10000", @"offset": [NSString stringWithFormat:@"%d", 0]};
           [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/videos/uploaded" parameters: parameters]
            startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    videosArray = [[NSMutableArray alloc] init];
                    NSDictionary *resultDictionary = (NSDictionary *)result;
                    NSArray *dataArray = (NSArray *)[resultDictionary objectForKey:@"data"];
                    
                    for (NSDictionary *videoDictionary in dataArray) {
                        NSMutableDictionary *_videoDictionary = [[NSMutableDictionary alloc] init];
                        [_videoDictionary setObject:[videoDictionary objectForKey:@"source"] forKey:@"source"];
                        [_videoDictionary setObject:[videoDictionary objectForKey:@"picture"] forKey:@"thumbnail"];
                        [_videoDictionary setObject:[videoDictionary objectForKey:@"description"] forKey:@"description"];
                        [videosArray addObject:_videoDictionary];
                    }
                    [self initializeView];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error...." message:@"An error occured while fetching your facebook videos, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
       }
    }];
}

- (void)checkVideosPermissions:(void (^)(BOOL hasGranted))completion
{
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"user_videos"]) {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"user_videos"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
            if(!error && [result.grantedPermissions containsObject:@"user_videos"])
            {
                completion(TRUE);
            }
            else if (result.isCancelled)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Cancelled" message:@"User cancelled facebook login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                completion(FALSE);
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error while accessing videos permissions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                completion(FALSE);
            }
        }];
    }
    else{
        completion(TRUE);
    }
}


- (void)initializeView
{
    if([videosArray count] > 1)
    {
        [swipeForMoreLabel setHidden:FALSE];
    }
    
    CGFloat imageX = 10.0f;
    int videoCounter = 0;
    for (NSDictionary *videoDictionary in videosArray) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView setTag:videoCounter];
         videoCounter++;
        [imageView setFrame:CGRectMake(imageX, 20.0f, [[UIScreen mainScreen] bounds].size.width - 20, videosScrollView.frame.size.height - 69)];
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setFrame:CGRectMake(0, 0, 200, 200)];
        [imageView addSubview:activityIndicatorView];
        activityIndicatorView.center = CGPointMake(imageView.center.x - 10, imageView.center.y - 10);
        [activityIndicatorView startAnimating];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[videoDictionary objectForKey:@"thumbnail"]] placeholderImage:nil options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [activityIndicatorView stopAnimating];
            [self addPlayButton:imageView];
            if(error)
            {
                NSLog(@"Error: %@", error);
            }
        }];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setUserInteractionEnabled:TRUE];
        [self addShadow:imageView.layer];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [videosScrollView addSubview:imageView];
        imageX+=[[UIScreen mainScreen] bounds].size.width;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTapped:)];
        [tapGesture setNumberOfTapsRequired:1];
        [imageView addGestureRecognizer:tapGesture];
    }
    
    [videosScrollView setContentSize:CGSizeMake((([[UIScreen mainScreen] bounds].size.width) * [videosArray count]), videosScrollView.frame.size.height - 69)];
}

- (void)addPlayButton:(UIImageView *)_imageView
{
    UIButton *playButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    [playButton setBackgroundColor:[UIColor clearColor]];
    [playButton setTag:_imageView.tag];
    [playButton setFrame:CGRectMake(0, 0, 50, 50)];
    playButton.center = CGPointMake(_imageView.center.x - 10, _imageView.center.y - 10);
    [playButton setBackgroundImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:playButton];
}

- (void)addShadow:(CALayer *)_layer
{
    _layer.masksToBounds = NO;
    _layer.shadowOffset = CGSizeMake(5, 5);
    _layer.shadowRadius = 5;
    _layer.shadowOpacity = 0.5;
}

- (void)videoTapped:(UITapGestureRecognizer *)_tapGesture
{
    UIImageView *tappedImageView = (UIImageView *)[_tapGesture view];
//    NSLog(@"Tapped: %ld", (long)tappedImageView.tag);
    if(tappedImageView.tag < [videosArray count])
    {
        NSDictionary *videoDictionary = [videosArray objectAtIndex:tappedImageView.tag];
        NSString *urlString = [videoDictionary objectForKey:@"source"];
        if(urlString && [urlString length])
        {
            [self playVideoWithURL:urlString];
        }
    }
}

- (void)playButtonAction:(UIButton *)_playButton{
    if(_playButton.tag < [videosArray count])
    {
        NSDictionary *videoDictionary = [videosArray objectAtIndex:_playButton.tag];
        NSString *urlString = [videoDictionary objectForKey:@"source"];
        if(urlString && [urlString length])
        {
            [self playVideoWithURL:urlString];
        }
    }
}

- (void)playVideoWithURL:(NSString *)_urlString
{
    MPMoviePlayerViewController *moviePlayerviewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:_urlString]];
    [self presentMoviePlayerViewControllerAnimated:moviePlayerviewController];
    [moviePlayerviewController.moviePlayer play];
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
