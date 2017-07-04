//
//  ViewController.h
//  GoogleDriveDemo
//
//  Created by dharmesh  on 6/26/17.
//  Copyright © 2017 dharmesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/SignIn.h>
#import <GTLRDrive.h>


@interface ViewController : UIViewController<GIDSignInDelegate, GIDSignInUIDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) IBOutlet GIDSignInButton *signInButton;
@property (nonatomic, strong) UITextView *output;
@property (nonatomic, strong) GTLRDriveService *service;
@property (strong, nonatomic) IBOutlet UITableView *tblFileList;



@end

