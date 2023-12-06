import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
  tag: string = "EntryAbility"

  onCreate(want, launchParam) {
    this.context
    hilog.info(0x0000, this.tag, '%{public}s', 'Ability onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, this.tag, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, this.tag, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, this.tag, 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
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
