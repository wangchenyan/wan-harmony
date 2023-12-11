import hilog from '@ohos.hilog'
import { Api } from '../net/Api'
import { Article, ArticleTag, getArticleAuthor, getArticleChapter, getTagColor, HomeBannerData, } from '../net/Model'
import { LoadState, PageLoading } from '../widgets/PageLoading'

@Component
export struct Home {
  private TAG = "Home"
  private swiperController: SwiperController = new SwiperController()
  @State bannerList: Array<HomeBannerData> = []
  @State articleList: Array<Article> = []
  @State loadState: LoadState = LoadState.LOADING
  @State bannerPosition: number = 0

  async aboutToAppear() {
    hilog.info(0, this.TAG, "aboutToAppear")
    this.loadData()
  }

  async loadData() {
    this.loadState = LoadState.LOADING
    let bannerRes = await Api.prototype.getHomeBanner()
    let topRes = await Api.prototype.getStickyArticle()
    let homeRes = await Api.prototype.getHomeArticleList(0)

    if (bannerRes.isSuccessWithData() && topRes.isSuccessWithData() && homeRes.isSuccessWithData()) {
      let articleList = []
      topRes.data.forEach((item) => {
        let tag = new ArticleTag()
        tag.name = "置顶"
        item.tags = [tag].concat(item.tags)
        articleList.push(item)
      })
      articleList = articleList.concat(homeRes.data.datas)
      this.articleList = articleList
      this.bannerList = bannerRes.data
      if (this.articleList.length === 0 && this.bannerList.length === 0) {
        this.loadState = LoadState.EMPTY
      } else {
        this.loadState = LoadState.SUCCESS
      }
    } else {
      this.loadState = LoadState.FAIL
    }
  }

  build() {
    PageLoading({
      loadState: $loadState,
      onReload: () => {
        hilog.debug(0, this.TAG, "onReload")
        this.loadData()
      }
    }) {
      Column() {
        List() {
          ListItem() {
            this.BannerBuilder()
          }

          ForEach(this.articleList, (item: Article) => {
            ListItem() {
              this.ArticleItemBuilder(item)
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
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  BannerBuilder() {
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
        .objectFit(ImageFit.Fill)
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

    })
  }

  @Builder
  ArticleItemBuilder(article: Article) {
    Column() {
      Row() {
        ForEach(article.tags, (item: ArticleTag) => {
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
        Text(getArticleAuthor(article))
          .layoutWeight(1)
          .fontColor($r("app.color.text_h1"))
          .fontSize(12)
        Divider()
          .width(8)
          .height(0)
          .color(Color.Transparent)
        Text(article.niceDate)
          .fontColor($r("app.color.text_h2"))
          .fontSize(12)
      }

      Divider()
        .width('100%')
        .height(4)
        .color(Color.Transparent)
      Text(article.title)
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
        Text(getArticleChapter(article))
          .fontColor($r("app.color.text_h2"))
          .fontSize(12)
        Blank()
        Image(article.collect ? $r("app.media.ic_like_fill") : $r("app.media.ic_like"))
          .fillColor(article.collect ? $r("app.color.red") : $r("app.color.text_h2"))
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
  }
}
