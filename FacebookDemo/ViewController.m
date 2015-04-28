//
//  ViewController.m
//  FacebookDemo
//
//  Created by Rohan Sonawane on 18/04/15.
//  Copyright (c) 2015 Rohan. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "PhotosViewController.h"
#import "VideosViewController.h"

@interface ViewController ()
{
    __weak IBOutlet UIButton *loginWithFacebookButton;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [loginWithFacebookButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [loginWithFacebookButton.layer setBorderWidth:0.5f];
    [loginWithFacebookButton.layer setCornerRadius:4.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --------------------------------------------------------------
#pragma mark Button Actions
#pragma mark --------------------------------------------------------------
- (IBAction)loginWithFacebookAction:(id)sender {
    
    [activityIndicator startAnimating];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"user_photos", @"user_videos"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            [activityIndicator stopAnimating];
            if([[[error userInfo] allKeys]containsObject:@"com.facebook.sdk:FBSDKErrorDeveloperMessageKey"])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please make sure you've added \"Facebook App ID\" in your project's info.plist file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else{
                // Process error
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured while logging into facebook, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
        } else if (result.isCancelled) {
            [activityIndicator stopAnimating];

            // Handle cancellations
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"User Cancelled" message:@"User cancelled facebook login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        } else {
            //success
            [self getUserPhotos];
        }
    }];
}


- (void)getUserPhotos
{
    [self checkPhotosPermissions:^(BOOL hasGranted) {
       if(hasGranted)
       {
           [loginWithFacebookButton setUserInteractionEnabled:FALSE];
           
           NSDictionary *parameters = @{@"limit": @"10000", @"offset": [NSString stringWithFormat:@"%d", 0]};
           
           [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos/uploaded?fields=images" parameters: parameters]
            startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                [loginWithFacebookButton setUserInteractionEnabled:TRUE];
                [activityIndicator stopAnimating];
                
                if (!error) {
                    //             NSLog(@"fetched user:%@", result);
                    NSDictionary *resultDictionary = (NSDictionary *)result;
                    NSArray *dataArray = (NSArray *)[resultDictionary objectForKey:@"data"];
                    
                    NSMutableArray *imagesLinkArray = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *imageDictionary in dataArray) {
                        NSArray *imageArray = [imageDictionary objectForKey:@"images"];
                        NSDictionary *topImageDictionary = [imageArray objectAtIndex:0];
                        [imagesLinkArray addObject:[topImageDictionary objectForKey:@"source"]];
                    }
                    //             NSLog(@"imagesLinkArray: %@", imagesLinkArray);
                    if([imagesLinkArray count])
                    {
                        PhotosViewController *photosViewController = [[PhotosViewController alloc] initWithNibName:@"PhotosViewController" bundle:nil WithImageLinkArray:imagesLinkArray];
                        [photosViewController.tabBarItem setTitle:@"Photos"];
                        
                        VideosViewController *videosViewController = [[VideosViewController alloc] initWithNibName:@"VideosViewController" bundle:nil];
                        [videosViewController.tabBarItem setTitle:@"Videos"];
                        
                        
                        UITabBarController *tabBarController = [[UITabBarController alloc] init];
                        [tabBarController setViewControllers:[NSArray arrayWithObjects:photosViewController, videosViewController, nil]];
                        [tabBarController.tabBar setTranslucent:TRUE];
                        [tabBarController.tabBar setBarStyle:UIBarStyleBlack];
                        [tabBarController.tabBar setBackgroundColor:[UIColor clearColor]];
                        [tabBarController.tabBar setTintColor:[UIColor whiteColor]];
                        [tabBarController setSelectedIndex:0];
                        
                        [self presentViewController:tabBarController animated:TRUE completion:NULL];
                    }
                    else
                    {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Photos" message:@"There are no photos on your facebook account." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }
                else
                {
                    NSLog(@"error: %@", error);
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured while fetching your facebook photos, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
       }
    }];
}

- (void)checkPhotosPermissions:(void (^)(BOOL hasGranted))completion
{
    if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"user_photos"]) {
        [activityIndicator startAnimating];
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"user_photos"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
            [activityIndicator stopAnimating];
            
            if(!error && [result.grantedPermissions containsObject:@"user_photos"])
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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An error while accessing photos permissions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                completion(FALSE);
            }
        }];
    }
    else{
        completion(TRUE);
    }
}


@end
