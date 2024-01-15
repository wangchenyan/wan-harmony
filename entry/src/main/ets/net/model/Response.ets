export class Response<T> {
  errorCode: number = 0
  errorMsg: string = ""
  data: T = null

  isSuccess(): boolean {
    return this.errorCode === 0
  }

  isSuccessWithData(): boolean {
    return this.errorCode === 0 && !!this.data
  }
}
