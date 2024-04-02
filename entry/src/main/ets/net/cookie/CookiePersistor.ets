import Cookie from './Cookie';

export default interface CookiePersistor {
  loadAll(): Cookie[];

  saveAll(cookies: Array<Cookie>): void;

  removeAll(cookies: Array<Cookie>): void;

  clear(): void;
}