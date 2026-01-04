import hilog from '@ohos.hilog';
import Api from '../net/Api';
import { LoadState, PageLoading } from '../widgets/PageLoading';
import { TitleLayout } from '../widgets/TitleLayout';
import { ArticleItemComponent } from '../widgets/ArticleItemComponent';
import CollectUtils from '../common/CollectUtils';
import { HRouter } from '../router/HRouter';
import { RouteMode, RouteParams } from '../router/RouteInfo';
import { Article } from '../net/model/Article';
import { Harmony, Links, Open_sources, Tools } from '../net/model/Harmony';
import { Response } from '../net/Response';
import { Routes } from '../Routes';

interface HarmonyCategory {
  name: string;
  key: 'links' | 'open_sources' | 'tools';
}

interface GeneratedTypeLiteralInterface_1 {
  categoryData: Links | Open_sources | Tools | null;
}

@Component
struct HarmonyTab {
  @Prop categoryData: Links | Open_sources | Tools | null;
  private static TAG = "HarmonyTab";
  private scroller: Scroller = new Scroller();
  @State articleList: Article[] = [];

  onParameterChanged(params: GeneratedTypeLiteralInterface_1): void {
    this.categoryData = params.categoryData;
    this.updateArticleList();
  }

  aboutToAppear() {
    this.updateArticleList();
  }

  private updateArticleList() {
    this.articleList = this.categoryData?.articleList || [];
    hilog.info(0, HarmonyTab.TAG, `加载分类文章数：${this.articleList.length}`);
  }

  private async handleCollectClick(article: Article) {
    const success: boolean = await CollectUtils.collect(article);
    if (success) {
      this.articleList = this.articleList.map(item => item);
    }
  }

  build() {
    List({ scroller: this.scroller }) {
      ForEach(this.articleList, (item: Article) => {
        ListItem() {
          ArticleItemComponent({
            article: item,
            clearTop: true,
            onCollectClick: (article): Promise<void> => this.handleCollectClick(article)
          })
        }
        .padding({ top: 8, bottom: 8 })
      })

      if (this.articleList.length === 0) {
        ListItem() {
          Column({ space: 8 }) {
            Text('暂无相关文章')
              .fontSize(14)
              .fontColor($r("app.color.navi_bar_bg")) // 确保资源存在
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
    .edgeEffect(EdgeEffect.None)
  }
}

@Component
export struct HarmonyPage {
  @State title: string = "鸿蒙开发专栏";
  @State loadState: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  clearTop: boolean = false;
  @State categories: HarmonyCategory[] = [
    { name: '链接', key: 'links' },
    { name: '开源项目', key: 'open_sources' },
    { name: '工具', key: 'tools' }
  ];
  @State harmonyData: Harmony | null = null;
  private static TAG = "HarmonyPage";

  aboutToAppear() {
    this.loadData();
  }

  private getTabData(categoryKey: 'links' | 'open_sources' | 'tools'): Links | Open_sources | Tools | null {
    if (!this.harmonyData) {
      return null;
    }
    switch (categoryKey) {
      case 'links':
        return this.harmonyData.links;
      case 'open_sources':
        return this.harmonyData.open_sources;
      case 'tools':
        return this.harmonyData.tools;
      default:
        return null;
    }
  }

  build() {
    Column() {
      TitleLayout({
        title: this.title,
        showBack: false,
        menuIcon: $r("app.media.ic_search"),
        onMenuClick: () => {
          HRouter.with().url(Routes.Web).params('url', "https://ohpm.openharmony.cn/#/cn/home")
            .mode(this.clearTop ? RouteMode.ClearTop : RouteMode.Standard)
            .start();
        }
      })

      PageLoading({
        loadState: this.loadState,
        showLoading: this.showLoading,
        onReload: () => {
          hilog.debug(0, HarmonyPage.TAG, "重新加载数据");
          this.loadData();
        }
      }) {
        if (this.categories.length > 0) {
          Tabs({ barPosition: BarPosition.Start }) {
            ForEach(this.categories, (category: HarmonyCategory) => {
              TabContent() {
                // 传递数据给子组件的@Prop属性（无private初始化问题）
                HarmonyTab({
                  categoryData: this.getTabData(category.key)
                })
              }
              .tabBar(category.name)
            })
          }
          .width('100%')
          .height('100%')
          .scrollable(true)
          .barMode(BarMode.Scrollable)
          .barHeight(44)
        }
      }
    }
    .width('100%')
    .height('100%')
  }

  private loadData() {
    this.loadState = LoadState.LOADING;
    Api.get().getHarmony()
      .then((res: Response<Harmony>) => {
        if (res.errorCode === 0 && res.data) {
          this.harmonyData = res.data;
          this.loadState = LoadState.SUCCESS;
          hilog.info(0, HarmonyPage.TAG, "数据加载成功");
        } else {
          this.loadState = LoadState.FAIL;
          hilog.error(0, HarmonyPage.TAG, `加载失败：${res.errorMsg}`);
        }
      })
      .catch((error: Error) => {
        this.loadState = LoadState.FAIL;
        hilog.error(0, HarmonyPage.TAG, `加载异常：${error.message}`);
      });
  }
}

@Builder
export function HarmonyNavDesBuilder(params: RouteParams) {
  NavDestination() {
    HarmonyPage()
  }
  .hideTitleBar(true)
}

export { Harmony };
