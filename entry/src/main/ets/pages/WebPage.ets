import web_webview from '@ohos.web.webview';
import router from '@ohos.router';
import { TitleLayout } from '../widgets/TitleLayout';

@Entry
@Component
export struct WebPage {
  private webController: web_webview.WebviewController = new web_webview.WebviewController()
  private url: string = (router.getParams() as WebPageParams).url
  @State title: string = "加载中…"
  @State progress: number = 0

  onBackPress(): boolean | void {
    if (this.webController.accessBackward()) {
      this.webController.backward()
      return true;
    }
    return false;
  }

  build() {
    Column() {
      TitleLayout({
        title: $title,
        onBack: () => {
          if (this.webController.accessBackward()) {
            this.webController.backward()
          } else {
            router.back()
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
        if (this.progress != 100) {
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
}

export class WebPageParams {
  url: string = ""

  constructor(url: string) {
    this.url = url;
  }
}