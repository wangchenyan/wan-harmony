@Component
export struct Mine {
  build() {
    Row() {
      Column() {
        Text("Mine")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}