
export class RankingList {
  coinCount: number = 0
  level: number = 0
  nickname: string = ""
  rank: string = ""
  userId: number = 0
  username: string = ""
}

export class  Rank {
  curPage: number = 0
  datas: RankingList[] = []
  offset: number = 0
  over: boolean = false
  pageCount: number = 0
  size: number = 0
  total: number = 0
}