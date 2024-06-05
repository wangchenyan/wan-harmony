/**
 * Cookie 对象，参考 OkHttp 中 Cookie 结构
 */
export default interface Cookie {
  domain: string;
  path: string;
  expiresAt: number;
  name: string;
  value: string;
  httpOnly: boolean;
  persistent: boolean;
}