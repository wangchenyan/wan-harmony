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

let TAG = "Api";
let BASE_URL: string = "https://www.wanandroid.com";

let cookieJar: CookieJar = new PersistentCookieJar(EntryContext.getContext() as Context);

function parseUri(url: string): uri.URI {
  return new uri.URI(url);
}

async function requestSync<T>(path: string, method: http.RequestMethod, extraData?: Object): Promise<Response<T>> {
  await cookieJar.init();
  return new Promise<Response<T>>((resolve, reject) => {
    let url = BASE_URL + path;
    let uri = parseUri(url);
    let header = {};
    let cookies = cookieJar.loadForRequest(uri);
    if (cookies.length > 0) {
      header["Cookie"] = CookieUtils.cookieHeader(cookies);
    }
    if (method === http.RequestMethod.POST) {
      header["Content-Type"] = "application/x-www-form-urlencoded";
      if (!extraData) {
        // POST 必须有请求体，否则会报 Parameter error
        extraData = {};
      }
    }
    let httpRequest = http.createHttp();
    hilog.info(0, TAG, `start request, path: ${path}, method: ${method}, extraData: ` + JSON.stringify(extraData));
    httpRequest.request(
      url,
      {
        method: method,
        expectDataType: http.HttpDataType.OBJECT,
        header: header,
        extraData: extraData
      },
      (err, data) => {
        let res = new Response<T>()
        if (!err && data.responseCode === 200) {
          cookieJar.saveFromResponse(uri, CookieUtils.parseHttpRequestCookies(data.cookies))
          if (typeof data.result === 'string') {
            Object.assign(res, JSON.parse(data.result));
          } else {
            Object.assign(res, data.result);
          }
          hilog.info(0, TAG, `request success, path: ${path}, result: ${JSON.stringify(res)}`)
        } else {
          hilog.error(0, TAG, `request error, path: ${path}, error: ${JSON.stringify(err)}`)
          res.errorCode = data?.responseCode??-1
          res.errorMsg = err?.message??""
        }
        resolve(res);
      }
    )
  })
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

  async getTopArticle(): Promise<Response<Array<Article>>> {
    return requestSync("/article/top/json", http.RequestMethod.GET);
  }

  async getHomeBanner(): Promise<Response<Array<HomeBannerData>>> {
    return requestSync("/banner/json", http.RequestMethod.GET);
  }

  async getSquareArticleList(page: number): Promise<Response<ArticleList>> {
    return requestSync(`/user_article/list/${page}/json`, http.RequestMethod.GET);
  }

  async getWeChatAuthorList(): Promise<Response<Array<WeChatAuthor>>> {
    return requestSync("/wxarticle/chapters/json", http.RequestMethod.GET)
  }

  async getWeChatArticleList(id: number, page: number): Promise<Response<ArticleList>> {
    return requestSync(`/wxarticle/list/${id}/${page}/json`, http.RequestMethod.GET);
  }

  async login(username: string, password: string): Promise<Response<User>> {
    return requestSync("/user/login", http.RequestMethod.POST, `username=${username}&password=${password}`);
  }

  async logout(): Promise<Response<string>> {
    return requestSync("/user/logout/json", http.RequestMethod.GET);
  }

  async getUserInfo(): Promise<Response<User>> {
    return requestSync("/lg/coin/userinfo/json", http.RequestMethod.GET);
  }

  async getSearchHotKey(): Promise<Response<Array<HotKey>>> {
    return requestSync("/hotkey/json", http.RequestMethod.GET)
  }

  async search(keyword: string, page: number): Promise<Response<ArticleList>> {
    return requestSync(`/article/query/${page}/json`, http.RequestMethod.POST, `k=${keyword}`)
  }

  async collect(id: number): Promise<Response<Object>> {
    return requestSync(`/lg/collect/${id}/json`, http.RequestMethod.POST)
  }

  async unCollect(id: number): Promise<Response<Object>> {
    return requestSync(`/lg/uncollect_originId/${id}/json`, http.RequestMethod.POST)
  }

  async getCollectList(page: number): Promise<Response<ArticleList>> {
    return requestSync(`/lg/collect/list/${page}/json`, http.RequestMethod.GET)
  }

  async getTree(): Promise<Response<Array<Tree>>> {
    return requestSync(`/tree/json`, http.RequestMethod.GET)
  }

  async getTreeArticleList(cid: number, page: number): Promise<Response<ArticleList>> {
    return requestSync(`/article/list/${page}/json?cid=${cid}`, http.RequestMethod.GET)
  }
}