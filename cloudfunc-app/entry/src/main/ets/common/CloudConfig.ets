// 云函数调用配置：只需要改这里的常量即可
export class CloudConfig {
  /**
   * 触发器的域名部分，例如 https://xxxx.cloudfunctions.xxx.com
   * 留空时页面会提示「尚未配置域名」，不会发请求。
   */
  static readonly BASE_URL: string = '';

  /** HTTP 触发器的路径（AGC 云函数 → testhan2 → 触发器 → 触发URL） */
  static readonly TRIGGER_PATH: string = '/functions/4b7o26s1/testhan2-$latest';

  /**
   * 认证类型 apigw-client 时需要 API 客户端凭据。
   * 留空则只发匿名请求（无认证触发器可直接用）。
   */
  static readonly CLIENT_ID: string = '';
  static readonly CLIENT_SECRET: string = '';

  /** OAuth 换 token 的地址 */
  static readonly TOKEN_URL: string = 'https://oauth-login.cloud.huawei.com/oauth2/v3/token';

  static requestUrl(): string {
    return CloudConfig.BASE_URL + CloudConfig.TRIGGER_PATH;
  }

  static needToken(): boolean {
    return CloudConfig.CLIENT_ID.length > 0 && CloudConfig.CLIENT_SECRET.length > 0;
  }
}
