import uri from '@ohos.uri';
import Cookie from './Cookie';

export default interface CookieJar {
  init(): Promise<void>;

  saveFromResponse(url: uri.URI, cookies: Array<Cookie>);

  loadForRequest(url: uri.URI): Array<Cookie>;

  clear();
}
