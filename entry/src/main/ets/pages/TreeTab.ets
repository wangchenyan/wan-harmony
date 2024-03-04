import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh';
import hilog from '@ohos.hilog';
import { Pair } from '../common/Structs';
import Api from '../net/Api';
import { Article } from '../net/model/Article';
import { Tree } from '../net/model/Tree';
import { LoadState, PageLoading } from '../widgets/PageLoading';
import { TitleLayout } from '../widgets/TitleLayout';
import { ArticleItemBuilder } from '../widgets/ArticleItemBuilder';
import CollectUtils from '../common/CollectUtils';
import Preferences from '../common/Preferences';

@Component
export struct TreeTab {
  @State loadStateTree: LoadState = LoadState.LOADING;
  @State loadStateArticle: LoadState = LoadState.LOADING;
  @State showLoading: boolean = false;
  @State title: string = "体系";
  @State treeList: Array<Tree> = [];
  @State data: Array<Article> = [];
  @State selectTrees: Pair<Tree, Tree> = { first: undefined, second: undefined };
  @State selectTreeTemp: Tree = undefined;
  @State showSelectLayer: boolean = false;
  private tag = "Tree"
  private treeScroll1: Scroller = new Scroller();
  private treeScroll2: Scroller = new Scroller();
  private articleScroller: Scroller = new Scroller();
  private refreshConfig = new PullToRefreshConfigurator();
  private nextPage: number = 1;
  private hasMore: boolean = true;

  aboutToAppear() {
    this.refreshConfig.setHasRefresh(false);
    this.loadTreeData();
  }

  private async loadTreeData() {
    this.loadStateTree = LoadState.LOADING
    let res = await Api.get().getTree();
    if (res.isSuccessWithData()) {
      if (res.data.length > 0) {
        this.treeList = res.data;
        let selectedIds = await Preferences.get(getContext()).getSelectedTreeId();
        let selectedTree1 = this.treeList.find((item) => item.id === selectedIds.first);
        let selectedTree2 = selectedTree1?.children?.find((item) => item.id === selectedIds.second);
        if (selectedTree1 !== undefined && selectedTree2 !== undefined) {
          this.selectTreeTemp = selectedTree1;
          this.selectTrees = { first: selectedTree1, second: selectedTree2 };
        } else {
          this.selectTreeTemp = this.treeList[0];
          this.selectTrees = { first: this.treeList[0], second: this.treeList[0].children[0] };
        }
        this.loadStateTree = LoadState.SUCCESS;
        this.loadArticleData();
      } else {
        this.loadStateTree = LoadState.EMPTY;
      }
    } else {
      this.loadStateTree = LoadState.FAIL;
    }
  }

  private loadArticleData() {
    this.loadStateArticle = LoadState.LOADING;
    this.nextPage = 1;
    this.loadArticleDataByPage(0).then(
      (data) => {
        this.data = data;
        if (this.data.length === 0) {
          this.loadStateArticle = LoadState.EMPTY;
        } else {
          this.loadStateArticle = LoadState.SUCCESS;
        }
      },
      (error) => {
        this.loadStateArticle = LoadState.FAIL;
      })
  }

  private async loadArticleDataByPage(page: number): Promise<Array<Article>> {
    let res = await Api.get().getTreeArticleList(this.selectTrees.second.id, page);
    return new Promise<Array<Article>>((resolve, reject) => {
      if (res.isSuccessWithData()) {
        let list = res.data.datas;
        resolve(list);
      } else {
        reject();
      }
    })
  }

  build() {
    Column() {
      TitleLayout({
        title: $title,
        isJustShowStatusBar: true
      })
      PageLoading({
        loadState: $loadStateTree,
        showLoading: $showLoading,
        onReload: () => {
          hilog.debug(0, this.tag, "onReloadTree");
          this.loadTreeData();
        }
      }) {
        Column() {
          if (this.selectTrees.first && this.selectTrees.second) {
            Row() {
              Text(`${this.selectTrees.first.name} > ${this.selectTrees.second.name}`)
                .fontColor($r("app.color.text_h1"))
                .fontSize(17)
                .layoutWeight(1)
              Text(`更换 ${this.showSelectLayer ? "🔼" : "🔽"}`)
                .margin({ left: 12 })
                .fontColor($r("app.color.main"))
                .fontSize(16)
            }
            .width('100%')
            .height(48)
            .padding({ left: 16, right: 16 })
            .alignItems(VerticalAlign.Center)
            .onClick((event) => {
              if (this.showSelectLayer) {
                this.showSelectLayer = false;
                this.selectTreeTemp = this.selectTrees.first;
              } else {
                this.showSelectLayer = true;
                setTimeout(() => {
                  // 滚动到选中位置的前一个
                  let selectedIndex1 = this.treeList.findIndex(item => item.id === this.selectTrees.first.id);
                  if (selectedIndex1 >= 0) {
                    this.treeScroll1.scrollToIndex(Math.max(selectedIndex1 - 1, 0));
                  }
                  let selectedIndex2 = this.selectTrees.first.children.findIndex(item => item.id === this.selectTrees.second.id);
                  if (selectedIndex2 >= 0) {
                    this.treeScroll2.scrollToIndex(Math.max(selectedIndex2 - 1, 0));
                  }
                }, 16)
              }
            })
          }
          Stack() {
            PageLoading({
              loadState: $loadStateArticle,
              showLoading: $showLoading,
              onReload: () => {
                hilog.debug(0, this.tag, "onReloadArticle");
                this.loadArticleData();
              }
            }) {
              Column() {
                PullToRefresh({
                  data: $data,
                  scroller: this.articleScroller,
                  refreshConfigurator: this.refreshConfig,
                  customList: this.ListViewBuilder,
                  onLoadMore: () => {
                    return new Promise<string>((resolve, reject) => {
                      if (this.hasMore) {
                        this.loadArticleDataByPage(this.nextPage).then(
                          (data) => {
                            if (data.length > 0) {
                              this.nextPage++
                              this.data = this.data.concat(data);
                              resolve('加载成功');
                            } else {
                              this.hasMore = false;
                              resolve('没有更多了');
                            }
                          },
                          (error) => {
                            resolve('加载失败');
                          }
                        )
                      } else {
                        resolve('没有更多了');
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

            if (this.showSelectLayer) {
              Column() {
                Row() {
                  List({ scroller: this.treeScroll1 }) {
                    ForEach(this.treeList, (tree: Tree, index: number) => {
                      ListItem() {
                        Text(tree.name)
                          .width('100%')
                          .padding({ left: 12, top: 8, right: 12, bottom: 8 })
                          .fontColor((this.selectTreeTemp.id === tree.id) ? $r("app.color.main") : $r("app.color.text_h1"))
                          .fontSize(14)
                          .textAlign(TextAlign.Center)
                          .backgroundColor((index % 2 === 0) ? Color.Transparent : $r("app.color.hot_key_bg"))
                          .onClick((event) => {
                            this.selectTreeTemp = tree;
                          })
                      }
                    })
                  }
                  .width('50%')
                  .height('100%')
                  .onClick((event) => {
                  })

                  Line()
                    .width(0.5)
                    .height('100%')
                    .backgroundColor($r("app.color.divider"))

                  List({ scroller: this.treeScroll2 }) {
                    ForEach(this.selectTreeTemp.children, (tree: Tree, index: number) => {
                      ListItem() {
                        Text(tree.name)
                          .width('100%')
                          .padding({ left: 12, top: 8, right: 12, bottom: 8 })
                          .fontColor((this.selectTrees.second.id === tree.id) ? $r("app.color.main") : $r("app.color.text_h1"))
                          .fontSize(14)
                          .textAlign(TextAlign.Center)
                          .backgroundColor((index % 2 === 1) ? Color.Transparent : $r("app.color.hot_key_bg"))
                          .onClick((event) => {
                            this.selectTrees = { first: this.selectTreeTemp, second: tree };
                            Preferences.get(getContext())
                              .putSelectedTreeId(this.selectTrees.first.id, this.selectTrees.second.id)
                            this.showSelectLayer = false;
                            this.loadArticleData();
                          })
                      }
                    })
                  }
                  .width('50%')
                  .height('100%')
                  .onClick((event) => {
                  })
                }
                .width('100%')
                .height('70%')
                .backgroundColor($r("app.color.start_window_background"))
              }
              .width('100%')
              .height('100%')
              .backgroundColor($r("app.color.translucent_black_50"))
              .onClick((event) => {
                this.showSelectLayer = false;
                this.selectTreeTemp = this.selectTrees.first;
              })
            }
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ListViewBuilder() {
    List({ scroller: this.articleScroller }) {
      ForEach(this.data, (item: Article) => {
        ListItem() {
          ArticleItemBuilder({
            article: item,
            onCollectClick: (article: Article) => {
              CollectUtils.collect(article)
                .then((success) => {
                  if (success) {
                    this.data = this.data.map(item => item);
                  }
                })
            }
          })
        }
      })
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
    .edgeEffect(EdgeEffect.None) // 必须设置列表为滑动到边缘无效果
  }
}