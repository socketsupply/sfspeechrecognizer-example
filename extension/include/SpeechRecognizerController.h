#ifndef SPEECH_RECOGNIZER_CONTROLLER_H
#define SPEECH_RECOGNIZER_CONTROLLER_H

#import <Speech/Speech.h>
#import <TargetConditionals.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>

typedef void (^SpeechRecognizerControllerAuthorizationRequestCallback)(
  SFSpeechRecognizerAuthorizationStatus
);

typedef void (^SpeechRecognizerControllerAudioRecognitionCallback)(
  NSError*,
  NSString*
);

@interface SpeechRecognizerController : NSObject<SFSpeechRecognizerDelegate>
@property (atomic, assign) SFSpeechRecognizer* speechRecognizer;
@property (atomic, assign) AVAudioEngine* audioEngine;
@property (atomic, assign) AVAudioInputNode* inputNode;

@property (atomic, assign) SFSpeechRecognitionTask* currentTask;
@property (atomic, assign) SFSpeechAudioBufferRecognitionRequest* currentRequest;
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@property (atomic, assign) AVAudioSession* audioSession;
#endif
@property (atomic, assign) NSLocale* locale;

+ (SpeechRecognizerController*) sharedInstance;
- (BOOL) isAvailable;
- (void) requestAuthorization: (SpeechRecognizerControllerAuthorizationRequestCallback) callback;
- (void) finishRecognition;
- (void) recognizeAudio: (SpeechRecognizerControllerAudioRecognitionCallback) callback;
- (void) speechRecognizer: (SFSpeechRecognizer*) speechRecognizer
    availabilityDidChange: (BOOL) available;
@end

#endif
