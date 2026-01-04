import { collectListNavDesBuilder } from './pages/CollectList'
import { HarmonyNavDesBuilder } from './pages/Harmony'
import { loginNavDesBuilder } from './pages/Login'
import { RankingListNavDesBuilder } from './pages/RankingList'
import { searchEntryNavDesBuilder } from './pages/SearchEntry'
import { searchResultNavDesBuilder } from './pages/SearchResult'
import { webPageNavDesBuilder } from './pages/WebPage'
import { HRouter } from './router/HRouter'


export enum Routes {
  Login = '/login',
  Web = '/web',
  SearchEntry = '/search_entry',
  SearchResult = '/search_result',
  CollectList = '/collect_list',
  Harmony = '/Harmony',
  RankingList = '/RankingList'
}

export function registerRoutes() {
  HRouter.register(Routes.Login, wrapBuilder(loginNavDesBuilder))
  HRouter.register(Routes.Web, wrapBuilder(webPageNavDesBuilder))
  HRouter.register(Routes.SearchEntry, wrapBuilder(searchEntryNavDesBuilder))
  HRouter.register(Routes.SearchResult, wrapBuilder(searchResultNavDesBuilder))
  HRouter.register(Routes.CollectList, wrapBuilder(collectListNavDesBuilder))
  HRouter.register(Routes.Harmony, wrapBuilder(HarmonyNavDesBuilder))
  HRouter.register(Routes.RankingList, wrapBuilder(RankingListNavDesBuilder))
}