import hilog from '@ohos.hilog'
import { Api } from '../net/Api'
import {
  Article,
  ArticleList,
  ArticleTag,
  getArticleAuthor,
  getArticleChapter,
  getTagColor,
  Response
} from '../net/Model'

@Component
export struct Home {
  private tag = "Home"
  @State articleList: Array<Article> = []

  aboutToAppear() {
    hilog.info(0, this.tag, "aboutToAppear")
    Api.prototype.getStickyArticle((resp: Response<Array<Article>>) => {
      if (resp.isSuccessWithData()) {
        let list = resp.data
        list.forEach((item) => {
          let tag = new ArticleTag()
          tag.name = "置顶"
          item.tags = [tag].concat(item.tags)
        })
        this.articleList = list.concat(this.articleList)
      } else {
      }
    })
    Api.prototype.getHomeArticleList(0, (resp: Response<ArticleList>) => {
      if (resp.isSuccessWithData()) {
        this.articleList = this.articleList.concat(resp.data.datas)
      } else {
      }
    })
  }

  build() {
    Column() {
      List() {
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
