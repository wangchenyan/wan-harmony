import hilog from '@ohos.hilog';
import Api from '../net/Api';
import { WeChatAuthor } from '../net/model/WeChat';
import { LoadState, PageLoading } from '../widgets/PageLoading';
import { TitleLayout } from '../widgets/TitleLayout';
import { WechatTab } from './WechatTab';

@Component
export struct Wechat {
  @State title: string = "公众号";
  @State loadState: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  @State authors: Array<WeChatAuthor> = []
  private tag = "Square"

  aboutToAppear() {
    this.loadData();
  }

  private loadData() {
    this.loadState = LoadState.LOADING
    Api.get().getWeChatAuthorList()
      .then((res) => {
        if (res.isSuccessWithData()) {
          this.authors = res.data;
          if (this.authors.length === 0) {
            this.loadState = LoadState.EMPTY;
          } else {
            this.loadState = LoadState.SUCCESS;
          }
        } else {
          this.loadState = LoadState.FAIL;
        }
      })
  }

  build() {
    Column() {
      TitleLayout({
        title: $title,
        showBack: false,
      })
      PageLoading({
        loadState: $loadState,
        showLoading: $showLoading,
        onReload: () => {
          hilog.debug(0, this.tag, "onReload");
          this.loadData();
        }
      }) {
        if (this.authors.length > 0) {
          Tabs({
            barPosition: BarPosition.Start
          }) {
            ForEach(this.authors, (author: WeChatAuthor) => {
              TabContent() {
                WechatTab({
                  authorId: author.id
                })
              }
              .tabBar(author.name)
            })
          }
          .width('100%')
          .height('100%')
          .scrollable(true)
          .barMode(BarMode.Scrollable)
          .barHeight(44)
        }
      }
    }
    .width('100%')
    .height('100%')
  }
}