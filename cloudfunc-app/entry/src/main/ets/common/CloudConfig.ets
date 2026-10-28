/**
 * 云函数调用配置
 *
 * 说明：AGC 新版控制台只给出相对触发路径 `/functions/<appId>/<func>-$latest`，
 * 真实公网地址需要按官方 SDK 的规则拼装（本文件已按此还原并实测可用）：
 *
 *   域名        : agconnect-services.json 里的 agcgw.url（中国区 = connect-drcn.dbankcloud.cn）
 *   触发路径    : /agc/apigw/wisefunction/functions/<appId>/<函数名>-$latest
 *   取 token    : /agc/apigw/oauth2/v1/token  (client_credentials + useJwt)
 *   appId 算法  : base36(sha256("agc:<cp_id>@<product_id>")) 前 8 位 = 4b7o26s1
 *
 * 身份头（client_id / appId / productId / sdkServiceName ...）由网关校验，
 * 缺任何一个都会返回 401 {"ret":{"code":205524993,"msg":"client token auth failed"}}。
 */
export class CloudConfig {
  /** 网关域名 */
  static readonly BASE_URL: string = 'https://connect-drcn.dbankcloud.cn';

  /** 触发路径（对应控制台卡片上的 /functions/4b7o26s1/testhan2-$latest） */
  static readonly TRIGGER_PATH: string = '/agc/apigw/wisefunction/functions/4b7o26s1/testhan2-$latest';

  /** 取 token 的路径 */
  static readonly TOKEN_PATH: string = '/agc/apigw/oauth2/v1/token';

  /** 应用级凭据（AGC → 项目管理 → 客户端ID / Client Secret） */
  static readonly CLIENT_ID: string = '2071067647725857792';
  static readonly CLIENT_SECRET: string = 'D6B082E333E9AAA9BAE385E9A2C742D0E9B9DDF086B0860F7B684633A81B4875';

  /** agconnect-services.json 中的 app_id / product_id */
  static readonly APP_ID: string = '6917620261826369552';
  static readonly PRODUCT_ID: string = '101653523865475304';
  static readonly PACKAGE_NAME: string = 'com.example.cfapp';

  static readonly SDK_SERVICE_NAME: string = 'agconnect-cloud';
  static readonly SDK_VERSION: string = '1.0.2';

  static tokenUrl(): string {
    return CloudConfig.BASE_URL + CloudConfig.TOKEN_PATH;
  }

  static requestUrl(): string {
    return CloudConfig.BASE_URL + CloudConfig.TRIGGER_PATH;
  }

  static needToken(): boolean {
    return CloudConfig.CLIENT_ID.length > 0 && CloudConfig.CLIENT_SECRET.length > 0;
  }
}
