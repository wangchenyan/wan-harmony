import { navRouter } from './NavRouter'
import { RouteInfo, RouteParams } from './RouteInfo'

export class NavRoute {
  private readonly routeInfo: RouteInfo = new RouteInfo()

  constructor(navDesInfo?: NavDestinationInfo) {
    if (navDesInfo) {
      this.routeInfo.currentParams = (navDesInfo.param ?? new Map()) as RouteParams
    }
  }

  getRouteInfo(): RouteInfo {
    return this.routeInfo
  }

  targetUrl(url: string): NavRoute {
    this.routeInfo.targetUrl = url
    return this
  }

  params(key: string, value: Object): NavRoute {
    this.routeInfo.targetParams.set(key, value)
    return this
  }

  animated(value: boolean): NavRoute {
    this.routeInfo.animated = value
    return this
  }

  moveToTop(value: boolean): NavRoute {
    this.routeInfo.moveToTop = value
    return this
  }

  onPopListener(listener: (params: RouteParams) => void): NavRoute {
    this.routeInfo.onPopListener = listener
    return this
  }

  start() {
    navRouter.start(this.routeInfo)
  }

  back() {
    navRouter.back(this.routeInfo)
  }
}