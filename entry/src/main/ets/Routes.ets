import { collectListNavDesBuilder } from './pages/CollectList'
import { loginNavDesBuilder } from './pages/Login'
import { searchEntryNavDesBuilder } from './pages/SearchEntry'
import { searchResultNavDesBuilder } from './pages/SearchResult'
import { webPageNavDesBuilder } from './pages/WebPage'
import { navRouter } from './router/NavRouter'

export enum Routes {
  Login = '/login',
  Web = '/web',
  SearchEntry = '/search_entry',
  SearchResult = '/search_result',
  CollectList = '/collect_list'
}

export function registerRoutes() {
  navRouter.register(Routes.Login, wrapBuilder(loginNavDesBuilder))
  navRouter.register(Routes.Web, wrapBuilder(webPageNavDesBuilder))
  navRouter.register(Routes.SearchEntry, wrapBuilder(searchEntryNavDesBuilder))
  navRouter.register(Routes.SearchResult, wrapBuilder(searchResultNavDesBuilder))
  navRouter.register(Routes.CollectList, wrapBuilder(collectListNavDesBuilder))
}