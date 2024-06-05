import HashMap from '@ohos.util.HashMap';
import uri from '@ohos.uri';
import Cookie from './Cookie';
import CookieJar from './CookieJar';
import CookiePersistor from './CookiePersistor';
import KVCookiePersistor from './KVCookiePersistor';
import CookieUtils from './CookieUtils';

export default class PersistentCookieJar implements CookieJar {
  private static TAG = "PersistentCookieJar";
  private cache: HashMap<string, Cookie> = new HashMap();
  private persistor: CookiePersistor;

  constructor(context: Context) {
    this.persistor = new KVCookiePersistor(context);
    const cookies = this.persistor.loadAll();
    cookies.forEach((cookie) => {
      this.cache.set(CookieUtils.createCookieKey(cookie), cookie);
    })
  }

  saveFromResponse(url: uri.URI, cookies: Cookie[]): void {
    cookies.forEach((cookie) => {
      this.cache.set(CookieUtils.createCookieKey(cookie), cookie);
    })
    this.persistor.saveAll(PersistentCookieJar.filterPersistentCookies(cookies));
  }

  private static filterPersistentCookies(cookies: Cookie[]): Cookie[] {
    return cookies.filter((item) => {
      return item.persistent;
    })
  }

  loadForRequest(url: uri.URI): Cookie[] {
    const cookiesToRemove: Cookie[] = [];
    const validCookies: Cookie[] = [];

    const iterator: IterableIterator<Cookie> = this.cache.values();
    let result = iterator.next();
    while (!result.done) {
      const currentCookie: Cookie = result.value;
      if (CookieUtils.isExpired(currentCookie)) {
        cookiesToRemove.push(currentCookie);
      } else if (CookieUtils.matches(currentCookie, url)) {
        validCookies.push(currentCookie);
      }
      result = iterator.next();
    }

    cookiesToRemove.forEach((item) => {
      this.cache.remove(CookieUtils.createCookieKey(item));
    })

    this.persistor.removeAll(cookiesToRemove);

    return validCookies;
  }

  clear(): void {
    this.cache.clear();
    this.persistor.clear();
  }
}