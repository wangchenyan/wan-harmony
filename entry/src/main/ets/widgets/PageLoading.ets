export enum LoadState {
  LOADING,
  SUCCESS,
  FAIL,
  EMPTY
}

@Component
export struct PageLoading {
  @Prop loadState: LoadState;
  onReload?: () => void;
  @Prop showLoading: boolean;
  @BuilderParam content: () => void;

  build() {
    Stack() {
      if (this.loadState === LoadState.LOADING) {
        LoadingProgress()
          .width(50)
          .height(50)
          .color($r("app.color.main"))
      } else if (this.loadState === LoadState.SUCCESS) {
        this.content();
        if (this.showLoading) {
          Stack() {
            Stack() {
              LoadingProgress()
                .width(50)
                .height(50)
                .color($r("app.color.white"))
            }
            .width(100)
            .height(100)
            .backgroundColor($r("app.color.translucent_black_50"))
            .borderRadius(8)
          }
          .width('100%')
          .height('100%')
        }
      } else if (this.loadState === LoadState.FAIL) {
        Stack() {
          Text("加载失败，点击重试")
        }
        .width('100%')
        .height('100%')
        .onClick(() => {
          if (this.onReload) {
            this.onReload();
          }
        })
      } else {
        Stack() {
          Text("这里什么都没有")
        }
        .width('100%')
        .height('100%')
        .onClick(() => {
          if (this.onReload) {
            this.onReload();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
