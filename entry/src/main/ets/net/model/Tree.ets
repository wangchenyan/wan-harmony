import { Article } from './Article'

export class Tree {
  articleList: Array<Article> = []
  author: string = ""
  children: Array<Tree> = []
  courseId: number = 0
  cover: string = ""
  desc: string = ""
  id: number = 0
  lisense: string = ""
  lisenseLink: string = ""
  name: string = ""
  order: number = 0
  parentChapterId: number = 0
  type: number = 0
  userControlSetTop: boolean = false
  visible: number = 0
}