import promptAction from '@ohos.promptAction';
import EntryContext from '../common/EntryContext';
import Api from '../net/Api';
import Preferences from '../common/Preferences';
import { navRouter } from '../router/NavRouter';
import { Routes } from '../Routes';

export default class UserService {
  private static instance: UserService
  private static TAG = "UserService"
  private user?: User
  private userObservers: ((user?: User) => void)[] = []

  static get(): UserService {
    if (UserService.instance === undefined) {
      UserService.instance = new UserService()
    }
    return UserService.instance
  }

  private constructor() {
    const context = EntryContext.getContext() as Context;
    const user = Preferences.get(context).getUser()
    if (user) {
      this.user = user;
      this.notifyObserver();
      this.updateUser().catch();
    }
  }

  isLogin(): boolean {
    if (this.user) {
      return true;
    }
    return false;
  }

  checkLogin(onLogin?: () => void) {
    if (this.isLogin()) {
      if (onLogin) {
        onLogin()
      }
    } else {
      promptAction.showDialog({
        title: "提示",
        message: "当前操作需要登录",
        buttons: [
          {
            text: "立即登录",
            color: $r("app.color.main")
          },
          {
            text: "取消",
            color: $r("app.color.text_h2")
          }
        ]
      }).then((resp) => {
        if (resp.index === 0) {
          navRouter.open()
            .targetUrl(Routes.Login)
            .onPopListener((params) => {
              if (params.get('success') && onLogin) {
                onLogin()
              }
            })
            .start()
        }
      })
    }
  }

  getUser(): User | undefined {
    return this.user;
  }

  setUser(user?: User) {
    this.user = user;
    this.notifyObserver();
    const context = EntryContext.getContext() as Context;
    Preferences.get(context).putUser(user);
  }

  async updateUser(): Promise<User> {
    if (this.isLogin()) {
      const res = await Api.get().getUserInfo()
      if (res.isSuccessWithData()) {
        const user = this.user!!;
        user.coinCount = res.getDataOrThrow().coinCount;
        user.level = res.getDataOrThrow().level;
        user.rank = res.getDataOrThrow().rank;
        this.setUser(user);
        return Promise.resolve(user);
      } else {
        return Promise.reject(res.errorMsg);
      }
    } else {
      return Promise.reject()
    }
  }

  addUserObserver(observer: (user?: User) => void) {
    if (!this.userObservers.includes(observer)) {
      this.userObservers.push(observer);
    }
  }

  removeUserObserver(observer: (user?: User) => void) {
    const index = this.userObservers.indexOf(observer);
    if (index >= 0) {
      this.userObservers.splice(index, 1);
    }
  }

  private notifyObserver() {
    this.userObservers.forEach((observer) => {
      if (observer) {
        observer(this.user);
      }
    });
  }

  clearUser() {
    this.setUser(undefined);
    Api.get().clearCookie();
  }
}

export class User {
  id: number = 0
  username: string = ""
  nickname: string = ""
  chapterTops: object[] = []
  coinCount: number = 0
  collectIds: number[] = []
  email: string = ""
  icon: string = ""
  level: string = ""
  rank: string = ""
}
