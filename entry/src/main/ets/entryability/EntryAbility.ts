import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import EntryContext from '../common/EntryContext';
import WindowUtils from '../common/WindowUtils'

export default class EntryAbility extends UIAbility {
  tag: string = "EntryAbility"

  onCreate(want, launchParam) {
    hilog.info(0x0000, this.tag, '%{public}s', 'Ability onCreate');
    EntryContext.setContext(this.context)
  }

  async onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, this.tag, '%{public}s', 'Ability onWindowStageCreate');

    let windowClass = await windowStage.getMainWindow();
    hilog.info(0x0000, this.tag, 'Succeeded in obtaining the main window. Data: ' + JSON.stringify(windowClass));
    WindowUtils.init(windowClass);

    let data = await windowStage.loadContent('pages/Index');
    hilog.info(0x0000, this.tag, 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, this.tag, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, this.tag, '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, this.tag, '%{public}s', 'Ability onBackground');
  }

  onDestroy() {
    hilog.info(0x0000, this.tag, '%{public}s', 'Ability onDestroy');
  }
}
