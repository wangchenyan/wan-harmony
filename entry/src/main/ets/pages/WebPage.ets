import web_webview from '@ohos.web.webview';
import { TitleLayout } from '../widgets/TitleLayout';
import { navRouter } from '../router/NavRouter';
import { RouteParams } from '../router/RouteInfo';

@Component
export struct WebPage {
  private webController: web_webview.WebviewController = new web_webview.WebviewController()
  url: string = ''
  @State title: string = "加载中…"
  @State progress: number = 0

  build() {
    NavDestination() {
      Column() {
        TitleLayout({
          title: this.title,
          onBack: () => {
            if (this.webController.accessBackward()) {
              this.webController.backward()
            } else {
              navRouter.open().back();
            }
          }
        })
        Stack({ alignContent: Alignment.Top }) {
          Web({
            src: this.url,
            controller: this.webController
          })
            .width('100%')
            .height('100%')
            .onlineImageAccess(true)
            .javaScriptAccess(true)
            .domStorageAccess(true)
            .databaseAccess(true)
            .mixedMode(MixedMode.All)
            .onTitleReceive((event) => {
              this.title = event?.title ?? ""
            })
            .onProgressChange((event) => {
              this.progress = event?.newProgress ?? 0
            })
          if (this.progress !== 100) {
            Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
              .width('100%')
          }
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      if (this.webController.accessBackward()) {
        this.webController.backward()
        return true;
      }
      return false;
    })
  }
}

@Builder
export function webPageNavDesBuilder(params: RouteParams) {
  WebPage({
    url: params.get('url') as string
  })
}