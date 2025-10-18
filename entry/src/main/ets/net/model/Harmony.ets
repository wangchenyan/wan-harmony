import { Article } from "./Article";

export  class  Links {
  articleList: Article[] = []
  author: string = ""
  children: [] = []
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

export class  Open_sources {
  articleList: Article[] = []
  author: string = ""
  children: [] = []
  courseId: number = 0
  cover: string= ""
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


export class  Tools {
  articleList: Article[] = []
  author: string = ""
  children: [] = []
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

export class Harmony {
  links: Links | null = new Links();
  open_sources: Open_sources | null = new Open_sources();
  tools: Tools | null = new Tools();
}
