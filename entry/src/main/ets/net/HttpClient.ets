import CookieJar from './cookie/CookieJar'
import { http } from '@kit.NetworkKit'
import { Response } from './Response'
import { Headers } from './Headers'
import { uri } from '@kit.ArkTS'
import CookieUtils from './cookie/CookieUtils'
import { hilog } from '@kit.PerformanceAnalysisKit'
import UserService from '../service/UserService'

const TAG = "HttpClient";
const CODE_UNAUTH = -1001;

export class HttpClient {
  readonly baseUrl: string
  readonly cookieJar: CookieJar

  constructor(baseUrl: string, cookieJar: CookieJar) {
    this.baseUrl = baseUrl
    this.cookieJar = cookieJar
  }

  async get<T>(path: string): Promise<Response<T>> {
    return this.requestSync(path, http.RequestMethod.GET);
  }

  async post<T>(path: string, extraData?: object): Promise<Response<T>> {
    return this.requestSync(path, http.RequestMethod.POST, extraData);
  }

  async requestSync<T>(
    path: string,
    method: http.RequestMethod,
    extraData?: object
  ): Promise<Response<T>> {
    const headers = new Headers();
    const url = this.baseUrl + path;
    const uri = this.parseUri(url);
    const cookies = this.cookieJar.loadForRequest(uri);
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

    const res = new Response<T>()
    let resp: http.HttpResponse

    try {
      resp = await httpRequest.request(
        url,
        {
          method: method,
          expectDataType: http.HttpDataType.OBJECT,
          header: headers,
          extraData: extraData
        })
    } catch (err) {
      hilog.error(0, TAG, `request error, path: ${path}, error: ${JSON.stringify(err, undefined, undefined)}`)
      res.errorCode = -1
      res.errorMsg = err?.message ?? ""
      return res;
    }

    if (resp.responseCode === 200) {
      this.cookieJar.saveFromResponse(uri, CookieUtils.parseHttpRequestCookies(resp.cookies))
      if (resp.resultType === http.HttpDataType.STRING) {
        const result: Response<T> = JSON.parse(resp.result as string);
        res.errorCode = result.errorCode;
        res.errorMsg = result.errorMsg;
        res.data = result.data;
      } else if (resp.resultType === http.HttpDataType.OBJECT) {
        const result = resp.result as Response<T>;
        res.errorCode = result.errorCode;
        res.errorMsg = result.errorMsg;
        res.data = result.data;
      } else {
        res.errorCode = -1
        res.errorMsg = `UnSupport data type: ${resp.resultType}`
      }

      hilog.info(0, TAG, `request success, path: ${path}, result: ${JSON.stringify(res, undefined, undefined)}`)

      if (res.errorCode === CODE_UNAUTH) {
        // token 失效
        UserService.get().clearUser();
      }
    } else {
      hilog.error(0, TAG, `request error, path: ${path}, http code: ${resp.responseCode}`)
      res.errorCode = resp.responseCode
    }

    return res;
  }

  private parseUri(url: string): uri.URI {
    return new uri.URI(url);
  }
}