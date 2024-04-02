import uri from '@ohos.uri';

/**
 * Cookie 对象，参考 OkHttp 中 Cookie 结构
 */
export default class Cookie {
  name: string = "";
  value: string = "";
  expiresAt: number = 0;
  domain: string = "";
  path: string = "";
  httpOnly: boolean = false;
  persistent: boolean = true;

  matches(url: uri.URI): boolean {
    let domainMatch = Cookie.domainMatch(url.host, this.domain);
    if (!domainMatch) return false;
    if (!Cookie.pathMatch(url, this.path)) return false;
    return true;
  }

  createCookieKey(): string {
    return `https://${this.domain}${this.path}|${this.name}`;
  }

  isExpired(): boolean {
    let nowTime = Date.now() / 1000;
    return this.expiresAt < nowTime;
  }

  static fromJson(json: string): Cookie | undefined {
    if (json.length === 0) return undefined;
    let temp: Cookie | undefined = JSON.parse(json);
    if (temp === undefined) return undefined;
    let cookie = new Cookie();
    cookie.name = temp.name;
    cookie.value = temp.value;
    cookie.expiresAt = temp.expiresAt;
    cookie.domain = temp.domain;
    cookie.path = temp.path;
    cookie.httpOnly = temp.httpOnly;
    cookie.persistent = temp.persistent;
    return cookie;
  }

  private static domainMatch(urlHost: string, domain: string): boolean {
    if (urlHost === domain) {
      return true; // As in 'example.com' matching 'example.com'.
    }

    return urlHost.endsWith(domain) && urlHost[urlHost.length - domain.length - 1] === ".";
  }

  private static pathMatch(url: uri.URI, path: string): boolean {
    let urlPath = url.path;
    if (urlPath === path) {
      return true; // As in '/foo' matching '/foo'.
    }
    if (urlPath.startsWith(path)) {
      if (path.endsWith("/")) return true; // As in '/' matching '/foo'.
      if (urlPath[path.length] === "/") return true; // As in '/foo' matching '/foo/bar'.
    }
    return false;
  }
}