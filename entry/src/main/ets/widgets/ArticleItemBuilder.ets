import router from '@ohos.router'
import { Article, ArticleTag, getArticleAuthor, getArticleChapter, getTagColor } from '../net/model/Article'

@Component
export struct ArticleItemBuilder {
  article: Article;
  onCollectClick: (Article) => void;

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
            if (this.onCollectClick !== undefined) {
              this.onCollectClick(this.article);
            }
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
      });
    })
  }
}