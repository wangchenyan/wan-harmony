import uri from '@ohos.uri'

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