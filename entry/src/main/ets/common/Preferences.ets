import dataPreferences from '@ohos.data.preferences';

const KEY_SEARCH_HISTORY: string = "search_history";

export default class Preferences {
  private static instance: Preferences;
  private context: Context
  private preferences: dataPreferences.Preferences;

  private constructor(context: Context) {
    this.context = context;
  }

  async getSearchHistory(): Promise<Array<string>> {
    await this.checkInit();
    let json = await this.preferences.get(KEY_SEARCH_HISTORY, "")
    return new Promise<Array<string>>((resolve, reject) => {
      if (json) {
        resolve(JSON.parse(json.toString()))
      } else {
        resolve([])
      }
    })
  }

  putSearchHistory(historyKeys: Array<string>) {
    this.checkInit().then((v) => {
      this.preferences.put(KEY_SEARCH_HISTORY, JSON.stringify(historyKeys))
      this.preferences.flush()
    })
  }

  private async checkInit(): Promise<void> {
    if (!this.preferences) {
      this.preferences = await dataPreferences.getPreferences(this.context, 'top.wangchenyan.wanharmony');
    }
    return new Promise<void>((resolve, reject) => {
      resolve();
    });
  }

  static get(context: Context): Preferences {
    if (Preferences.instance === undefined) {
      Preferences.instance = new Preferences(context);
    }
    return Preferences.instance;
  }
}