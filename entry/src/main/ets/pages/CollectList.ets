import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import hilog from '@ohos.hilog';
import Api from '../net/Api';
import { Article } from '../net/model/Article';
import { LoadState, PageLoading } from '../widgets/PageLoading';
import { TitleLayout } from '../widgets/TitleLayout';
import { ArticleItemBuilder } from '../widgets/ArticleItemBuilder';
import CollectUtils from '../common/CollectUtils';

@Entry
@Component
struct CollectList {
  @State loadState: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  @State title: string = "我的收藏";
  @State data: Array<Article> = [];
  private tag = "CollectList"
  private scroller: Scroller = new Scroller();
  private refreshConfig = new PullToRefreshConfigurator();
  private nextPage: number = 1;
  private hasMore: boolean = true;

  aboutToAppear() {
    this.loadData();
  }

  private loadData() {
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
      (error) => {
        this.loadState = LoadState.FAIL;
      })
  }

  private async loadDataByPage(page: number): Promise<Array<Article>> {
    let res = await Api.get().getCollectList(page);
    return new Promise<Array<Article>>((resolve, reject) => {
      if (res.isSuccessWithData()) {
        let list = res.data.datas;
        list.forEach((item) => {
          item.collect = true;
        })
        resolve(list);
      } else {
        reject();
      }
    })
  }

  build() {
    Column() {
      TitleLayout({
        title: $title
      })
      PageLoading({
        loadState: $loadState,
        showLoading: $showLoading,
        onReload: () => {
          hilog.debug(0, this.tag, "onReload");
          this.loadData();
        }
      }) {
        Column() {
          PullToRefresh({
            data: $data,
            scroller: this.scroller,
            refreshConfigurator: this.refreshConfig,
            customList: this.ListViewBuilder,
            onRefresh: () => {
              return new Promise<string>((resolve, reject) => {
                this.loadDataByPage(0).then(
                  (data) => {
                    this.nextPage = 1;
                    this.data = data;
                    resolve('刷新成功');
                  },
                  (error) => {
                    resolve('刷新失败');
                  }
                )
              });
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
                    (error) => {
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
  ListViewBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (item: Article) => {
        ListItem() {
          ArticleItemBuilder({
            article: item,
            onCollectClick: (article: Article) => {
              CollectUtils.collect(article, article.originId)
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
}
