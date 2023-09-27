/* global EventTarget, CustomEvent */
import extension from './extension.js'

export class SpeechRecognizerEvent extends CustomEvent {}

export default class SpeechRecognizer extends EventTarget {
  static async load () {
    const binding = await extension.load()
    return new this({ binding })
  }

  constructor (options) {
    super()
    this.binding = options.binding
  }

  async requestAuthorization () {
    const result = await this.binding.requestAuthorization()

    if (result.err) {
      throw result.err
    }

    this.dispatchEvent(new SpeechRecognizerEvent('status', { detail: result.data }))
    return result.data
  }

  async isAvailable () {
    const result = await this.binding.isAvailable()

    if (result.err) {
      throw result.err
    }

    return result.data
  }

  async recognizeAudio () {
    const result = await this.binding.recognizeAudio()

    if (result.err) {
      throw result.err
    }

    return result.data
  }

  async finishRecognition () {
    const result = await this.binding.finishRecognition()

    if (result.err) {
      throw result.err
    }
  }
}
