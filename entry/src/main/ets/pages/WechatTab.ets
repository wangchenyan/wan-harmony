import hilog from '@ohos.hilog';
import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import CollectUtils from '../common/CollectUtils';
import Api from '../net/Api';
import { Article } from '../net/model/Article';
import { ArticleItemComponent } from '../widgets/ArticleItemComponent';
import { LoadState, PageLoading } from '../widgets/PageLoading';

@Component
export struct WechatTab {
  authorId: number = 0;
  @State loadState: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  @State data: Article[] = [];
  private static TAG = "WechatTab"
  private scroller: Scroller = new Scroller();
  private refreshConfig = new PullToRefreshConfigurator();
  private nextPage: number = 1;
  private hasMore: boolean = true;

  aboutToAppear() {
    this.refreshConfig.setHasRefresh(false);
    this.loadData();
  }

  build() {
    Column() {
      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading,
        onReload: () => {
          hilog.debug(0, WechatTab.TAG, "onReload");
          this.loadData();
        }
      }) {
        Column() {
          PullToRefresh({
            data: $data,
            scroller: this.scroller,
            refreshConfigurator: this.refreshConfig,
            customList: () => {
              this.listViewBuilder();
            },
            onLoadMore: () => {
              return new Promise<string>((resolve, reject) => {
                if (this.hasMore) {
                  this.loadDataByPage(this.nextPage).then(
                    (data) => {
                      if (data.length > 0) {
                        this.nextPage++
                        this.data = this.data.concat(data);
                        resolve('加载成功');
                      } else {
                        this.hasMore = false;
                        resolve('没有更多了');
                      }
                    },
                    () => {
                      resolve('加载失败');
                    }
                  )
                } else {
                  resolve('没有更多了');
                }
              });
            },
            customLoad: null,
            customRefresh: null,
          })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private listViewBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (item: Article) => {
        ListItem() {
          ArticleItemComponent({
            article: item,
            clearTop: true,
            onCollectClick: (article: Article) => {
              CollectUtils.collect(article)
                .then((success) => {
                  if (success) {
                    this.data = this.data.map(item => item);
                  }
                })
            }
          })
        }
      })
    }
    .width('100%')
    .height('100%')
    .listDirection(Axis.Vertical)
    .divider({
      strokeWidth: 0.5,
      color: $r("app.color.divider"),
      startMargin: 16,
      endMargin: 16
    })
    .edgeEffect(EdgeEffect.None) // 必须设置列表为滑动到边缘无效果
  }

  private loadData() {
    if (this.authorId) {
      this.loadState = LoadState.LOADING
      this.loadDataByPage(0).then(
        (data) => {
          this.data = data;
          if (this.data.length === 0) {
            this.loadState = LoadState.EMPTY;
          } else {
            this.loadState = LoadState.SUCCESS;
          }
        },
        () => {
          this.loadState = LoadState.FAIL;
        })
    } else {
      this.loadState = LoadState.FAIL;
    }
  }

  private async loadDataByPage(page: number): Promise<Article[]> {
    const res = await Api.get().getWeChatArticleList(this.authorId, page);
    if (res.isSuccessWithData()) {
      const list = res.getDataOrThrow().datas;
      return Promise.resolve(list);
    } else {
      return Promise.reject();
    }
  }
}