import { RouteRequest } from './RouteRequest'
import { RouteParams } from './RouteInfo'

class _HRouter {
  readonly pathStack: NavPathStack = new NavPathStack()
  private readonly navDesBuilderMap: Map<string, WrappedBuilder<[RouteParams]>> = new Map()

  register(url: string, builder: WrappedBuilder<[RouteParams]>) {
    this.navDesBuilderMap.set(url, builder)
  }

  getNavDesBuilder(url: string): WrappedBuilder<[RouteParams]> | undefined {
    return this.navDesBuilderMap.get(url)
  }

  with(info?: NavDestinationInfo): RouteRequest {
    return new RouteRequest(info)
  }

  clearStack() {
    this.pathStack.clear(false)
  }
}

export const HRouter: _HRouter = new _HRouter()
