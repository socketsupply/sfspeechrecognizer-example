import Tonic from '@socketsupply/tonic'

import SpeechRecognizerCore from '../speech-recognizer.js'

export default class SpeechRecognizer extends Tonic {
  state = {
    recording: false,
    isAvailable: false,
    authorization: null,
    recognizedText: ''
  }

  get speechRecognizer () {
    return this.state.speechRecognizer
  }

  get isAvailable () {
    return this.state.isAvailable
  }

  get authorization () {
    return this.state.authorization
  }

  async connected () {
    this.state.speechRecognizer = await SpeechRecognizerCore.load()
    this.state.isAvailable = await this.state.speechRecognizer.isAvailable()

    if (this.state.isAvailable) {
      this.state.authorization = await this.state.speechRecognizer.requestAuthorization()
    }
  }

  async click (event) {
    if (!Tonic.match(event.target, '[data-event]')) {
      return
    }

    if (!this.state.isAvailable && this.state.authorization?.status !== 'authorized') {
      this.state.recognizedText = '(SpeechRecognizer is not available or not authorized by user)'
      this.reRender()
      return
    }

    if (this.state.recording) {
      this.state.recording = false
      await this.state.speechRecognizer.finishRecognition()
    } else {
      this.state.recording = true
      this.state.recognizedText = '...'
      this.state.speechRecognizer.recognizeAudio().then((result) => {
        this.state.recognizedText = result
        this.reRender()
      })
    }

    await this.reRender()
  }

  render () {
    return this.html`
      <div>
        <button data-event="record-or-stop" class="${Tonic.unsafeRawString(this.state.recording ? 'recording' : '')}">
          ${this.state.recording ? 'Stop' : 'Record'}
        </button>
        <textarea disabled>${this.state.recognizedText}</textarea>
      </div>
    `
  }
}
