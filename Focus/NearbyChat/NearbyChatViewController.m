//
//  NearbyChatViewController.m
//  Focus
//
//  Created by Kevin Yang on 6/1/14.
//  Copyright (c) 2014 Kevin Yang. All rights reserved.
//

#import "NearbyChatViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

static NSString * const ServiceType = @"MultipeerDemo";

@interface NearbyChatViewController () <MCSessionDelegate, MCBrowserViewControllerDelegate, MCAdvertiserAssistantDelegate, UITextFieldDelegate>
@property (nonatomic, strong) MCPeerID *localPeerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCBrowserViewController *browserViewController;

@property (weak, nonatomic) IBOutlet UITextField *textToSend;
@property (weak, nonatomic) IBOutlet UITextView *messageList;
@property (strong, nonatomic) UIImage *image;

@end

@implementation NearbyChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textToSend.delegate = self;
    [self.advertiser start];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.messageList.selectable = NO;
}

- (IBAction)onTapBrowse
{
    [self presentViewController:self.browserViewController animated:NO completion:nil];
}

- (IBAction)onTapSend:(UIButton *)sender
{
    [self.textToSend resignFirstResponder];
    [self sendMessage];
}

- (void)sendMessage
{
    NSString *message = self.textToSend.text;
    self.textToSend.text = @"";
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [self.session sendData:data toPeers:[self.session connectedPeers] withMode:MCSessionSendDataReliable error:&error];
    if (error) {
        NSLog(@"ERROR: %@", error);
    }
    
    [self receiveMessage:message fromPeer:self.localPeerID];
}

- (void)receiveMessage:(NSString *)message fromPeer:(MCPeerID *)peer
{
    NSString *who = peer == self.localPeerID ? @"Me" : peer.displayName;
    self.messageList.text = [NSString stringWithFormat:@"%@: %@\n%@", who, message, self.messageList.text];
}

# pragma mark - Getters & Setters

- (MCPeerID *)localPeerID
{
    if (!_localPeerID) {
        _localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    }
    return _localPeerID;
}

- (MCSession *)session {
    if (!_session) {
        _session = [[MCSession alloc] initWithPeer:self.localPeerID
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];
        _session.delegate = self;
    }
    return _session;
}

- (MCAdvertiserAssistant *)advertiser
{
    if (!_advertiser) {
        _advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:ServiceType discoveryInfo:nil session:self.session];
        _advertiser.delegate = self;
    }
    return _advertiser;
}

- (MCBrowserViewController *)browserViewController
{
    if (!_browserViewController) {
                _browserViewController = [[MCBrowserViewController alloc] initWithServiceType:ServiceType session:self.session];
        _browserViewController.delegate = self;
    }
    return _browserViewController;
}

# pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:NO completion:nil];
}

# pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [self receiveMessage:message fromPeer:peerID];
    });
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localURL]];

    dispatch_async(dispatch_get_main_queue(),^{
        [self performSegueWithIdentifier:@"ShowImage" sender:self];
    });
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self sendMessage];
    return YES;
}

@end
