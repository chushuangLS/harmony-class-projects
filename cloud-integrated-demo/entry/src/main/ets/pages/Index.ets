/**
 * 端云一体空项目 · 首页
 *
 * 工程结构：
 *   CloudProgram/cloudfunctions/  ← 云函数（云端代码）
 *   CloudProgram/clouddb/         ← 云数据库对象类型
 *   cloud_objects/                ← 由云端对象生成的调用接口（har 模块）
 *   AppScope/resources/rawfile/agconnect-services.json  ← AGC 项目配置
 *
 * 调用云函数的写法（API 12+，来自 @kit.CloudFoundationKit，本页暂未启用）：
 *
 *   import { cloudFunction } from '@kit.CloudFoundationKit';
 *
 *   const result = await cloudFunction.call({
 *     name: 'hello',          // cloudfunctions 下的函数名
 *     version: '$latest',
 *     data: { request: 'Hello World!' }
 *   });
 *
 * 前置条件：
 *   1. module.json5 已声明 ohos.permission.INTERNET
 *   2. AppScope/resources/rawfile/agconnect-services.json 的 package_name 与本工程 bundleName 一致
 *   3. AGC 上该函数已部署（否则返回服务端错误）
 */
@Entry
@Component
struct Index {
  @State message: string = '端云一体空项目';

  build() {
    Column({ space: 12 }) {
      Text(this.message)
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2D3D')

      Text('CloudProgram · cloud_objects · agconnect-services.json')
        .fontSize(13)
        .fontColor('#7A8B9A')
        .textAlign(TextAlign.Center)

      Text('bundleName: com.example.cfapp')
        .fontSize(12)
        .fontColor('#9AA7B4')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F2F6FC')
  }
}
