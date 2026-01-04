import hilog from '@ohos.hilog';
import Api from '../net/Api';
import { LoadState, PageLoading } from '../widgets/PageLoading';
import { PullToRefresh } from '@ohos/pulltorefresh';
import { TitleLayout } from '../widgets/TitleLayout';
import { HRouter } from '../router/HRouter';
import { RouteParams } from '../router/RouteInfo';
import { RankingList, Rank } from '../net/model/RankingList';
import { Response } from '../net/Response';

@Component
export struct RankingListPage {
  @State title: string = "积分排行榜";
  @State loadState: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  @State rankingList: RankingList[] = [];
  private static TAG = "RankingListPage";
  private scroller: Scroller = new Scroller();
  private currentPage: number = 1;
  private hasMore: boolean = true;

  async aboutToAppear() {
    hilog.info(0, RankingListPage.TAG, "aboutToAppear：开始加载排行榜数据");
    this.loadData();
  }

  build() {
    PageLoading({
      loadState: this.loadState,
      showLoading: this.showLoading,
      onReload: () => {
        hilog.debug(0, RankingListPage.TAG, "onReload：重新加载排行榜");
        this.loadData();
      }
    }) {
      Column() {
        TitleLayout({
          title: this.title,
          showBack: true,
          onBack: () => {
            HRouter.with().back();
          },
          menuIcon: undefined,
          onMenuClick: undefined
        });

        PullToRefresh({
          data: $rankingList,
          scroller: this.scroller,
          customList: () => {
            this.listViewBuilder();
          },
          onRefresh: () => {
            return new Promise<string>((resolve) => {
              this.loadDataByPage(1).then(
                (rankData) => {
                  this.currentPage = 1;
                  this.rankingList = rankData.datas;
                  this.hasMore = !rankData.over;
                  resolve('刷新成功');
                },
                () => {
                  resolve('刷新失败');
                }
              );
            });
          },
          onLoadMore: () => {
            return new Promise<string>((resolve) => {
              if (this.hasMore) {
                this.loadDataByPage(this.currentPage + 1).then(
                  (rankData) => {
                    if (rankData.datas.length > 0) {
                      this.currentPage++;
                      this.rankingList = this.rankingList.concat(rankData.datas);
                      this.hasMore = !rankData.over;
                      resolve('加载成功');
                    } else {
                      this.hasMore = false;
                      resolve('没有更多数据了');
                    }
                  },
                  () => {
                    resolve('加载失败');
                  }
                );
              } else {
                resolve('没有更多数据了');
              }
            });
          },
          customLoad: null,
          customRefresh: null,
        })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  private listViewBuilder() {
    List({ scroller: this.scroller }) {
      ForEach(this.rankingList, (item: RankingList, index: number) => {
        ListItem() {
          this.rankItemBuilder(item, index + 1);
        }
        .padding({ top: 12, bottom: 12 })
      });

      if (this.rankingList.length === 0 && this.loadState === LoadState.SUCCESS) {
        ListItem() {
          Column({ space: 8 }) {
            Text('暂无排行榜数据')
              .fontSize(14)
              .fontColor($r("app.color.gray600"))
          }
          .width('100%')
          .height(100)
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .width('100%')
    .height('100%')
    .listDirection(Axis.Vertical)
    .divider({
      strokeWidth: 0.5,
      color: $r("app.color.divider"),
      startMargin: 16,
      endMargin: 16
    })
    .edgeEffect(EdgeEffect.None);
  }

  @Builder
  private rankItemBuilder(item: RankingList, actualRank: number) {
    Row({ space: 16 }) {
      Text(actualRank.toString())
        .width(24)
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getRankColor(actualRank));

      Column({ space: 4 }) {
        Text(item.username)
          .fontSize(15)
          .fontColor($r("app.color.text_h1"))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .flexGrow(1);

        Text(`等级：${item.level}`)
          .fontSize(12)
          .fontColor($r("app.color.gray600"));
      }
      .flexGrow(1);

      Text(`积分：${item.coinCount}`)
        .fontSize(15)
        .fontColor($r("app.color.main"))
        .fontWeight(FontWeight.Medium);
    }
    .width('100%')
    .padding({ left: 16, right: 16 });
  }

  private getRankColor(rank: number): Resource {
    switch (rank) {
      case 1:
        return $r("app.color.rank_gold");
      case 2:
        return $r("app.color.rank_silver");
      case 3:
        return $r("app.color.rank_bronze");
      default:
        return $r("app.color.gray600");
    }
  }

  private async loadData() {
    this.loadState = LoadState.LOADING;
    try {
      const rankData = await this.loadDataByPage(1);
      this.rankingList = rankData.datas;
      this.currentPage = 1;
      this.hasMore = !rankData.over;
      this.loadState = this.rankingList.length === 0 ? LoadState.EMPTY : LoadState.SUCCESS;
    } catch (error) {
      this.loadState = LoadState.FAIL;
      // 确保catch中打印的是Error实例的message（避免类型问题）
      const errorMsg = error instanceof Error ? error.message : '未知加载错误';
      hilog.error(0, RankingListPage.TAG, `初始加载失败：${errorMsg}`);
    }
  }

  private async loadDataByPage(page: number): Promise<Rank> {
    try {
      hilog.info(0, RankingListPage.TAG, `加载第${page}页排行榜数据`);
      const response: Response<Rank> = await Api.get().getRankingList(page);

      if (response.errorCode === 0 && response.data) {
        return response.data;
      } else {
        // 2. 修复throw错误：将内容封装成Error实例（原错误位置）
        const errorMsg = `接口返回异常：${response.errorMsg || '未知错误'}`;
        throw new Error(errorMsg); // 仅抛出Error类型，符合ArkTS规范
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : '网络请求失败';
      hilog.error(0, RankingListPage.TAG, `第${page}页加载失败：${errorMsg}`);
      // 再次抛出时也确保是Error实例（若上层需要处理）
      throw error instanceof Error ? error : new Error(errorMsg);
    }
  }
}

@Builder
export function RankingListNavDesBuilder(params: RouteParams) {
  NavDestination() {
    RankingListPage()
  }
  .hideTitleBar(true);
}