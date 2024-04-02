import Cookie from './Cookie';

export default interface CookiePersistor {
  loadAll(): Promise<Cookie[]>;

  saveAll(cookies: Array<Cookie>): void;

  removeAll(cookies: Array<Cookie>): void;

  clear(): void;
}