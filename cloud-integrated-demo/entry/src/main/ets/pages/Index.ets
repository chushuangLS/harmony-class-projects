/**
 * 端云一体空项目 · 首页
 *
 * 云端调用使用 API 12+ 的 @kit.CloudFoundationKit（由 HMS SDK 提供）：
 *   cloudFunction.call({ name, version, data })
 *
 * 前置条件：
 *   1. module.json5 声明 ohos.permission.INTERNET
 *   2. AppScope/resources/rawfile/agconnect-services.json 的 package_name 与 bundleName 一致
 *   3. 该函数已部署，且与本应用在同一个 AGC 项目下
 */
import { cloudFunction } from '@kit.CloudFoundationKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State loading: boolean = false;
  @State outText: string = '尚未调用';
  @State success: boolean = false;

  async callFn(): Promise<void> {
    this.loading = true;
    this.success = false;
    this.outText = '调用中…';
    try {
      const params: cloudFunction.FunctionParams = {
        name: 'testhan2',
        version: '$latest',
        data: '{"request":"Hello World!"}'
      };
      const res: cloudFunction.FunctionResult = await cloudFunction.call(params);
      const r: string | Object = res.result;
      this.outText = typeof r === 'string' ? r : JSON.stringify(r, null, 2);
      this.success = true;
    } catch (e) {
      const err = e as BusinessError;
      this.outText = '调用失败\ncode: ' + err.code + '\nmessage: ' + err.message;
      this.success = false;
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column({ space: 14 }) {
      Text('端云一体空项目')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2D3D')

      Text('com.chushuangls.cfdemo · 课程项目')
        .fontSize(12)
        .fontColor('#7A8B9A')

      Button('调用云函数 testhan2')
        .width('86%')
        .height(46)
        .fontSize(16)
        .backgroundColor('#3A7AFE')
        .enabled(!this.loading)
        .onClick(() => {
          this.callFn();
        })

      if (this.loading) {
        LoadingProgress().width(32).height(32)
      }

      Scroll() {
        Text(this.outText)
          .fontSize(13)
          .fontColor(this.success ? '#155724' : '#5A6B7B')
          .width('100%')
          .padding(14)
          .backgroundColor(this.success ? '#EAF7EE' : '#FFFFFF')
          .borderRadius(10)
      }
      .layoutWeight(1)
      .width('86%')
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 60 })
    .backgroundColor('#F2F6FC')
  }
}
