import Cookie from './Cookie';

export default interface CookiePersistor {
  loadAll(): Promise<Cookie[]>;

  saveAll(cookies: Array<Cookie>);

  removeAll(cookies: Array<Cookie>);

  clear();
}