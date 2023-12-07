export enum LoadState {
  LOADING,
  SUCCESS,
  FAIL,
  EMPTY
}

@Component
export struct PageLoading {
  @Link loadState: LoadState
  onReload?: () => void
  @BuilderParam content: () => void

  build() {
    Stack() {
      if (this.loadState === LoadState.LOADING) {
        Progress({ value: 0, total: 0, type: ProgressType.Eclipse })
          .width(48)
          .height(48)
          .align(Alignment.Center)
      } else if (this.loadState === LoadState.SUCCESS) {
        this.content()
      } else if (this.loadState === LoadState.FAIL) {
        Stack() {
          Text("加载失败，点击重试")
            .align(Alignment.Center)
        }
        .width('100%')
        .height('100%')
        .onClick((event) => {
          if (this.onReload !== undefined) {
            this.onReload()
          }
        })
      } else {
        Stack() {
          Text("这里什么都没有")
            .align(Alignment.Center)
        }
        .width('100%')
        .height('100%')
        .onClick((event) => {
          if (this.onReload !== undefined) {
            this.onReload()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
