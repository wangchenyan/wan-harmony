import router from '@ohos.router'
import Api from '../net/Api'
import UserService, { User } from '../service/UserService'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { TitleLayout } from '../widgets/TitleLayout'

class UserInfo {
  name: string
  level: string
  rank: string
  point: string
}

@Component
export struct Mine {
  @State loadState: LoadState = LoadState.SUCCESS;
  @State title: string = "";
  private unLoginInfo: UserInfo = {
    name: "未登录",
    level: "",
    rank: "",
    point: ""
  }
  @State userInfo: UserInfo = this.unLoginInfo;
  @State isLogin: boolean = false;
  private userObserver = (user?: User) => {
    if (user) {
      this.isLogin = true;
      this.userInfo = {
        name: user.nickname,
        level: user.level,
        rank: user.rank,
        point: user.coinCount.toString()
      }
    } else {
      this.isLogin = false;
      this.userInfo = this.unLoginInfo
    }
  }

  aboutToAppear() {
    UserService.get().addUserObserver(this.userObserver);
    let user = UserService.get().getUser();
    this.userObserver(user);
  }

  aboutToDisappear() {
    UserService.get().removeUserObserver(this.userObserver);
  }

  async logout() {
    await Api.get().logout();
    UserService.get().clearUser();
  }

  build() {
    PageLoading({
      loadState: $loadState,
    }) {
      Column() {
        TitleLayout({
          title: $title,
          isJustShowStatusBar: true
        })
        Column() {
          Image($r("app.media.harmony_os"))
            .width(100)
            .height(100)
          Text(this.userInfo.name)
            .fontColor($r("app.color.text_h1"))
            .fontSize(17)
            .margin({ top: 16 })
          Row({ space: 5 }) {
            Text("LV" + this.userInfo.level)
              .fontColor($r("app.color.white"))
              .fontSize(15)
              .backgroundColor($r("app.color.green"))
              .padding({ left: 4, top: 2, right: 4, bottom: 2 })
            Text("排名" + this.userInfo.rank)
              .fontColor($r("app.color.white"))
              .fontSize(15)
              .backgroundColor($r("app.color.blue"))
              .padding({ left: 4, top: 2, right: 4, bottom: 2 })
          }
          .margin({ top: 16 })
        }
        .margin({ top: 30 })
        .alignItems(HorizontalAlign.Center)
        .onClick((e) => {
          if (!UserService.get().isLogin()) {
            router.pushUrl({ url: 'pages/Login' })
          }
        })

        Row() {
          Text("我的积分")
            .layoutWeight(1)
            .fontSize(15)
            .fontColor($r("app.color.text_h1"))
          Text(this.userInfo.point)
            .fontSize(15)
            .fontColor($r("app.color.text_h1"))
        }
        .width('100%')
        .height(50)
        .margin({ top: 50 })
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16 })
        .backgroundColor($r("app.color.white"))
        .onClick((e) => {
          if (!UserService.get().isLogin()) {
            router.pushUrl({ url: 'pages/Login' })
          }
        })

        Row()
          .width('100%')
          .height(0.5)
          .backgroundColor($r("app.color.divider"))
        Row() {
          Text("我的收藏")
            .layoutWeight(1)
            .fontSize(15)
            .fontColor($r("app.color.text_h1"))
          Image($r("app.media.ic_arrow_right"))
            .fillColor($r("app.color.text_h1"))
            .width(20)
            .height(20)
        }
        .width('100%')
        .height(50)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 16, right: 16 })
        .backgroundColor($r("app.color.white"))
        .onClick((event) => {
          if (!UserService.get().isLogin()) {
            router.pushUrl({ url: 'pages/Login' })
          } else {

          }
        })

        if (this.isLogin) {
          Column() {
            Button("退出登录", {
              type: ButtonType.Capsule
            })
              .width('100%')
              .fontSize(15)
              .fontColor($r("app.color.white"))
              .backgroundColor($r("app.color.red"))
              .onClick((e) => {
                this.logout();
              })
          }
          .width('100%')
          .margin({ top: 50 })
          .padding({ left: 16, right: 16 })
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}