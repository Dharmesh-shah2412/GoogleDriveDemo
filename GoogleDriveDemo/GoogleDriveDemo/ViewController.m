//
//  ViewController.m
//  GoogleDriveDemo
//
//  Created by dharmesh  on 6/26/17.
//  Copyright © 2017 dharmesh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSMutableArray *fileList,*indexPathAry;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    fileList = [NSMutableArray new];
    indexPathAry = [NSMutableArray new];
    // Configure Google Sign-in.
    GIDSignIn* signIn = [GIDSignIn sharedInstance];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    signIn.scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDriveReadonly, nil];
    [signIn signInSilently];
    
    // Add the sign-in button.
    self.signInButton = [[GIDSignInButton alloc] init];
    [self.view addSubview:self.signInButton];
    
    // Create a UITextView to display output.
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.output.hidden = true;
   // [self.view addSubview:self.output];
    
    // Create a UITableView to display output
    self.tblFileList = [[UITableView alloc] initWithFrame:CGRectMake(0,100 , self.view.frame.size.width, self.view.frame.size.height ) style:UITableViewStylePlain];
    
    [self.view addSubview:self.self.tblFileList];
    // Initialize the service object.
    self.service = [[GTLRDriveService alloc] init];

}
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    } else {
        self.signInButton.hidden = true;
        self.output.hidden = false;
        self.service.authorizer = user.authentication.fetcherAuthorizer;
        [self listFiles];
        
    }
}
// List up to 10 files in Drive
- (void)listFiles {
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.fields = @"nextPageToken, files(id, name)";
    query.pageSize = 10;
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// Process the response and display output
- (void)displayResultWithTicket:(GTLRServiceTicket *)ticket
             finishedWithObject:(GTLRDrive_FileList *)result
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *output = [[NSMutableString alloc] init];
        if (result.files.count > 0) {
            [output appendString:@"Files:\n"];
            __block int count = 0;
            for (GTLRDrive_File *file in result.files) {
               
                NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?key=xyz",
                                 file.identifier];
                GTMSessionFetcher *fetcher = [self.service.fetcherService fetcherWithURLString:url]; //GTLServiceDrive *service;
                [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                    if (error == nil) {
                        NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        if ([[dict valueForKey:@"mimeType"] isEqualToString:@"application/vnd.google-apps.folder"])
                        {
                           // [indexPathAry addObject:indexPath];
                            //                [fileList removeObjectAtIndex:indexPath.row];
                            //                [_tblFileList reloadData];
                        }
                        else
                        {
//                            [output appendFormat:@"%@ (%@)\n", file.name, file.identifier];
//                            NSDictionary *dictData = @{@"name":file.name,@"id":file.identifier};
                            
                            [fileList addObject:dict];
                            

                        }
                        count++;
                        if (count == result.files.count)
                        {
                            self.tblFileList.delegate = self;
                            self.tblFileList.dataSource = self;
                            [self.tblFileList reloadData];
                        }
                        
                    }}];
            }
        } else {
            [output appendString:@"No files found."];
        }
        self.output.text = output;
       
    } else {
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendFormat:@"Error getting presentation data: %@\n", error.localizedDescription];
        [self showAlert:@"Error" message:message];
    }
}


// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = [[fileList objectAtIndex:indexPath.row] valueForKey:@"name"];
    
        
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // datt
    

    
    
    
    
  //  GTLRDrive_File *myfile = ;//Your File Object
//    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?key=xyx",
//                     [[fileList objectAtIndex:indexPath.row] valueForKey:@"id"]];
//    GTMSessionFetcher *fetcher = [self.service.fetcherService fetcherWithURLString:url]; //GTLServiceDrive *service;
//    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
//        if (error == nil) {
//            //NSString *someString = [[NSString alloc] initWithData:fetcher.downloadedData encoding:NSUTF8StringEncoding] ;
//            NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//            NSString *fileName = [NSString stringWithFormat:@"%@",[dict valueForKey:@"name"]];
//            //[data writeToFile:filePath atomically:YES];
            NSString *urltest = [NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?alt=media",                      [[fileList objectAtIndex:indexPath.row] valueForKey:@"id"]];
//            //the ID of my file in a string identifier_file
//            
            GTMSessionFetcher *fetcher = [self.service.fetcherService fetcherWithURLString:urltest];  // the request
            
            // receive response and play it in web view:
            [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *errorrr) {
                if (errorrr == nil) {
                    NSLog(@"Retrieved file content");
                    //NSMutableDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[fileList objectAtIndex:indexPath.row] valueForKey:@"name"]];
                    [data writeToFile:filePath atomically:YES];
                    NSLog(@"%@", filePath);
                    //            [webView_screen loadData:data MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:nil]; //my file is a pdf
                    //            [webView_screen reload];
                    
                } else {
                    NSLog(@"An error occurred: %@", errorrr);
                }
            }];
            //NSLog(@"%@",someString);
            NSLog(@"Retrieved file content");
            // File Downloaded!
//        } else {
//            NSLog(@"An error occurred: %@", error);
//        }
//    }];
}
@end
