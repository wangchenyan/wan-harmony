import hilog from '@ohos.hilog'
import Api from '../net/Api'
import { Article, ArticleTag, HomeBannerData, } from '../net/model/Article'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { TitleLayout } from '../widgets/TitleLayout'
import router from '@ohos.router'
import { ArticleItemBuilder } from '../widgets/ArticleItemBuilder'
import CollectUtils from '../common/CollectUtils'

@Component
export struct Home {
  @State data: Array<Object> = [];
  @State loadState: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  @State bannerPosition: number = 0;
  @State title: string = "首页";
  private tag = "Home";
  private scroller: Scroller = new Scroller();
  private nextPage: number = 1;
  private hasMore: boolean = true;

  async aboutToAppear() {
    hilog.info(0, this.tag, "aboutToAppear")
    this.loadData();
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
      (error) => {
        this.loadState = LoadState.FAIL;
      })
  }

  async loadDataByPage(page: number): Promise<Array<Object>> {
    return new Promise<Array<Object>>(async (resolve, reject) => {
      if (page === 0) {
        let bannerRes = await Api.get().getHomeBanner();
        let topRes = await Api.get().getTopArticle();
        let articleRes = await Api.get().getHomeArticleList(page);

        if (bannerRes.isSuccessWithData() && topRes.isSuccessWithData() && articleRes.isSuccessWithData()) {
          let bannerList = bannerRes.data;
          let articleList = [];
          topRes.data.forEach((item) => {
            let tag = new ArticleTag();
            tag.name = "置顶";
            item.tags = [tag].concat(item.tags);
            articleList.push(item);
          })
          articleList = articleList.concat(articleRes.data.datas);
          let dataList = [bannerList].concat(articleList);
          resolve(dataList);
        } else {
          reject();
        }
      } else {
        let articleRes = await Api.get().getHomeArticleList(page);
        if (articleRes.isSuccessWithData()) {
          resolve(articleRes.data.datas);
        } else {
          reject();
        }
      }
    })
  }

  build() {
    PageLoading({
      loadState: $loadState,
      showLoading: $showLoading,
      onReload: () => {
        hilog.debug(0, this.tag, "onReload");
        this.loadData();
      }
    }) {
      Column() {
        TitleLayout({
          title: $title,
          showBack: false,
          menuIcon: $r("app.media.ic_search"),
          onMenuClick: () => {
            router.pushUrl({
              url: 'pages/SearchEntry'
            });
          }
        })
        PullToRefresh({
          data: $data,
          scroller: this.scroller,
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
                      resolve('没有更多了')
                    }
                  },
                  (error) => {
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
  ListViewBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.data, (item: object) => {
        ListItem() {
          if (item instanceof Array) {
            BannerBuilder({
              bannerList: item
            })
          } else {
            ArticleItemBuilder({
              article: item as Article,
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

@Component
struct BannerBuilder {
  private swiperController: SwiperController = new SwiperController()
  @State private bannerPosition: number = 0
  bannerList: Array<HomeBannerData>

  build() {
    Stack() {
      Swiper(this.swiperController) {
        ForEach(this.bannerList, (item) => {
          this.BannerItemBuilder(item)
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
  BannerItemBuilder(data: HomeBannerData) {
    Stack({ alignContent: Alignment.Bottom }) {
      Image(data.imagePath)
        .objectFit(ImageFit.Cover)
        .width('100%')
        .height('100%')
      Text(data.title)
        .width('100%')
        .padding({
          left: 16, top: 6, right: 16, bottom: 6
        })
        .fontColor($r("app.color.white"))
        .fontSize(15)
        .maxLines(1)
        .backgroundColor($r("app.color.translucent_black_40"))
    }
    .width('100%')
    .height('100%')
    .onClick((event) => {
      router.pushUrl({
        url: 'pages/WebPage',
        params: {
          url: data.url
        }
      });
    })
  }
}
