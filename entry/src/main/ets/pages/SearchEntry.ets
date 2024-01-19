import router from '@ohos.router'
import WindowUtils from '../common/WindowUtils'
import Api from '../net/Api'
import { HotKey } from '../net/model/Search'
import Preferences from '../common/Preferences'
import { toast } from '../common/Toast'

@Entry
@Component
struct SearchEntry {
  @State showKeyword: string = ""
  @State hotKeys: Array<HotKey> = []
  @State historyKeys: Array<string> = []
  private keyword: string = ""

  async aboutToAppear() {
    this.historyKeys = await Preferences.get(getContext()).getSearchHistory()
    let res = await Api.get().getSearchHotKey()
    if (res.isSuccessWithData()) {
      this.hotKeys = res.data;
    }
  }

  search() {
    if (!this.keyword) {
      toast("请输入关键词");
      return;
    }
    let historyKeys = this.historyKeys;
    let existIndex = historyKeys.findIndex((value) => {
      return this.keyword === value;
    })
    if (existIndex >= 0) {
      historyKeys.splice(existIndex, 1);
    }
    historyKeys.unshift(this.keyword);
    this.historyKeys = historyKeys;
    Preferences.get(getContext()).putSearchHistory(historyKeys);
    router.pushUrl({
      url: 'pages/SearchResult',
      params: {
        keyword: this.keyword
      }
    });
  }

  deleteHistory(index: number) {
    let historyKeys = this.historyKeys;
    historyKeys.splice(index, 1);
    this.historyKeys = historyKeys;
    Preferences.get(getContext()).putSearchHistory(historyKeys);
  }

  build() {
    Column() {
      Row()
        .width('100%')
        .height(WindowUtils.statusBarHeight + 'px')
      Row() {
        Image($r("app.media.ic_back"))
          .width(48)
          .height(48)
          .padding(14)
          .fillColor($r("app.color.text_h1"))
          .objectFit(ImageFit.Contain)
          .onClick((event) => {
            router.back();
          })
        TextInput({
          placeholder: "关键词以空格隔开",
          text: this.showKeyword
        })
          .layoutWeight(1)
          .fontSize(17)
          .fontColor($r("app.color.text_h1"))
          .padding({ left: 16, right: 16 })
          .onChange((value) => {
            this.keyword = value;
          })
          .onSubmit((keyType) => {
            this.search();
          })
        Image($r("app.media.ic_search"))
          .width(48)
          .height(48)
          .padding(14)
          .fillColor($r("app.color.text_h1"))
          .objectFit(ImageFit.Contain)
          .onClick((event) => {
            this.search();
          })
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)

      Column() {
        Text("热门搜索")
          .fontColor($r("app.color.text_h1"))
          .fontSize(16)
          .width('100%')
          .margin({ top: 16 })
          .padding({ left: 16, right: 16 })
        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.Wrap
        }) {
          ForEach(this.hotKeys, (key: HotKey) => {
            Text(key.name)
              .fontColor($r("app.color.text_h1"))
              .fontSize(14)
              .padding({ left: 12, top: 6, right: 12, bottom: 6 })
              .maxLines(1)
              .backgroundColor($r("app.color.hot_key_bg"))
              .borderRadius(50)
              .margin({ top: 8, right: 8 })
              .onClick((event) => {
                this.showKeyword = key.name;
                this.keyword = key.name;
                this.search();
              })
          })
        }
        .width('100%')
        .margin({ top: 8 })
        .padding({ left: 16, right: 16 })

        Text("搜索历史")
          .fontColor($r("app.color.text_h1"))
          .fontSize(16)
          .width('100%')
          .margin({ top: 16 })
          .padding({ left: 16, right: 16 })
        List() {
          ForEach(this.historyKeys, (item: string, index: number) => {
            ListItem() {
              Row() {
                Text(item)
                  .fontColor($r("app.color.text_h2"))
                  .fontSize(14)
                  .layoutWeight(1)
                  .maxLines(1)
                Image($r("app.media.ic_close"))
                  .width(20)
                  .height(20)
                  .fillColor($r("app.color.text_h2"))
                  .onClick((event) => {
                    this.deleteHistory(index);
                  })
              }
              .width('100%')
              .padding({ left: 16, top: 12, right: 16, bottom: 12 })
              .onClick((event) => {
                this.showKeyword = item;
                this.keyword = item;
                this.search();
              })
            }
          })
        }
        .listDirection(Axis.Vertical)
        .width('100%')
        .height('100%')
        .margin({ top: 16 })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}