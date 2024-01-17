import dataPreferences from '@ohos.data.preferences';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import EntryContext from '../common/EntryContext';
import Api from '../net/Api';

export default class UserService {
  private static instance: UserService
  private tag = "UserService"
  private key = "user_info"
  private preferences?: dataPreferences.Preferences
  private user?: User
  private userObservers: Array<(user?: User) => void> = []

  static get(): UserService {
    if (UserService.instance === undefined) {
      UserService.instance = new UserService()
    }
    return UserService.instance
  }

  private constructor() {
    this.init();
  }

  private async init() {
    let context = EntryContext.getContext() as Context;
    this.preferences = await dataPreferences.getPreferences(context, 'top.wangchenyan.wanharmony.user');
    let json = await this.preferences.get(this.key, "");
    if (json) {
      let user = new User();
      Object.assign(user, JSON.parse(json as string));
      this.user = user;
      this.notifyObserver();
      this.updateUser();
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
      if (onLogin != undefined) {
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
          router.pushUrl({
            url: 'pages/Login'
          })
        }
      })
    }
  }

  getUser(): User {
    return this.user;
  }

  setUser(user?: User) {
    this.user = user;
    if (user) {
      this.preferences?.put(this.key, JSON.stringify(user));
    } else {
      this.preferences?.delete(this.key);
    }
    this.preferences?.flush();
    this.notifyObserver();
  }

  async updateUser(): Promise<User> {
    if (this.isLogin()) {
      let res = await Api.get().getUserInfo()
      return new Promise<User>((resolve, reject) => {
        if (res.isSuccessWithData()) {
          let user = this.user;
          this.user.coinCount = res.data.coinCount;
          this.user.level = res.data.level;
          this.user.rank = res.data.rank;
          this.setUser(user);
          resolve(this.user);
        } else {
          reject(res.errorMsg);
        }
      })
    }
  }

  addUserObserver(observer: (user?: User) => void) {
    if (!this.userObservers.includes(observer)) {
      this.userObservers.push(observer);
    }
  }

  removeUserObserver(observer: (user?: User) => void) {
    let index = this.userObservers.indexOf(observer);
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
  chapterTops: Array<Object> = []
  coinCount: number = 0
  collectIds: Array<number> = []
  email: string = ""
  icon: string = ""
  level: string = ""
  rank: string = ""
}
