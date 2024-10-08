import { toast } from '../common/Toast'
import Api from '../net/Api'
import { HRouter } from '../router/HRouter'
import { RouteParams } from '../router/RouteInfo'
import UserService from '../service/UserService'
import { LoadState, PageLoading } from '../widgets/PageLoading'
import { TitleLayout } from '../widgets/TitleLayout'

@Component
struct Login {
  @State loadState: LoadState = LoadState.SUCCESS;
  @State showLoading: boolean = false;
  @State title: string = "登录";
  private account: string = "";
  private password: string = "";

  build() {
    Stack() {
      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading
      }) {
        Column() {
          TitleLayout({
            title: this.title
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
                this.login().catch();
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

  async login() {
    if (!this.account) {
      toast("请输入用户名");
      return;
    }
    if (!this.password) {
      toast("请输入密码");
      return;
    }
    this.showLoading = true;
    const res = await Api.get().login(this.account, this.password);
    this.showLoading = false;
    if (res.isSuccessWithData()) {
      toast("登录成功");
      UserService.get().setUser(res.data);
      const user = await UserService.get().updateUser();
      if (user) {
        HRouter.with()
          .params('success', true)
          .back();
      }
    } else {
      toast(res.errorMsg);
    }
  }
}

@Builder
export function loginNavDesBuilder(params: RouteParams) {
  NavDestination() {
    Login()
  }
  .hideTitleBar(true)
}