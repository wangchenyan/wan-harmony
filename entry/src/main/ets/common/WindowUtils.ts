import window from '@ohos.window'

export default class WindowUtils {
  static statusBarHeight: number = 0
  static navigationBarHeight: number = 0
  static windowWidth: number = 0
  static windowHeight: number = 0

  static init(windowClass: window.Window) {
    let windowRect = windowClass.getWindowProperties().windowRect;
    WindowUtils.windowWidth = windowRect.width;
    WindowUtils.windowHeight = windowRect.height;
    let statusBarAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    WindowUtils.statusBarHeight = statusBarAvoidArea.topRect.height;
    let navigationBarAvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    WindowUtils.navigationBarHeight = navigationBarAvoidArea.bottomRect.height;
  }
}