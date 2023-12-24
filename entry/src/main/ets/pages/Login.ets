import router from '@ohos.router'
import Api from '../net/Api'
import UserService from '../service/UserService'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { TitleLayout } from '../widgets/TitleLayout'

@Entry
@Component
struct Login {
  @State loadState: LoadState = LoadState.SUCCESS
  @State title: string = "登录"
  private account: string
  private password: string

  async login() {
    if (!this.account || !this.password) return;
    let res = await Api.get().login(this.account, this.password);
    if (res.isSuccessWithData()) {
      UserService.get().setUser(res.data);
      let user = await UserService.get().updateUser();
      if (user) {
        router.back();
      }
    }
  }

  build() {
    Stack() {
      PageLoading({
        loadState: $loadState,
      }) {
        Column() {
          TitleLayout({
            title: $title
          })
          Column() {
            TextInput({
              placeholder: "请输入用户名"
            })
              .fontSize(15)
              .fontColor($r("app.color.text_h1"))
              .type(InputType.Email)
              .onChange((value) => {
                this.account = value
              })
            TextInput({
              placeholder: "请输入密码"
            })
              .margin({ top: 16 })
              .fontSize(15)
              .fontColor($r("app.color.text_h1"))
              .type(InputType.Password)
              .onChange((value) => {
                this.password = value
              })
            Button("登录", {
              type: ButtonType.Capsule
            })
              .width('100%')
              .margin({ top: 50 })
              .fontSize(15)
              .fontColor($r("app.color.white"))
              .backgroundColor($r("app.color.main"))
              .onClick((e) => {
                this.login();
              })
          }
          .width('100%')
          .margin({ top: 120 })
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }
}