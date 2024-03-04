import { Home } from './Home'
import { Square } from './Square'
import { Mine } from './Mine'
import { Wechat } from './Wechat'
import OHPermission from '../common/OHPermission'
import { TreeTab } from './TreeTab'

@Entry
@Component
struct Index {
  private tag = "Index"
  private tabsController = new TabsController()
  @State currentIndex: number = 0
  @State isPermissionGrant: boolean = false

  build() {
    if (this.isPermissionGrant) {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          Home()
        }.tabBar(this.TabBuilder("首页", 0, $r("app.media.ic_tab_home_fill"), $r("app.media.ic_tab_home")))

        TabContent() {
          Square()
        }.tabBar(this.TabBuilder("广场", 1, $r("app.media.ic_tab_discover_fill"), $r("app.media.ic_tab_discover")))

        TabContent() {
          TreeTab()
        }.tabBar(this.TabBuilder("体系", 2, $r("app.media.ic_tab_tree_fill"), $r("app.media.ic_tab_tree")))

        TabContent() {
          Wechat()
        }.tabBar(this.TabBuilder("公众号", 3, $r("app.media.ic_tab_wechat_fill"), $r("app.media.ic_tab_wechat")))

        TabContent() {
          Mine()
        }.tabBar(this.TabBuilder("我的", 4, $r("app.media.ic_tab_my_fill"), $r("app.media.ic_tab_my")))
      }
      .scrollable(false)
      .onChange((index) => {
        this.currentIndex = index
      })
      .backgroundColor($r("app.color.start_window_background"))
    } else {
      Text("No Permission")
        .textAlign(TextAlign.Center)
    }
  }

  aboutToAppear() {
    OHPermission.requestPermission(getContext(this), ['ohos.permission.INTERNET'])
      .then((v) => {
        this.isPermissionGrant = true;
      })
      .catch((err) => {
        this.isPermissionGrant = false;
      })
  }

  @Builder
  TabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 24, height: 24 })
        .fillColor(this.currentIndex === targetIndex ? $r("app.color.main") : $r("app.color.navi_tab_unselect"))
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? $r("app.color.main") : $r("app.color.navi_tab_unselect"))
        .fontSize(11)
    }
    .width("100%")
    .height("100%")
    .backgroundColor($r("app.color.navi_bar_bg"))
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex
      this.tabsController.changeIndex(targetIndex)
    })
  }
}