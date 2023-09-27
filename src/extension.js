import extension from 'socket:extension'
import hooks from 'socket:hooks'

let instance = null

export const EXTENSION_NAME = 'SFSpeechRecognizer'

export async function load () {
  await new Promise((resolve) => hooks.onReady(resolve))

  if (!instance) {
    instance = await extension.load(EXTENSION_NAME)
  }

  return instance.binding
}

export async function unload () {
  if (instance) {
    const tmp = instance
    instance = null
    await tmp.unload()
  }
}

export default { load, unload }
