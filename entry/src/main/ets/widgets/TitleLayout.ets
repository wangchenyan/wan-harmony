import router from '@ohos.router'
import SystemBarUtils from '../common/SystemBarUtils'

@Component
export struct TitleLayout {
  @Link title: string
  isJustShowStatusBar: boolean = false
  onBack: () => void = () => {
    router.back()
  }
  menuIcon?: Resource
  onMenuClick?: () => void

  build() {
    Column() {
      Blank()
        .width('100%')
        .height(SystemBarUtils.statusBarHeight + 'px')
      if (this.isJustShowStatusBar === false) {
        Row() {
          if (this.onBack !== undefined) {
            Image($r("app.media.ic_back"))
              .width(48)
              .height(48)
              .padding(14)
              .fillColor($r("app.color.text_h1"))
              .objectFit(ImageFit.Contain)
              .onClick((event) => {
                if (this.onBack !== undefined) {
                  this.onBack()
                }
              })
          }
          Text(this.title)
            .layoutWeight(1)
            .fontSize(17)
            .fontColor($r("app.color.text_h1"))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: 16, right: 16 })
          if (this.menuIcon !== undefined) {
            Image(this.menuIcon)
              .width(48)
              .height(48)
              .padding(14)
              .fillColor($r("app.color.text_h1"))
              .objectFit(ImageFit.Contain)
              .onClick((event) => {
                if (this.onMenuClick !== undefined) {
                  this.onMenuClick()
                }
              })
          }
        }
        .width('100%')
        .height(48)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .backgroundColor($r("app.color.title_bar_bg"))
  }
}