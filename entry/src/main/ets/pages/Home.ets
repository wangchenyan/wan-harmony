import hilog from '@ohos.hilog'
import Api from '../net/Api'
import { Article, ArticleTag, HomeBannerData, } from '../net/model/Article'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { TitleLayout } from '../widgets/TitleLayout'
import { ArticleItemComponent } from '../widgets/ArticleItemComponent'
import CollectUtils from '../common/CollectUtils'
import { HRouter } from '../router/HRouter'
import { Routes } from '../Routes'

declare type HomeItemData = Article | HomeBannerData[];

@Component
export struct Home {
  @State data: HomeItemData[] = [];
  @State loadState: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  @State bannerPosition: number = 0;
  @State title: string = "首页";
  private static TAG = "Home";
  private scroller: Scroller = new Scroller();
  private nextPage: number = 1;
  private hasMore: boolean = true;

  async aboutToAppear() {
    hilog.info(0, Home.TAG, "aboutToAppear")
    this.loadData();
  }

  build() {
    PageLoading({
      loadState: this.loadState,
      showLoading: this.showLoading,
      onReload: () => {
        hilog.debug(0, Home.TAG, "onReload");
        this.loadData();
      }
    }) {
      Column() {
        TitleLayout({
          title: this.title,
          showBack: false,
          menuIcon: $r("app.media.ic_search"),
          onMenuClick: () => {
            HRouter.with()
              .url(Routes.SearchEntry)
              .start()
          }
        })
        PullToRefresh({
          data: $data,
          scroller: this.scroller,
          customList: () => {
            this.listViewBuilder();
          },
          onRefresh: () => {
            return new Promise<string>((resolve, reject) => {
              this.loadDataByPage(0).then(
                (data) => {
                  this.nextPage = 1;
                  this.data = data;
                  resolve('刷新成功');
                },
                () => {
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
                      resolve('没有更多了')
                    }
                  },
                  () => {
                    resolve('加载失败');
                  }
                )
              } else {
                resolve('没有更多了')
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

  @Builder
  private listViewBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (item: HomeItemData) => {
        ListItem() {
          if (item instanceof Array) {
            BannerComponent({
              bannerList: item
            })
          } else {
            ArticleItemComponent({
              article: item as Article,
              onCollectClick: async (article: Article) => {
                const success = await CollectUtils.collect(article)
                if (success) {
                  this.data = this.data.map(item => item);
                }
              }
            })
          }
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

  async loadData() {
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
  }

  async loadDataByPage(page: number): Promise<HomeItemData[]> {
    if (page === 0) {
      const bannerRes = await Api.get().getHomeBanner();
      const topRes = await Api.get().getTopArticle();
      const articleRes = await Api.get().getHomeArticleList(page);

      if (bannerRes.isSuccessWithData() && topRes.isSuccessWithData() && articleRes.isSuccessWithData()) {
        const bannerList = bannerRes.getDataOrThrow();
        let articleList: Article[] = [];
        topRes.getDataOrThrow().forEach((item) => {
          const tag = new ArticleTag();
          tag.name = "置顶";
          item.tags = [tag].concat(item.tags);
          articleList.push(item);
        })
        articleList = articleList.concat(articleRes.getDataOrThrow().datas);
        let dataList: HomeItemData[] = [];
        dataList.push(bannerList);
        dataList = dataList.concat(articleList);
        return Promise.resolve(dataList);
      } else {
        return Promise.reject();
      }
    } else {
      const articleRes = await Api.get().getHomeArticleList(page);
      if (articleRes.isSuccessWithData()) {
        return Promise.resolve(articleRes.getDataOrThrow().datas);
      } else {
        return Promise.reject();
      }
    }
  }
}

@Component
struct BannerComponent {
  private swiperController: SwiperController = new SwiperController()
  @State private bannerPosition: number = 0
  bannerList: HomeBannerData[] = []

  build() {
    Stack() {
      Swiper(this.swiperController) {
        ForEach(this.bannerList, (item: HomeBannerData) => {
          this.bannerItemBuilder(item)
        })
      }
      .autoPlay(true)
      .index(this.bannerPosition)
      .loop(true)
      .indicatorStyle({
        right: 16,
        bottom: 0
      })
      .onChange((index) => {
        this.bannerPosition = index;
      })
    }
    .width('100%')
    .height(220)
  }

  @Builder
  private bannerItemBuilder(data: HomeBannerData) {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(data.imagePath)
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('100%')
      Text(data.title)
        .width('100%')
        .padding({
          left: 16,
          top: 6,
          right: 16,
          bottom: 6
        })
        .fontColor($r("app.color.white"))
        .fontSize(15)
        .maxLines(1)
        .backgroundColor($r("app.color.translucent_black_40"))
    }
    .width('100%')
    .height('100%')
    .onClick((event) => {
      HRouter.with()
        .url(Routes.Web)
        .params('url', data.url)
        .start()
    })
  }
}
