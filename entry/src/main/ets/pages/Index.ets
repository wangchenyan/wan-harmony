import { Home } from './Home'
import { Square } from './Square'
import { Mine } from './Mine'
import { Wechat } from './Wechat'
import OHPermission from '../common/OHPermission'
import { TreeTab } from './TreeTab'
import WindowUtils from '../common/WindowUtils'

@Entry
@Component
struct Index {
  private tag = "Index"
  private tabsController = new TabsController()
  @State currentIndex: number = 0
  @State isPermissionGrant: boolean = false

  build() {
    Column() {
      if (this.isPermissionGrant) {
        Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
          TabContent() {
            Home()
          }.tabBar(this.tabBuilder("首页", 0, $r("app.media.ic_tab_home_fill"), $r("app.media.ic_tab_home")))

          TabContent() {
            Square()
          }.tabBar(this.tabBuilder("广场", 1, $r("app.media.ic_tab_discover_fill"), $r("app.media.ic_tab_discover")))

          TabContent() {
            TreeTab()
          }.tabBar(this.tabBuilder("体系", 2, $r("app.media.ic_tab_tree_fill"), $r("app.media.ic_tab_tree")))

          TabContent() {
            Wechat()
          }.tabBar(this.tabBuilder("公众号", 3, $r("app.media.ic_tab_wechat_fill"), $r("app.media.ic_tab_wechat")))

          TabContent() {
            Mine()
          }.tabBar(this.tabBuilder("我的", 4, $r("app.media.ic_tab_my_fill"), $r("app.media.ic_tab_my")))
        }
        .layoutWeight(1)
        .scrollable(false)
        .animationDuration(0)
        .onChange((index) => {
          this.currentIndex = index
        })
        .backgroundColor($r("app.color.start_window_background"))
      } else {
        Text("No Permission")
          .width('100%')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      Row()
        .width('100%')
        .height(WindowUtils.navigationBarHeight + 'px')
        .backgroundColor($r("app.color.navi_bar_bg"))
    }
  }

  aboutToAppear() {
    OHPermission.requestPermission(getContext(this), ['ohos.permission.INTERNET'])
      .then((v) => {
        this.isPermissionGrant = true;
      })
      .catch(() => {
        this.isPermissionGrant = false;
      })
  }

  @Builder
  tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 })
        .fillColor(this.currentIndex === targetIndex ? $r("app.color.main") : $r("app.color.navi_tab_unselect"))
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? $r("app.color.main") : $r("app.color.navi_tab_unselect"))
        .fontSize(11)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r("app.color.navi_bar_bg"))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex
      this.tabsController.changeIndex(targetIndex)
    })
  }
}