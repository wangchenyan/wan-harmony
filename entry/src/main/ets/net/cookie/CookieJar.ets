import uri from '@ohos.uri';
import Cookie from './Cookie';

export default interface CookieJar {
  saveFromResponse(url: uri.URI, cookies: Array<Cookie>): void;

  loadForRequest(url: uri.URI): Array<Cookie>;

  clear(): void;
}
