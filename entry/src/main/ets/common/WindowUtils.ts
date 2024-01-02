import window from '@ohos.window'

export default class WindowUtils {
  static statusBarHeight: number = -1
  static windowWidth: number = -1
  static windowHeight: number = -1

  static init(windowClass: window.Window) {
    let windowRect = windowClass.getWindowProperties().windowRect;
    WindowUtils.windowWidth = windowRect.width;
    WindowUtils.windowHeight = windowRect.height;
    let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    WindowUtils.statusBarHeight = avoidArea.topRect.height;
  }
}