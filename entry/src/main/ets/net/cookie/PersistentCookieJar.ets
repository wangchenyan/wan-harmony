import HashMap from '@ohos.util.HashMap';
import uri from '@ohos.uri';
import Cookie from './Cookie';
import CookieJar from './CookieJar';
import CookiePersistor from './CookiePersistor';
import KVCookiePersistor from './KVCookiePersistor';

export default class PersistentCookieJar implements CookieJar {
  private tag = "PersistentCookieJar";
  private isInit = false;
  private cache: HashMap<string, Cookie> = new HashMap();
  private persistor: CookiePersistor;

  constructor(context: Context) {
    this.persistor = new KVCookiePersistor(context);
  }

  async init(): Promise<void> {
    if (!this.isInit) {
      let cookies = await this.persistor.loadAll();
      cookies.forEach((cookie) => {
        this.cache.set(cookie.createCookieKey(), cookie);
      })
      this.isInit = true;
    }
    return new Promise<void>((resolve, reject) => {
      resolve();
    })
  }

  saveFromResponse(url: uri.URI, cookies: Cookie[]) {
    cookies.forEach((cookie) => {
      this.cache.set(cookie.createCookieKey(), cookie);
    })
    this.persistor.saveAll(PersistentCookieJar.filterPersistentCookies(cookies));
  }

  private static filterPersistentCookies(cookies: Array<Cookie>): Array<Cookie> {
    return cookies.filter((item) => {
      return item.persistent;
    })
  }

  loadForRequest(url: uri.URI): Cookie[] {
    let cookiesToRemove: Array<Cookie> = [];
    let validCookies: Array<Cookie> = [];

    let iterator: IterableIterator<Cookie> = this.cache.values();
    let result = iterator.next();
    while (!result.done) {
      let currentCookie: Cookie = result.value;
      if (currentCookie.isExpired()) {
        cookiesToRemove.push(currentCookie);
      } else if (currentCookie.matches(url)) {
        validCookies.push(currentCookie);
      }
      result = iterator.next();
    }

    cookiesToRemove.forEach((item) => {
      this.cache.remove(item.createCookieKey());
    })

    this.persistor.removeAll(cookiesToRemove);

    return validCookies;
  }

  clear() {
    this.cache.clear();
    this.persistor.clear();
  }
}