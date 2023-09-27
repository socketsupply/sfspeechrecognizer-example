#ifndef SPEECH_RECOGNIZER_IPC_H
#define SPEECH_RECOGNIZER_IPC_H

#include <socket/extension.h>

namespace SpeechRecognizer::IPC {
  void requestAuthorization (
    sapi_context_t* context,
    sapi_ipc_message_t* message,
    const sapi_ipc_router_t* router
  );

  void isAvailable (
    sapi_context_t* context,
    sapi_ipc_message_t* message,
    const sapi_ipc_router_t* router
  );

  void recognizeAudio (
    sapi_context_t* context,
    sapi_ipc_message_t* message,
    const sapi_ipc_router_t* router
  );

  void finishRecognition (
    sapi_context_t* context,
    sapi_ipc_message_t* message,
    const sapi_ipc_router_t* router
  );
}

#endif
