import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CloudConfig } from '../common/CloudConfig';

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
  @State hasResult: boolean = false;
  @State statusCode: number = 0;
  @State costMs: number = 0;
  @State respBody: string = '';
  @State errMsg: string = '';
  @State logText: string = '尚未发起请求';
  @State tokenBrief: string = '';
  @State tokenCached: string = '';
  @State tokenExpireAt: number = 0;

  private async fetchToken(): Promise<string> {
    if (this.tokenCached.length > 0 && Date.now() < this.tokenExpireAt) {
      return this.tokenCached;
    }
    const request = http.createHttp();
    try {
      const reqBody: TokenReq = {
        grant_type: 'client_credentials',
        client_id: CloudConfig.CLIENT_ID,
        client_secret: CloudConfig.CLIENT_SECRET,
        useJwt: 1
      };
      const payload: string = JSON.stringify(reqBody);
      const resp = await request.request(CloudConfig.tokenUrl(), {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json;charset=UTF-8' },
        extraData: payload,
        connectTimeout: 15000,
        readTimeout: 15000
      });
      const body: string = resp.result as string;
      if (resp.responseCode !== 200) {
        throw new Error('取 token 失败 HTTP ' + resp.responseCode + ' : ' + body);
      }
      const parsed: TokenResp = JSON.parse(body) as TokenResp;
      const ttl: number = parsed.expires_in > 60 ? parsed.expires_in - 60 : parsed.expires_in;
      this.tokenCached = parsed.access_token;
      this.tokenExpireAt = Date.now() + ttl * 1000;
      this.tokenBrief = 'token 已获取，有效期 ' + parsed.expires_in + ' 秒';
      return parsed.access_token;
    } finally {
      request.destroy();
    }
  }

  async callCloudFunction(): Promise<void> {
    this.loading = true;
    this.errMsg = '';
    this.hasResult = false;
    this.logText = '请求中…';
    const started: number = Date.now();
    const request = http.createHttp();
    try {
      const token: string = await this.fetchToken();
      const headers: Record<string, string> = {
        'Content-Type': 'application/json;charset=UTF-8',
        'Authorization': 'Bearer ' + token,
        'client_id': CloudConfig.CLIENT_ID,
        'appId': CloudConfig.APP_ID,
        'productId': CloudConfig.PRODUCT_ID,
        'sdkServiceName': CloudConfig.SDK_SERVICE_NAME,
        'sdkVersion': CloudConfig.SDK_VERSION,
        'sdkPlatform': 'OpenHarmony',
        'sdkType': 'TS',
        'packageName': CloudConfig.PACKAGE_NAME,
        'appVersion': '1.0.0'
      };
      const resp = await request.request(CloudConfig.requestUrl(), {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify({ request: 'Hello World!' }),
        connectTimeout: 20000,
        readTimeout: 20000
      });
      this.costMs = Date.now() - started;
      this.statusCode = resp.responseCode;
      this.respBody = this.pretty(resp.result as string);
      this.hasResult = true;
      this.logText = '请求完成';
    } catch (e) {
      this.costMs = Date.now() - started;
      const err = e as BusinessError;
      this.errMsg = '请求失败：' + (err.message !== undefined ? err.message : JSON.stringify(e));
      this.hasResult = false;
      this.logText = '请求失败';
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

  @Builder
  metaItem(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(12)
        .fontColor('#7A8B9A')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
  }

  build() {
    Column() {
      Row() {
        Text('云函数请求')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2D3D')
        Blank()
        Text('POST · apigw-client')
          .fontSize(12)
          .fontColor('#7A8B9A')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 6 })

      Text('testhan2-$latest')
        .fontSize(12)
        .fontColor('#5A6B7B')
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 2 })

      if (this.tokenBrief.length > 0) {
        Text(this.tokenBrief)
          .fontSize(12)
          .fontColor('#2E9E5B')
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 4 })
      }

      Button('请求云函数')
        .width('100%')
        .height(48)
        .fontSize(17)
        .margin({ left: 20, right: 20, top: 10 })
        .backgroundColor('#3A7AFE')
        .enabled(!this.loading)
        .onClick(() => {
          this.callCloudFunction();
        })

      if (this.loading) {
        Row() {
          LoadingProgress().width(22).height(22)
          Text('请求中…').fontSize(13).fontColor('#5A6B7B').margin({ left: 8 })
        }
        .margin({ top: 14 })
      }

      if (this.errMsg.length > 0) {
        Text(this.errMsg)
          .fontSize(13)
          .fontColor('#E84026')
          .width('100%')
          .padding(14)
          .margin({ left: 20, right: 20, top: 14 })
          .borderRadius(12)
          .backgroundColor('#FFF1EF')
      }

      if (this.hasResult) {
        Row() {
          this.metaItem('状态码', this.statusCode.toString(), this.statusCode === 200 ? '#2E9E5B' : '#E84026')
          this.metaItem('耗时', this.costMs.toString() + ' ms', '#1F2D3D')
          this.metaItem('请求方式', 'POST', '#3A7AFE')
        }
        .width('100%')
        .padding(16)
        .margin({ left: 20, right: 20, top: 14 })
        .borderRadius(14)
        .backgroundColor('#FFFFFF')

        Text('云函数返回')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2D3D')
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 6 })

        Scroll() {
          Text(this.respBody)
            .fontSize(12)
            .fontColor('#22303C')
            .width('100%')
            .padding(14)
            .backgroundColor('#F7F9FC')
            .borderRadius(10)
        }
        .layoutWeight(1)
        .padding({ left: 20, right: 20, bottom: 24 })
        .scrollBar(BarState.Auto)
      } else {
        Blank()
        Text(this.logText)
          .fontSize(13)
          .fontColor('#9AA7B4')
          .margin({ bottom: 40 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F6FC')
  }
}
