import { HRouter } from './HRouter'
import { RouteInfo, RouteMode, RouteParams } from './RouteInfo'

class _RouteExecutor {
  start(info: RouteInfo) {
    let builder = HRouter.getNavDesBuilder(info.targetUrl)
    if (!builder) {
      return
    }
    switch (info.mode) {
      case RouteMode.ClearTop:
        this.startWithClearTop(info)
        break;
      case RouteMode.MoveToTop:
        this.startWithMoveToTop(info)
        break;
      case RouteMode.Standard:
      default:
        this.startWithStandardMode(info)
        break;
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

  private startWithClearTop(info: RouteInfo) {
    let indices = HRouter.pathStack.getIndexByName(info.targetUrl)
    if (indices.length) {
      let lastIndex = indices[indices.length - 1]
      while (lastIndex <= HRouter.pathStack.size() - 1) {
        HRouter.pathStack.pop(false)
      }
      setTimeout(() => {
        this.startWithStandardMode(info)
      }, 16)
    } else {
      this.startWithStandardMode(info)
    }
  }

  private startWithMoveToTop(info: RouteInfo) {
    let indices = HRouter.pathStack.getIndexByName(info.targetUrl)
    if (indices.length) {
      HRouter.pathStack.moveIndexToTop(indices[indices.length - 1], info.animated)
    } else {
      this.startWithStandardMode(info)
    }
  }
}

export const RouteExecutor: _RouteExecutor = new _RouteExecutor();