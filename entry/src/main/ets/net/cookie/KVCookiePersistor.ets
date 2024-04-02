import Cookie from './Cookie';
import dataPreferences from '@ohos.data.preferences';
import CookiePersistor from './CookiePersistor';
import JSON from '@ohmos/json-bigint';

const KEY_COOKIE_KEYS = "COOKIE_KEYS";

export default class KVCookiePersistor implements CookiePersistor {
  private tag = "KVCookiePersistor";
  private context: Context;
  private preferences?: dataPreferences.Preferences;

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
    let keys = await this.preferences?.get(KEY_COOKIE_KEYS, []) as Array<string>
    keys.forEach((key) => {
      let value = this.preferences?.getSync(key, "") as string
      if (value.length > 0) {
        let cookie = Cookie.fromJson(value);
        if (cookie) {
          cookies.push(cookie);
        }
      }
    })
    return new Promise<Cookie[]>((resolve, reject) => {
      resolve(cookies);
    });
  }

  saveAll(cookies: Cookie[]) {
    this.checkInit().then(async (v) => {
      cookies.forEach((cookie) => {
        this.preferences?.put(cookie.createCookieKey(), JSON.stringify(cookie, undefined, undefined));
      });
      let rawKeys = await this.preferences?.get(KEY_COOKIE_KEYS, []) as Array<string>
      let newKeys = cookies.map(cookie => cookie.createCookieKey())
      newKeys.forEach((key) => {
        if (rawKeys.indexOf(key) < 0) {
          rawKeys.push(key)
        }
      })
      this.preferences?.put(KEY_COOKIE_KEYS, rawKeys)
      this.preferences?.flush();
    });
  }

  removeAll(cookies: Cookie[]) {
    this.checkInit().then((v) => {
      cookies.forEach((cookie) => {
        this.preferences?.delete(cookie.createCookieKey());
      });
      this.preferences?.flush();
    });
  }

  clear() {
    this.checkInit().then((v) => {
      this.preferences?.clear();
      this.preferences?.flush();
    });
  }
}