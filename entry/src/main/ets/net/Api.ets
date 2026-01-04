import { Article, ArticleList, HomeBannerData } from './model/Article';
import { User } from '../service/UserService';
import PersistentCookieJar from './cookie/PersistentCookieJar';
import CookieJar from './cookie/CookieJar';
import EntryContext from '../common/EntryContext';
import { Response } from './Response';
import { HotKey } from './model/Search';
import { WeChatAuthor } from './model/WeChat';
import { Tree } from './model/Tree';
import { Rank } from './model/RankingList';
import { Harmony } from './model/Harmony';
import { HttpClient } from './HttpClient';

const BASE_URL: string = "https://www.wanandroid.com";

export default class Api {
  private static instance: Api;
  private readonly cookieJar: CookieJar;
  private readonly httpClient: HttpClient;

  private constructor() {
    this.cookieJar = new PersistentCookieJar(EntryContext.getContext());
    this.httpClient = new HttpClient(BASE_URL, this.cookieJar);
  }

  static get(): Api {
    if (Api.instance === undefined) {
      Api.instance = new Api();
    }
    return Api.instance;
  }

  clearCookie() {
    this.cookieJar.clear();
  }

  async getHomeArticleList(page: number): Promise<Response<ArticleList>> {
    return this.httpClient.get(`/article/list/${page}/json`);
  }

  async getTopArticle(): Promise<Response<Article[]>> {
    return this.httpClient.get("/article/top/json");
  }

  async getHomeBanner(): Promise<Response<HomeBannerData[]>> {
    return this.httpClient.get("/banner/json");
  }

  async getSquareArticleList(page: number): Promise<Response<ArticleList>> {
    return this.httpClient.get(`/user_article/list/${page}/json`);
  }

  async getWeChatAuthorList(): Promise<Response<WeChatAuthor[]>> {
    return this.httpClient.get("/wxarticle/chapters/json")
  }

  async getWeChatArticleList(id: number, page: number): Promise<Response<ArticleList>> {
    return this.httpClient.get(`/wxarticle/list/${id}/${page}/json`);
  }

  async login(username: string, password: string): Promise<Response<User>> {
    return this.httpClient.post(`/user/login?username=${username}&password=${password}`);
  }

  async logout(): Promise<Response<string>> {
    return this.httpClient.get("/user/logout/json");
  }

  async getUserInfo(): Promise<Response<User>> {
    return this.httpClient.get("/lg/coin/userinfo/json");
  }

  async getSearchHotKey(): Promise<Response<HotKey[]>> {
    return this.httpClient.get("/hotkey/json")
  }

  async search(keyword: string, page: number): Promise<Response<ArticleList>> {
    return this.httpClient.post(`/article/query/${page}/json?k=${encodeURIComponent(keyword)}`)
  }

  async collect(id: number): Promise<Response<object>> {
    return this.httpClient.post(`/lg/collect/${id}/json`)
  }

  async unCollect(id: number): Promise<Response<object>> {
    return this.httpClient.post(`/lg/uncollect_originId/${id}/json`)
  }

  async getCollectList(page: number): Promise<Response<ArticleList>> {
    return this.httpClient.get(`/lg/collect/list/${page}/json`)
  }

  async getTree(): Promise<Response<Tree[]>> {
    return this.httpClient.get(`/tree/json`)
  }

  async getTreeArticleList(cid: number, page: number): Promise<Response<ArticleList>> {
    return this.httpClient.get(`/article/list/${page}/json?cid=${cid}`)
  }

  async getHarmony(): Promise<Response<Harmony>> {
    return this.httpClient.get(`/harmony/index/json`)
  }

  async getRankingList(page: number): Promise<Response<Rank>> {
    const url = `/coin/rank/${page}/json`;
    return this.httpClient.get(url);
  }
}