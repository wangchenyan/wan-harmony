import Cookie from './Cookie';
import dataPreferences from '@ohos.data.preferences';
import CookiePersistor from './CookiePersistor';

export default class KVCookiePersistor implements CookiePersistor {
  private tag = "KVCookiePersistor";
  private context: Context;
  private preferences: dataPreferences.Preferences;

  constructor(context: Context) {
    this.context = context;
  }

  private async checkInit(): Promise<void> {
    if (!this.preferences) {
      this.preferences = await dataPreferences.getPreferences(this.context, 'top.wangchenyan.cookie.persistor');
    }
    return new Promise<void>((resolve, reject) => {
      resolve();
    });
  }

  async loadAll(): Promise<Cookie[]> {
    await this.checkInit();
    let cookies: Array<Cookie> = [];
    let all = await this.preferences.getAll();
    for (let key in all) {
      let value = all[key];
      let cookie = new Cookie();
      Object.assign(cookie, JSON.parse(value));
      cookies.push(cookie);
    }
    return new Promise<Cookie[]>((resolve, reject) => {
      resolve(cookies);
    });
  }

  saveAll(cookies: Cookie[]) {
    this.checkInit().then((v) => {
      cookies.forEach((cookie) => {
        this.preferences.put(cookie.createCookieKey(), JSON.stringify(cookie));
      });
      this.preferences.flush();
    });
  }

  removeAll(cookies: Cookie[]) {
    this.checkInit().then((v) => {
      cookies.forEach((cookie) => {
        this.preferences.delete(cookie.createCookieKey());
      });
      this.preferences.flush();
    });
  }

  clear() {
    this.checkInit().then((v) => {
      this.preferences.clear();
      this.preferences.flush();
    });
  }
}