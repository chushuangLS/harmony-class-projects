/**
 * 云函数直连配置（备选方案）
 *
 * 背景：@kit.CloudFoundationKit 的 cloudFunction.call 已经打通到服务端，
 * 但被网关的签名校验挡住（401:205525007 verify signature failed）。
 * 这里改用已验证可行的方式：AGC API 客户端凭据换 token，再直连函数网关。
 *
 * 已验证：POST 返回 200 + {"code":0,...}
 */
export class CloudGateway {
  /** AGC 网关（中国区） */
  static readonly BASE_URL: string = 'https://connect-drcn.dbankcloud.cn';

  /** 函数调用路径：/agc/apigw/wisefunction/functions/<appId>/<函数名>-$latest */
  static readonly TRIGGER_PATH: string = '/agc/apigw/wisefunction/functions/4b7o26s1/testhan2-$latest';

  /** 取 token */
  static readonly TOKEN_PATH: string = '/agc/apigw/oauth2/v1/token';

  /** 应用级凭据（AGC → 项目管理 → 客户端ID / Client Secret） */
  static readonly CLIENT_ID: string = '2071067647725857792';
  static readonly CLIENT_SECRET: string = 'D6B082E333E9AAA9BAE385E9A2C742D0E9B9DDF086B0860F7B684633A81B4875';

  /** agconnect-services.json 中的标识 */
  static readonly APP_ID: string = '6917620261826369552';
  static readonly PRODUCT_ID: string = '101653523865475304';

  /** 网关身份头里的包名 */
  static readonly PACKAGE_NAME: string = 'com.example.cfapp';

  static tokenUrl(): string {
    return CloudGateway.BASE_URL + CloudGateway.TOKEN_PATH;
  }

  static requestUrl(): string {
    return CloudGateway.BASE_URL + CloudGateway.TRIGGER_PATH;
  }
}
