/**
 * 端云一体空项目 · 首页
 *
 * 调用链路（备选方案，已实测 200）：
 *   POST {BASE}/agc/apigw/oauth2/v1/token     取 access_token
 *   POST {BASE}{TRIGGER_PATH}                带 Bearer + 身份头调用云函数
 *
 * 官方 @kit.CloudFoundationKit 的 cloudFunction.call 也试过：
 * 请求能到达服务端，但被网关签名校验挡住（401:205525007 verify signature failed），
 * 需要 AGC 侧把签名证书指纹与「关联已注册应用」都配对才会通过。
 */
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CloudGateway } from '../common/CloudGateway';

interface TokenResp {
  access_token: string;
  expires_in: number;
}

interface TokenReq {
  grant_type: string;
  client_id: string;
  client_secret: string;
  useJwt: number;
}

@Entry
@Component
struct Index {
  @State loading: boolean = false;
  @State outText: string = '尚未调用';
  @State success: boolean = false;
  @State costMs: number = 0;
  @State statusCode: number = 0;

  async callFn(): Promise<void> {
    this.loading = true;
    this.success = false;
    this.outText = '调用中…';
    const started: number = Date.now();
    const request = http.createHttp();
    try {
      // 1) 取 token
      const tokenReq: TokenReq = {
        grant_type: 'client_credentials',
        client_id: CloudGateway.CLIENT_ID,
        client_secret: CloudGateway.CLIENT_SECRET,
        useJwt: 1
      };
      const tokenResp = await request.request(CloudGateway.tokenUrl(), {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json;charset=UTF-8' },
        extraData: JSON.stringify(tokenReq),
        connectTimeout: 15000,
        readTimeout: 15000
      });
      if (tokenResp.responseCode !== 200) {
        throw new Error('取 token 失败 HTTP ' + tokenResp.responseCode);
      }
      const token: TokenResp = JSON.parse(tokenResp.result as string) as TokenResp;

      // 2) 调云函数
      const headers: Record<string, string> = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer ' + token.access_token,
        'client_id': CloudGateway.CLIENT_ID,
        'appId': CloudGateway.APP_ID,
        'productId': CloudGateway.PRODUCT_ID,
        'sdkServiceName': 'agconnect-cloud',
        'sdkVersion': '1.0.2',
        'sdkPlatform': 'OpenHarmony',
        'sdkType': 'TS',
        'packageName': CloudGateway.PACKAGE_NAME,
        'appVersion': '1.0.0'
      };
      const resp = await request.request(CloudGateway.requestUrl(), {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: '{"request":"Hello World!"}',
        connectTimeout: 20000,
        readTimeout: 20000
      });
      this.costMs = Date.now() - started;
      this.statusCode = resp.responseCode;
      this.outText = this.pretty(resp.result as string);
      this.success = resp.responseCode === 200;
    } catch (e) {
      const err = e as BusinessError;
      this.outText = '调用失败\n' + (err.message !== undefined ? err.message : JSON.stringify(e));
      this.success = false;
    } finally {
      request.destroy();
      this.loading = false;
    }
  }

  pretty(raw: string): string {
    try {
      const obj: object = JSON.parse(raw) as object;
      return JSON.stringify(obj, null, 2);
    } catch (e) {
      return raw;
    }
  }

  build() {
    Column({ space: 12 }) {
      Text('端云一体空项目')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2D3D')

      Text('com.chushuangls.cfdemo · 课程1 项目')
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
        Row({ space: 6 }) {
          LoadingProgress().width(22).height(22)
          Text('请求中…').fontSize(13).fontColor('#5A6B7B')
        }
      }

      if (this.success) {
        Row({ space: 18 }) {
          Text('状态码 ' + this.statusCode).fontSize(13).fontColor('#2E9E5B').fontWeight(FontWeight.Bold)
          Text('耗时 ' + this.costMs + ' ms').fontSize(13).fontColor('#2E9E5B')
        }
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
    .padding({ top: 50 })
    .backgroundColor('#F2F6FC')
  }
}
