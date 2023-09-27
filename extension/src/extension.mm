#import <socket/extension.h>
#import <SpeechRecognizerController.h>

#import "ipc.h"

bool initialize (sapi_context_t* context, const void *data) {
  sapi_ipc_router_map(
    context,
    "SFSpeechRecognizer.requestAuthorization",
    SpeechRecognizer::IPC::requestAuthorization,
    nullptr
  );

  sapi_ipc_router_map(
    context,
    "SFSpeechRecognizer.isAvailable",
    SpeechRecognizer::IPC::isAvailable,
    nullptr
  );

  sapi_ipc_router_map(
    context,
    "SFSpeechRecognizer.recognizeAudio",
    SpeechRecognizer::IPC::recognizeAudio,
    nullptr
  );

  sapi_ipc_router_map(
    context,
    "SFSpeechRecognizer.finishRecognition",
    SpeechRecognizer::IPC::finishRecognition,
    nullptr
  );

  return SpeechRecognizerController.sharedInstance != nil;
}

bool deinitialize (sapi_context_t* context, const void *data) {
  [SpeechRecognizerController.sharedInstance release];
  return true;
}

SOCKET_RUNTIME_REGISTER_EXTENSION(
  "SFSpeechRecognizer", // name
  initialize, // initializer
  deinitialize,
  "An native Socket Runtime extension for the SFSpeechRecognizer Framework" // description
);
