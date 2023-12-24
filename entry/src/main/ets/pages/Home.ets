import hilog from '@ohos.hilog'
import Api from '../net/Api'
import { Article, ArticleTag, getArticleAuthor, getArticleChapter, getTagColor, HomeBannerData, } from '../net/Model'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { PullToRefresh } from '@ohos/pulltorefresh'
import { TitleLayout } from '../widgets/TitleLayout'
import router from '@ohos.router'

const TAG = "Home"

@Component
export struct Home {
  private scroller: Scroller = new Scroller()
  private page: number = 0
  @State data: Array<Object> = []
  @State loadState: LoadState = LoadState.LOADING
  @State bannerPosition: number = 0
  @State title: string = "首页"

  async aboutToAppear() {
    hilog.info(0, TAG, "aboutToAppear")
    this.loadData()
  }

  async loadData() {
    this.loadState = LoadState.LOADING
    this.loadDataByPage(0).then(
      (data) => {
        this.data = data
        if (this.data.length === 0) {
          this.loadState = LoadState.EMPTY
        } else {
          this.loadState = LoadState.SUCCESS
        }
      },
      (error) => {
        this.loadState = LoadState.FAIL
      })
  }

  async loadDataByPage(page: number): Promise<Array<Object>> {
    return new Promise<Array<Object>>(async (resolve, reject) => {
      if (page === 0) {
        let bannerRes = await Api.get().getHomeBanner()
        let topRes = await Api.get().getStickyArticle()
        let articleRes = await Api.get().getHomeArticleList(page)

        if (bannerRes.isSuccessWithData() && topRes.isSuccessWithData() && articleRes.isSuccessWithData()) {
          let bannerList = bannerRes.data
          let articleList = []
          topRes.data.forEach((item) => {
            let tag = new ArticleTag()
            tag.name = "置顶"
            item.tags = [tag].concat(item.tags)
            articleList.push(item)
          })
          articleList = articleList.concat(articleRes.data.datas)
          let dataList = [bannerList].concat(articleList)
          resolve(dataList)
        } else {
          reject()
        }
      } else {
        let articleRes = await Api.get().getHomeArticleList(page)
        if (articleRes.isSuccessWithData()) {
          resolve(articleRes.data.datas)
        } else {
          reject()
        }
      }
    })
  }

  build() {
    PageLoading({
      loadState: $loadState,
      onReload: () => {
        hilog.debug(0, TAG, "onReload")
        this.loadData()
      }
    }) {
      Column() {
        TitleLayout({
          title: $title,
          menuIcon: $r("app.media.ic_search"),
          onMenuClick: () => {
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
                  resolve('刷新成功');
                  this.data = data
                },
                (error) => {
                  resolve('刷新失败');
                }
              )
            });
          },
          onLoadMore: () => {
            return new Promise<string>((resolve, reject) => {
              this.page++
              this.loadDataByPage(this.page).then(
                (data) => {
                  resolve('加载成功');
                  this.data = this.data.concat(data)
                },
                (error) => {
                  resolve('加载失败');
                }
              )
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
              article: item as Article
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
        this.bannerPosition = index
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
      })
    })
  }
}

@Component
struct ArticleItemBuilder {
  article: Article

  build() {
    Column() {
      Row() {
        ForEach(this.article.tags, (item: ArticleTag) => {
          Text(item.name)
            .fontColor(getTagColor(item))
            .fontSize(10)
            .textAlign(TextAlign.Center)
            .borderWidth(0.5)
            .border({
              width: 0.5,
              color: getTagColor(item),
              radius: 3
            })
            .padding({
              left: 2, top: 1, right: 2, bottom: 1
            })
          Divider()
            .width(8)
            .height(0)
            .color(Color.Transparent)
        })
        Text(getArticleAuthor(this.article))
          .layoutWeight(1)
          .fontColor($r("app.color.text_h1"))
          .fontSize(12)
        Divider()
          .width(8)
          .height(0)
          .color(Color.Transparent)
        Text(this.article.niceDate)
          .fontColor($r("app.color.text_h2"))
          .fontSize(12)
      }

      Divider()
        .width('100%')
        .height(4)
        .color(Color.Transparent)
      Text(this.article.title)
        .width('100%')
        .fontColor($r("app.color.text_h1"))
        .fontSize(15)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Divider()
        .width('100%')
        .height(5)
        .color(Color.Transparent)
      Row() {
        Text(getArticleChapter(this.article))
          .fontColor($r("app.color.text_h2"))
          .fontSize(12)
        Blank()
        Image(this.article.collect ? $r("app.media.ic_like_fill") : $r("app.media.ic_like"))
          .fillColor(this.article.collect ? $r("app.color.red") : $r("app.color.text_h2"))
          .width(24)
          .height(24)
          .onClick((event) => {

          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .width('100%')
    .padding({ left: 16, top: 10, right: 16, bottom: 10 })
    .onClick((e) => {
      router.pushUrl({
        url: 'pages/WebPage',
        params: {
          url: this.article.link
        }
      })
    })
  }
}
