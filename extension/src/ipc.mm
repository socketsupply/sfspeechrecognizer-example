#import <SpeechRecognizerController.h>
#import "ipc.h"

namespace SpeechRecognizer::IPC {
  void requestAuthorization (
    sapi_context_t* context,
    sapi_ipc_message_t* message,
    const sapi_ipc_router_t* router
  ) {
    auto instance = [SpeechRecognizerController sharedInstance];
    auto result = sapi_ipc_result_create(context, message);
    [instance requestAuthorization: ^(SFSpeechRecognizerAuthorizationStatus status) {
      if (status != SFSpeechRecognizerAuthorizationStatusAuthorized) {
        auto err = sapi_json_object_create(context);
        const char* message = "An unknown error occurred.";
        const char* statusType = "unknown";

        if (status == SFSpeechRecognizerAuthorizationStatusNotDetermined) {
          message = "The authorization status has not yet been determined.";
          statusType = "default";
        } else if (status == SFSpeechRecognizerAuthorizationStatusDenied) {
          message = "The user denied the request to perform speech recognition";
          statusType = "denied";
        } else if (status == SFSpeechRecognizerAuthorizationStatusRestricted) {
          message = "The device prevents speech recognition.";
          statusType = "restricted";
        }

        sapi_json_object_set(
          err,
          "message",
          sapi_json_any(sapi_json_string_create(context, message))
        );

        sapi_json_object_set(
          err,
          "status",
          sapi_json_any(sapi_json_string_create(context, statusType))
        );

        sapi_ipc_result_set_json_error(result, sapi_json_any(err));
      } else {
        auto data = sapi_json_object_create(context);

        sapi_json_object_set(
          data,
          "status",
          sapi_json_any(sapi_json_string_create(context, "authorized"))
        );

        sapi_ipc_result_set_json_data(result, sapi_json_any(data));
      }

      sapi_ipc_reply(result);
    }];
  }

  void isAvailable (
    sapi_context_t* context,
    sapi_ipc_message_t* message,
    const sapi_ipc_router_t* router
  ) {
    auto instance = [SpeechRecognizerController sharedInstance];
    auto result = sapi_ipc_result_create(context, message);
    auto data = sapi_json_object_create(context);

    sapi_ipc_result_set_json_data(
      result,
      sapi_json_any(sapi_json_boolean_create(context, instance.isAvailable))
    );

    sapi_ipc_reply(result);
  }

  void recognizeAudio (
    sapi_context_t* context,
    sapi_ipc_message_t* message,
    const sapi_ipc_router_t* router
  ) {
    auto instance = [SpeechRecognizerController sharedInstance];
    auto result = sapi_ipc_result_create(context, message);

    //auto data = sapi_json_object_create(context);
    [instance recognizeAudio: ^(NSError* error, NSString* text) {
      if (error != nil) {
        auto err = sapi_json_object_create(context);
        sapi_json_object_set(
          err,
          "message",
          sapi_json_any(sapi_json_string_create(context, error.localizedDescription.UTF8String))
        );

        sapi_ipc_result_set_json_error(result, sapi_json_any(err));
      } else {
        auto data = sapi_json_object_create(context);
        sapi_ipc_result_set_json_data(
          result,
          sapi_json_any(sapi_json_string_create(context, text.UTF8String))
        );
      }

      sapi_ipc_reply(result);
    }];
  }

  void finishRecognition (
    sapi_context_t* context,
    sapi_ipc_message_t* message,
    const sapi_ipc_router_t* router
  ) {
    auto instance = [SpeechRecognizerController sharedInstance];
    auto result = sapi_ipc_result_create(context, message);

    [instance finishRecognition];
    sapi_ipc_reply(result);
  }
}
