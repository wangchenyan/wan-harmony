import dataPreferences from '@ohos.data.preferences';
import { Pair } from './Structs';

const KEY_SEARCH_HISTORY: string = "search_history";
const KEY_SELECTED_TREE_ID_1 = "selected_tree_id_1";
const KEY_SELECTED_TREE_ID_2 = "selected_tree_id_2";

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

  async getSelectedTreeId(): Promise<Pair<number, number>> {
    await this.checkInit();
    let id1 = await this.preferences.get(KEY_SELECTED_TREE_ID_1, 0);
    let id2 = await this.preferences.get(KEY_SELECTED_TREE_ID_2, 0);
    return new Promise<Pair<number, number>>((resolve, reject) => {
      if (typeof id1 === "number" && id1 > 0 && typeof id2 === "number" && id2 > 0) {
        resolve({
          first: id1, second: id2
        });
      } else {
        resolve({
          first: 0, second: 0
        });
      }
    });
  }

  putSelectedTreeId(treeId1: number, treeId2: number) {
    this.checkInit().then((v) => {
      this.preferences.put(KEY_SELECTED_TREE_ID_1, treeId1);
      this.preferences.put(KEY_SELECTED_TREE_ID_2, treeId2);
      this.preferences.flush()
    });
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