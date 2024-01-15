import hilog from '@ohos.hilog';
import router from '@ohos.router';
import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import Api from '../net/Api';
import { Article } from '../net/model/Article';
import { ArticleItemBuilder } from '../widgets/ArticleItemBuilder';
import { LoadState, PageLoading } from '../widgets/PageLoading';
import { TitleLayout } from '../widgets/TitleLayout';

@Entry
@Component
struct SearchResult {
  @State loadState: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  @State title: string = "";
  @State data: Array<Article> = [];
  private tag = "SearchResult"
  private keyword: string
  private scroller: Scroller = new Scroller();
  private refreshConfig = new PullToRefreshConfigurator();
  private nextPage: number = 1;
  private hasMore: boolean = true;

  aboutToAppear() {
    this.keyword = router.getParams()['keyword']
    this.title = this.keyword;
    this.refreshConfig.setHasRefresh(false);
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
    let res = await Api.get().search(this.keyword, page);
    if (res.isSuccessWithData()) {
      return new Promise<Array<Article>>((resolve, reject) => {
        let list = res.data.datas;
        list.forEach((item) => {
          item.title = this.removeHtmlTags(item.title);
        })
        resolve(list);
      })
    } else {
      return new Promise<Array<Article>>((resolve, reject) => {
        reject();
      })
    }
  }

  private removeHtmlTags(text: string): string {
    // 使用正则表达式将 < 开头到 > 结尾之间的部分全部替换成空字符串
    return text.replace(/<[^>]+>/g, '')
      .replace('&gt;', '>')
      .replace('&lt;', '<');
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
            article: item
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