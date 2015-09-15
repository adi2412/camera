/*
     File: APLViewController.m
 Abstract: Main view controller for the application.
  Version: 2.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "APLViewController.h"
#import "PhotoPicker-Swift.h"


@interface APLViewController ()

@property SocketIOClient *socket;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic, weak) NSTimer *cameraTimer;
@property (nonatomic) NSMutableArray *capturedImages;


@end



@implementation APLViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.capturedImages = [[NSMutableArray alloc] init];
    
    self.socket = [[SocketIOClient alloc] initWithSocketURL:@"192.168.0.100:3000" opts:nil];
    [self addSocketEventHandlers];
    [self connectSocket];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.showsCameraControls = NO;
    self.imagePickerController = imagePickerController;
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

-(void)addSocketEventHandlers
{
    [self.socket onObjectiveC:@"connect" callback:^(NSArray* data, void (^ack)(NSArray*)) {
        NSLog(@"socket connected");
    }];
    
    [self.socket onObjectiveC:@"clickPic" callback:^(NSArray* data, void (^ack)(NSArray*)){
        NSLog(@"clicking picture");
        [self.imagePickerController takePicture];
    }];
    
    [self.socket onObjectiveC:@"download" callback:^(NSArray *data, void (^ack)(NSArray*)){
        NSLog(@"Download event");
        NSData *imageData = [[NSData alloc] init];
        imageData = UIImagePNGRepresentation([self.capturedImages objectAtIndex:0]);
        NSString *imageBase64 = [imageData base64EncodedStringWithOptions:0];
        [self.socket emit:@"upload" withItems:@[@{@"image":imageBase64}]];
    }];
}

- (void)connectSocket
{
    [self.socket connect];
}

#pragma mark - Timer

// Called by the timer to take a picture.
- (void)timedPhotoFire:(NSTimer *)timer
{
    [self.imagePickerController takePicture];
}


#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Deciding what to do with pic");
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

    [self.capturedImages addObject:image];

    if ([self.cameraTimer isValid])
    {
        return;
    }

    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end

