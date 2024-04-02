import Cookie from './Cookie';
import dataPreferences from '@ohos.data.preferences';
import CookiePersistor from './CookiePersistor';
import JSON from '@ohmos/json-bigint';

const PREFERENCES_NAME = "top.wangchenyan.cookie.persistor"
const KEY_COOKIE_KEYS = "COOKIE_KEYS";

export default class KVCookiePersistor implements CookiePersistor {
  private tag = "KVCookiePersistor";
  private preferences: dataPreferences.Preferences;

  constructor(context: Context) {
    this.preferences = dataPreferences.getPreferencesSync(context, {
      name: PREFERENCES_NAME
    });
  }

  loadAll(): Cookie[] {
    let cookies: Array<Cookie> = [];
    let keys = this.preferences.getSync(KEY_COOKIE_KEYS, []) as Array<string>
    keys.forEach((key) => {
      let value = this.preferences.getSync(key, "") as string
      if (value.length > 0) {
        let cookie = Cookie.fromJson(value);
        if (cookie) {
          cookies.push(cookie);
        }
      }
    })
    return cookies;
  }

  saveAll(cookies: Cookie[]) {
    cookies.forEach((cookie) => {
      this.preferences.putSync(cookie.createCookieKey(), JSON.stringify(cookie, undefined, undefined));
    });
    let keys = this.preferences.getSync(KEY_COOKIE_KEYS, []) as Array<string>
    cookies.forEach((cookie) => {
      let key = cookie.createCookieKey();
      if (keys.indexOf(key) < 0) {
        keys.push(key)
      }
    })
    this.preferences.putSync(KEY_COOKIE_KEYS, keys);
    this.preferences.flush();
  }

  removeAll(cookies: Cookie[]) {
    let keys = this.preferences.getSync(KEY_COOKIE_KEYS, []) as Array<string>
    cookies.forEach((cookie) => {
      let key = cookie.createCookieKey();
      this.preferences.deleteSync(key);
      let index = keys.indexOf(key);
      if (index >= 0) {
        keys.splice(index, 1);
      }
    });
    this.preferences.putSync(KEY_COOKIE_KEYS, keys);
    this.preferences.flush();
  }

  clear() {
    this.preferences.clearSync();
    this.preferences.flush();
  }
}