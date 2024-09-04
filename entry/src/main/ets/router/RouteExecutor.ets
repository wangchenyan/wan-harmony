import { HRouter } from './HRouter'
import { RouteInfo, RouteParams } from './RouteInfo'

class _RouteExecutor {
  start(info: RouteInfo) {
    let builder = HRouter.getNavDesBuilder(info.targetUrl)
    if (!builder) {
      return
    }
    if (info.moveToTop) {
      let indices = HRouter.pathStack.getIndexByName(info.targetUrl)
      if (indices.length) {
        HRouter.pathStack.moveIndexToTop(indices[indices.length - 1], info.animated)
      } else {
        this.startWithStandardMode(info)
      }
    } else {
      this.startWithStandardMode(info)
    }
  }

  back(info: RouteInfo) {
    HRouter.pathStack.pop(info.targetParams, info.animated)
  }

  private startWithStandardMode(info: RouteInfo) {
    if (info.onPop) {
      let onPopListener = info.onPop
      HRouter.pathStack.pushPathByName(info.targetUrl, info.targetParams, (popInfo) => {
        onPopListener(popInfo.result as RouteParams)
      }, info.animated)
    } else {
      HRouter.pathStack.pushPathByName(info.targetUrl, info.targetParams, info.animated)
    }
  }
}

export const RouteExecutor: _RouteExecutor = new _RouteExecutor();