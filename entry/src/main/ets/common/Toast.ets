import promptAction from '@ohos.promptAction';
import WindowUtils from './WindowUtils';

export function toast(message: ResourceStr | undefined) {
  if (message) {
    const bottom = WindowUtils.windowHeight > 0 ? (WindowUtils.windowHeight / 2 + 'px') : undefined;
    promptAction.showToast({
      message: message,
      bottom: bottom
    })
  }
}
