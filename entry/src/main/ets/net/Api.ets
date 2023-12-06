import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import { Response } from './Model';

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
      let resp = new Response()
      if (!err && data.responseCode === 200) {
        Object.assign(resp, data.result)
        hilog.info(0, TAG, `request success, path: ${path}, result: ${JSON.stringify(resp)}`)
      } else {
        hilog.error(0, TAG, `request error, path: ${path}, error: ${JSON.stringify(err)}`)
        resp.errorCode = data.responseCode
        resp.errorMsg = err.message
      }
      callback(resp)
    }
  )
}

export class Api {
  getHomeArticleList(page: number, callback: (Response) => void) {
    request(`/article/list/${page}/json`, http.RequestMethod.GET, callback)
  }

  getStickyArticle(callback: (Response) => void) {
    request("/article/top/json", http.RequestMethod.GET, callback)
  }
}