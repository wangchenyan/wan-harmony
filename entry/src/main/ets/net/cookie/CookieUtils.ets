import Cookie from './Cookie'

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
  static parseHttpRequestCookies(cookieString: string): Array<Cookie> {
    if (!cookieString) return [];
    let cookies: Array<Cookie> = [];
    let lines = cookieString.split("\r\n");
    lines.forEach((line) => {
      let attrs = line.split("\t");
      if (attrs.length !== 7 || !attrs[0]) return;
      let cookie = new Cookie();
      let domain = attrs[0];
      if (domain.startsWith("#HttpOnly_")) {
        domain = domain.substring("#HttpOnly_".length);
        cookie.httpOnly = true;
      }
      cookie.domain = domain;
      cookie.path = attrs[2];
      cookie.expiresAt = parseInt(attrs[4]);
      cookie.name = attrs[5];
      cookie.value = attrs[6];
      cookies.push(cookie);
    })
    return cookies;
  }

  static cookieHeader(cookies: Array<Cookie>): string {
    let str = "";
    cookies.forEach((cookie, index) => {
      if (index > 0) str += "; ";
      str += cookie.name + "=" + cookie.value;
    });
    return str;
  }
}