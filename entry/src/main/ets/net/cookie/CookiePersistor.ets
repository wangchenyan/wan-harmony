import Cookie from './Cookie';

export default interface CookiePersistor {
  loadAll(): Cookie[];

  saveAll(cookies: Cookie[]): void;

  removeAll(cookies: Cookie[]): void;

  clear(): void;
}