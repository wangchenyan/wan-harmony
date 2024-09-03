export class RouteInfo {
  targetUrl: string = ''
  currentParams: RouteParams = new Map()
  targetParams: RouteParams = new Map()
  animated: boolean = true
  moveToTop: boolean = false
  onPopListener?: (params: RouteParams) => void
}

export type RouteParams = Map<string, Object>
