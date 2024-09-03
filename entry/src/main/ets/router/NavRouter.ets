import { NavRoute } from './NavRoute'
import { RouteInfo, RouteParams } from './RouteInfo'

class NavRouter {
  readonly pathStack: NavPathStack = new NavPathStack()
  private readonly navDesBuilderMap: Map<string, WrappedBuilder<[RouteParams]>> = new Map()

  register(url: string, builder: WrappedBuilder<[RouteParams]>) {
    this.navDesBuilderMap.set(url, builder)
  }

  getNavDesBuilder(url: string): WrappedBuilder<[RouteParams]> {
    return this.navDesBuilderMap.get(url)!
  }

  open(info?: NavDestinationInfo): NavRoute {
    return new NavRoute(info)
  }

  start(info: RouteInfo) {
    let builder = this.navDesBuilderMap.get(info.targetUrl)
    if (!builder) {
      return
    }
    if (info.moveToTop) {
      let indices = this.pathStack.getIndexByName(info.targetUrl)
      if (indices.length) {
        this.pathStack.moveIndexToTop(indices[indices.length - 1], info.animated)
      } else {
        this.startWithStandardMode(info)
      }
    } else {
      this.startWithStandardMode(info)
    }
  }

  back(info: RouteInfo) {
    this.pathStack.pop(info.targetParams, info.animated)
  }

  clearStack() {
    this.pathStack.clear(false)
  }

  private startWithStandardMode(info: RouteInfo) {
    if (info.onPopListener) {
      let onPopListener = info.onPopListener
      this.pathStack.pushPathByName(info.targetUrl, info.targetParams, (popInfo) => {
        onPopListener(popInfo.result as RouteParams)
      }, info.animated)
    } else {
      this.pathStack.pushPathByName(info.targetUrl, info.targetParams, info.animated)
    }
  }
}

export const navRouter: NavRouter = new NavRouter()
