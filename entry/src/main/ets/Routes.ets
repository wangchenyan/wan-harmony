import { collectListNavDesBuilder } from './pages/CollectList'
import { loginNavDesBuilder } from './pages/Login'
import { searchEntryNavDesBuilder } from './pages/SearchEntry'
import { searchResultNavDesBuilder } from './pages/SearchResult'
import { webPageNavDesBuilder } from './pages/WebPage'
import { HRouter } from './router/HRouter'

export enum Routes {
  Login = '/login',
  Web = '/web',
  SearchEntry = '/search_entry',
  SearchResult = '/search_result',
  CollectList = '/collect_list'
}

export function registerRoutes() {
  HRouter.register(Routes.Login, wrapBuilder(loginNavDesBuilder))
  HRouter.register(Routes.Web, wrapBuilder(webPageNavDesBuilder))
  HRouter.register(Routes.SearchEntry, wrapBuilder(searchEntryNavDesBuilder))
  HRouter.register(Routes.SearchResult, wrapBuilder(searchResultNavDesBuilder))
  HRouter.register(Routes.CollectList, wrapBuilder(collectListNavDesBuilder))
}