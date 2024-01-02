import { MaterialProgressBar, MaterialProgressStyle } from '@ohos/materialprogressbar'

export enum LoadState {
  LOADING,
  SUCCESS,
  FAIL,
  EMPTY
}

@Component
export struct PageLoading {
  @Link loadState: LoadState;
  onReload?: () => void;
  @Link showLoading: boolean;
  @BuilderParam content: () => void;

  build() {
    Stack() {
      if (this.loadState === LoadState.LOADING) {
        MaterialProgressBar({ style: MaterialProgressStyle.MaterialCircular,
          modelBuild: {
            color: $r("app.color.main"),
            bgColor: $r("app.color.divider"),
            indeterminate: true,
            strokeWidth: 4
          } })
          .margin({ left: 16, top: 16 })
          .align(Alignment.Center)
      } else if (this.loadState === LoadState.SUCCESS) {
        this.content();
        if (this.showLoading) {
          Stack() {
            Stack() {
              MaterialProgressBar({ style: MaterialProgressStyle.MaterialCircular,
                modelBuild: {
                  color: $r("app.color.white"),
                  bgColor: Color.Transparent,
                  indeterminate: true,
                  strokeWidth: 4,
                } })
                .margin({ left: 16, top: 16 })
                .align(Alignment.Center)
            }
            .width(100)
            .height(100)
            .align(Alignment.Center)
            .backgroundColor($r("app.color.translucent_black_50"))
            .borderRadius(8)
          }
          .width('100%')
          .height('100%')
          .onClick((e) => {
          })
        }
      } else if (this.loadState === LoadState.FAIL) {
        Stack() {
          Text("加载失败，点击重试")
            .align(Alignment.Center)
        }
        .width('100%')
        .height('100%')
        .onClick((event) => {
          if (this.onReload !== undefined) {
            this.onReload();
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
            this.onReload();
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
