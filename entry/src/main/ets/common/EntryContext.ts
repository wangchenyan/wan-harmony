export default class EntryContext {
  private static context: object

  static setContext(context: object) {
    this.context = context
  }

  static getContext(): object {
    if (!EntryContext.context) {
      throw Error("context is not init")
    }
    return EntryContext.context
  }
}