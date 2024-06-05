import Api from '../net/Api';
import { Article } from '../net/model/Article';
import UserService from '../service/UserService';
import { toast } from './Toast';

export default class CollectUtils {
  static async collect(article: Article, id?: number): Promise<boolean> {
    if (!UserService.get().isLogin()) {
      UserService.get().checkLogin();
      return Promise.resolve(false);
    }

    if (!id) {
      id = article.id;
    }
    if (article.collect) {
      const res = await Api.get().unCollect(id);
      if (res.isSuccess()) {
        article.collect = false;
      } else {
        toast(res.errorMsg);
      }
      return Promise.resolve(res.isSuccess());
    } else {
      const res = await Api.get().collect(id);
      if (res.isSuccess()) {
        article.collect = true;
      } else {
        toast(res.errorMsg);
      }
      return Promise.resolve(res.isSuccess());
    }
  }
}