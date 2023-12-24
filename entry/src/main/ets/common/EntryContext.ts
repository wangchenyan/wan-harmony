export default class EntryContext {
  private static context: Object

  static setContext(context: Object) {
    this.context = context
  }

  static getContext(): Object {
    if (!EntryContext.context) {
      throw Error("context is not init")
    }
    return EntryContext.context
  }
}