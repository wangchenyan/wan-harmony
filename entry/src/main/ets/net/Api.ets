import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import { Article, ArticleList, HomeBannerData, Response } from './Model';

let TAG = "Api"
let BASE_URL: string = "https://www.wanandroid.com"

function request(path: string, method: http.RequestMethod, callback: (Response) => void) {
  let httpRequest = http.createHttp();
  hilog.info(0, TAG, `start request, path: ${path}`)
  httpRequest.request(
    `${BASE_URL}${path}`,
    {
      method: method,
      expectDataType: http.HttpDataType.OBJECT,
    },
    (err, data) => {
      let res = new Response()
      if (!err && data.responseCode === 200) {
        Object.assign(res, data.result)
        hilog.info(0, TAG, `request success, path: ${path}, result: ${JSON.stringify(res)}`)
      } else {
        hilog.error(0, TAG, `request error, path: ${path}, error: ${JSON.stringify(err)}`)
        res.errorCode = data.responseCode
        res.errorMsg = err.message
      }
      callback(res)
    }
  )
}

function requestSync<T>(path: string, method: http.RequestMethod): Promise<Response<T>> {
  return new Promise<Response<T>>((resolve, reject) => {
    request(path, method, (res) => {
      resolve(res)
    })
  })
}

export default class Api {
  static getHomeArticleList(page: number): Promise<Response<ArticleList>> {
    return requestSync(`/article/list/${page}/json`, http.RequestMethod.GET)
  }

  static getStickyArticle(): Promise<Response<Array<Article>>> {
    return requestSync("/article/top/json", http.RequestMethod.GET)
  }

  static getHomeBanner(): Promise<Response<Array<HomeBannerData>>> {
    return requestSync("/banner/json", http.RequestMethod.GET)
  }
}