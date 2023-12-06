@Component
export struct Square {
  build() {
    Row() {
      Column() {
        Text("Square")
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}