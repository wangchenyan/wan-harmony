import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import { Article, ArticleList, HomeBannerData } from './model/Article';
import { User } from '../service/UserService';
import uri from '@ohos.uri';
import PersistentCookieJar from './cookie/PersistentCookieJar';
import CookieJar from './cookie/CookieJar';
import EntryContext from '../common/EntryContext';
import CookieUtils from './cookie/CookieUtils';
import { Response } from './model/Response';
import { HotKey } from './model/Search';
import { WeChatAuthor } from './model/WeChat';
import { Tree } from './model/Tree';
import JSON from '@ohmos/json-bigint';
import { Rank } from './model/RankingList';
import { Harmony } from './model/Harmony';

const TAG = "Api";
const BASE_URL: string = "https://www.wanandroid.com";

const cookieJar: CookieJar = new PersistentCookieJar(EntryContext.getContext());

function parseUri(url: string): uri.URI {
  return new uri.URI(url);
}

async function requestSync<T>(path: string, method: http.RequestMethod, extraData?: object): Promise<Response<T>> {
  return new Promise<Response<T>>((resolve, reject) => {
    const headers = new Headers();
    const url = BASE_URL + path;
    const uri = parseUri(url);
    const cookies = cookieJar.loadForRequest(uri);
    if (cookies.length > 0) {
      headers.cookie = CookieUtils.cookieHeader(cookies);
    }
    if (method === http.RequestMethod.POST) {
      headers.contentType = "application/x-www-form-urlencoded"
      if (!extraData) {
        // POST 必须有请求体，否则会报 Parameter error
        extraData = new Object();
      }
    }
    const httpRequest = http.createHttp();
    hilog.info(0, TAG,
      `start request, path: ${path}, method: ${method}, extraData: ` + JSON.stringify(extraData, undefined, undefined));
    httpRequest.request(
      url,
      {
        method: method,
        expectDataType: http.HttpDataType.OBJECT,
        header: headers,
        extraData: extraData
      },
      (err, data) => {
        const res = new Response<T>()
        if (!err && data.responseCode === 200) {
          cookieJar.saveFromResponse(uri, CookieUtils.parseHttpRequestCookies(data.cookies))
          if (data.resultType === http.HttpDataType.STRING) {
            const result: Response<T> = JSON.parse(data.result);
            res.errorCode = result.errorCode;
            res.errorMsg = result.errorMsg;
            res.data = result.data;
          } else if (data.resultType === http.HttpDataType.OBJECT) {
            const result = data.result as Response<T>;
            res.errorCode = result.errorCode;
            res.errorMsg = result.errorMsg;
            res.data = result.data;
          } else {
            res.errorCode = -1
            res.errorMsg = `UnSupport data type: ${data.resultType}`
          }
          hilog.info(0, TAG, `request success, path: ${path}, result: ${JSON.stringify(res, undefined, undefined)}`)
        } else {
          hilog.error(0, TAG, `request error, path: ${path}, error: ${JSON.stringify(err, undefined, undefined)}`)
          res.errorCode = data?.responseCode ?? -1
          res.errorMsg = err?.message ?? ""
        }
        resolve(res);
      }
    )
  })
}

class Headers {
  contentType?: string;
  cookie?: string;
}

export default class Api {
  private static instance: Api;

  private constructor() {
  }

  static get(): Api {
    if (Api.instance === undefined) {
      Api.instance = new Api();
    }
    return Api.instance;
  }

  clearCookie() {
    cookieJar.clear();
  }

  async getHomeArticleList(page: number): Promise<Response<ArticleList>> {
    return requestSync(`/article/list/${page}/json`, http.RequestMethod.GET);
  }

  async getTopArticle(): Promise<Response<Article[]>> {
    return requestSync("/article/top/json", http.RequestMethod.GET);
  }

  async getHomeBanner(): Promise<Response<HomeBannerData[]>> {
    return requestSync("/banner/json", http.RequestMethod.GET);
  }

  async getSquareArticleList(page: number): Promise<Response<ArticleList>> {
    return requestSync(`/user_article/list/${page}/json`, http.RequestMethod.GET);
  }

  async getWeChatAuthorList(): Promise<Response<WeChatAuthor[]>> {
    return requestSync("/wxarticle/chapters/json", http.RequestMethod.GET)
  }

  async getWeChatArticleList(id: number, page: number): Promise<Response<ArticleList>> {
    return requestSync(`/wxarticle/list/${id}/${page}/json`, http.RequestMethod.GET);
  }

  async login(username: string, password: string): Promise<Response<User>> {
    return requestSync(`/user/login?username=${username}&password=${password}`, http.RequestMethod.POST);
  }

  async logout(): Promise<Response<string>> {
    return requestSync("/user/logout/json", http.RequestMethod.GET);
  }

  async getUserInfo(): Promise<Response<User>> {
    return requestSync("/lg/coin/userinfo/json", http.RequestMethod.GET);
  }

  async getSearchHotKey(): Promise<Response<HotKey[]>> {
    return requestSync("/hotkey/json", http.RequestMethod.GET)
  }

  async search(keyword: string, page: number): Promise<Response<ArticleList>> {
    return requestSync(`/article/query/${page}/json?k=${encodeURIComponent(keyword)}`, http.RequestMethod.POST)
  }

  async collect(id: number): Promise<Response<object>> {
    return requestSync(`/lg/collect/${id}/json`, http.RequestMethod.POST)
  }

  async unCollect(id: number): Promise<Response<object>> {
    return requestSync(`/lg/uncollect_originId/${id}/json`, http.RequestMethod.POST)
  }

  async getCollectList(page: number): Promise<Response<ArticleList>> {
    return requestSync(`/lg/collect/list/${page}/json`, http.RequestMethod.GET)
  }

  async getTree(): Promise<Response<Tree[]>> {
    return requestSync(`/tree/json`, http.RequestMethod.GET)
  }

  async getTreeArticleList(cid: number, page: number): Promise<Response<ArticleList>> {
    return requestSync(`/article/list/${page}/json?cid=${cid}`, http.RequestMethod.GET)
  }

  async getHarmony() : Promise<Response<Harmony>> {
    return requestSync(`/harmony/index/json`, http.RequestMethod.GET)
  }

  async getRankingList(page: number): Promise<Response<Rank>> {
    const url = `/coin/rank/${page}/json`;
    return requestSync(url, http.RequestMethod.GET);
  }
}