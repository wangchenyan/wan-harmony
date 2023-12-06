@Component
export struct Wechat {
  build() {
    Row() {
      Column() {
        Text("Wechat")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}