#import <SpeechRecognizerController.h>
#import <socket/extension.h>

static SpeechRecognizerController* sharedInstance = nil;

@implementation SpeechRecognizerController
+ (SpeechRecognizerController*) sharedInstance {

  if (sharedInstance == nil) {
    sharedInstance = [SpeechRecognizerController new];
    [sharedInstance retain];
  }

  return sharedInstance;
}

- (instancetype) init {
  self = [super init];
  // use system locale
  self.locale = [NSLocale autoupdatingCurrentLocale];

  // speech
  self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale: self.locale];
  self.speechRecognizer.delegate = self;

  // audio
  self.audioEngine = [AVAudioEngine new];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
  self.audioSession = [AVAudioSession sharedInstance];
#endif

  // state
  self.currentTask = nil;
  return self;
}

- (oneway void) release {
  if (sharedInstance != nil) {
    sharedInstance = nil;
  }
}

- (BOOL) isAvailable {
  return self.speechRecognizer != nil && self.speechRecognizer.isAvailable;
}

- (void) requestAuthorization: (SpeechRecognizerControllerAuthorizationRequestCallback) callback {
  if (SFSpeechRecognizer.authorizationStatus == SFSpeechRecognizerAuthorizationStatusAuthorized) {
    callback(SFSpeechRecognizer.authorizationStatus);
    return;
  }

  [SFSpeechRecognizer requestAuthorization: ^(SFSpeechRecognizerAuthorizationStatus status) {
    callback(status);
  }];
}

- (void) finishRecognition {
  if (self.currentRequest) {
    [self.currentRequest endAudio];
    self.currentRequest = nil;
  }

  if (self.currentTask != nil) {
    [self.currentTask finish];
    self.currentTask = nil;

    [self.audioEngine stop];
    [self.audioEngine.inputNode removeTapOnBus: 0];
  }
}

- (void) recognizeAudio: (SpeechRecognizerControllerAudioRecognitionCallback) callback {
  NSError* error = nil;

  [self finishRecognition];

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
  [self.audioSession
    setCategory: AVAudioSessionCategoryRecord
           mode: AVAudioSessionModeMeasurement
        options: AVAudioSessionCategoryOptionDuckOthers
         error: &error
  ];

  if (error != nil) {
    callback(error, nil);
    return;
  }
#endif

  self.currentRequest = [SFSpeechAudioBufferRecognitionRequest new];
  auto inputNode = self.audioEngine.inputNode;
  auto outputFormat = [inputNode outputFormatForBus: 0];

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
  if (@available(iOS 13, *)) {
    self.currentRequest.requiresOnDeviceRecognition = YES;
  }
#else
  if (self.speechRecognizer.supportsOnDeviceRecognition) {
    self.currentRequest.requiresOnDeviceRecognition = YES;
  }
#endif

  self.currentRequest.shouldReportPartialResults = YES;

  self.currentTask = [self.speechRecognizer
    recognitionTaskWithRequest: self.currentRequest
                 resultHandler: ^(SFSpeechRecognitionResult* result, NSError* error) {
    const auto isFinal = error != nil || (result != nil && result.isFinal);

    if (error != nil) {
      callback(error, nil);
    } else if (result != nil && result.isFinal) {
      callback(nil, result.bestTranscription.formattedString);
    }

    if (isFinal) {
      [self.audioEngine stop];
      [inputNode removeTapOnBus: 0];
    }
  }];

  [inputNode
    installTapOnBus: 0
         bufferSize: 1024
             format: outputFormat
              block: ^(AVAudioPCMBuffer *buffer, AVAudioTime *when) {
    if (self.currentRequest != nil) {
      [self.currentRequest appendAudioPCMBuffer: buffer];
    }
  }];

  [self.audioEngine prepare];
  [self.audioEngine startAndReturnError: &error];

  if (error != nil) {
    callback(error, nil);
  }
}

- (void) speechRecognizer: (SFSpeechRecognizer*) speechRecognizer
    availabilityDidChange: (BOOL) available {
}
@end
