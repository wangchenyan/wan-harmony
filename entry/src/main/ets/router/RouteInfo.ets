export class RouteInfo {
  targetUrl: string = ''
  currentParams: RouteParams = new Map()
  targetParams: RouteParams = new Map()
  mode: RouteMode = RouteMode.Standard
  animated: boolean = true
  onPop?: (params: RouteParams) => void
}

export type RouteParams = Map<string, Object>

export enum RouteMode {
  Standard = 'Standard',
  MoveToTop = 'MoveToTop',
  ClearTop = 'ClearTop',
}
