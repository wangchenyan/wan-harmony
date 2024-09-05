import { RouteExecutor } from './RouteExecutor'
import { RouteInfo, RouteMode, RouteParams } from './RouteInfo'

export class RouteRequest {
  private readonly routeInfo: RouteInfo = new RouteInfo()

  constructor(navDesInfo?: NavDestinationInfo) {
    if (navDesInfo) {
      this.routeInfo.currentParams = (navDesInfo.param ?? new Map()) as RouteParams
    }
  }

  getRouteInfo(): RouteInfo {
    return this.routeInfo
  }

  getCurrentParams(): RouteParams {
    return this.routeInfo.currentParams
  }

  url(url: string): RouteRequest {
    this.routeInfo.targetUrl = url
    return this
  }

  params(key: string, value: Object): RouteRequest {
    this.routeInfo.targetParams.set(key, value)
    return this
  }

  mode(value: RouteMode): RouteRequest {
    this.routeInfo.mode = value
    return this
  }

  animated(value: boolean): RouteRequest {
    this.routeInfo.animated = value
    return this
  }

  start(onPop?: (params: RouteParams) => void) {
    this.routeInfo.onPop = onPop
    RouteExecutor.start(this.routeInfo)
  }

  back() {
    RouteExecutor.back(this.routeInfo)
  }
}