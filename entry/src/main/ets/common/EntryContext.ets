export default class EntryContext {
  private static context: Context

  static setContext(context: Context) {
    EntryContext.context = context
  }

  static getContext(): Context {
    if (!EntryContext.context) {
      throw Error("context is not init")
    }
    return EntryContext.context
  }
}