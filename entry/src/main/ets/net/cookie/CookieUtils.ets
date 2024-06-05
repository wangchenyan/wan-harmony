import Cookie from './Cookie';
import { uri } from '@kit.ArkTS';

export default class CookieUtils {
  /**
   * httpRequest 返回的 cookie 格式：
   * ```
   * #HttpOnly_www.wanandroid.com  FALSE  /  TRUE  0  JSESSIONID  564CB756D6C2F19456141DA377A0D692
   * www.wanandroid.com  FALSE  /  FALSE  1705495544  loginUserName  chaywong
   * www.wanandroid.com  FALSE  /  FALSE  1705495544  token_pass  d4fb1b1219a552003c5ec2e93221b0b0
   * .wanandroid.com  TRUE  /  FALSE  1705495544  loginUserName_wanandroid_com  chaywong
   * .wanandroid.com  TRUE  /  FALSE  1705495544  token_pass_wanandroid_com  d4fb1b1219a552003c5ec2e93221b0b0
   * ```
   */
  static parseHttpRequestCookies(cookieString: string): Cookie[] {
    if (!cookieString) {
      return [];
    }
    const cookies: Cookie[] = [];
    const lines = cookieString.split("\r\n");
    lines.forEach((line) => {
      const attrs = line.split("\t");
      if (attrs.length !== 7 || !attrs[0]) {
        return;
      }
      let domain = attrs[0];
      let httpOnly = false;
      if (domain.startsWith("#HttpOnly_")) {
        domain = domain.substring("#HttpOnly_".length);
        httpOnly = true;
      }
      cookies.push({
        domain: domain,
        path: attrs[2],
        expiresAt: parseInt(attrs[4]),
        name: attrs[5],
        value: attrs[6],
        httpOnly: httpOnly,
        persistent: true
      });
    })
    return cookies;
  }

  static cookieHeader(cookies: Cookie[]): string {
    let str = "";
    cookies.forEach((cookie, index) => {
      if (index > 0) {
        str += "; ";
      }
      str += cookie.name + "=" + cookie.value;
    });
    return str;
  }

  static matches(cookie: Cookie, url: uri.URI): boolean {
    const domainMatch = CookieUtils.domainMatch(url.host, cookie.domain);
    if (!domainMatch) {
      return false;
    }
    if (!CookieUtils.pathMatch(url, cookie.path)) {
      return false;
    }
    return true;
  }

  static createCookieKey(cookie: Cookie): string {
    return `https://${cookie.domain}${cookie.path}|${cookie.name}`;
  }

  static isExpired(cookie: Cookie): boolean {
    const nowTime = Date.now() / 1000;
    return cookie.expiresAt < nowTime;
  }

  static fromJson(json: string): Cookie | undefined {
    if (json.length === 0) {
      return undefined;
    }
    const temp: Cookie | undefined = JSON.parse(json);
    return temp;
  }

  private static domainMatch(urlHost: string, domain: string): boolean {
    if (urlHost === domain) {
      return true; // As in 'example.com' matching 'example.com'.
    }

    return urlHost.endsWith(domain) && urlHost[urlHost.length - domain.length - 1] === ".";
  }

  private static pathMatch(url: uri.URI, path: string): boolean {
    const urlPath = url.path;
    if (urlPath === path) {
      return true; // As in '/foo' matching '/foo'.
    }
    if (urlPath.startsWith(path)) {
      if (path.endsWith("/")) {
        return true;
      } // As in '/' matching '/foo'.
      if (urlPath[path.length] === "/") {
        return true;
      } // As in '/foo' matching '/foo/bar'.
    }
    return false;
  }
}