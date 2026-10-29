# HarmonyOS 课堂练习：云函数请求 + 天气查询

一个仓库，两个独立的 HarmonyOS 工程（ArkTS + Stage 模型，API 26 / HarmonyOS 7.0.0）。

| 工程 | 首页 | 说明 |
|---|---|---|
| `cloudfunc-app/` | `pages/Index` | 点按钮请求云函数（HTTP 触发器 / `apigw-client`），页面显示状态码、耗时与返回 JSON |
| `weather-app/` | `pages/Index` | 天气查询：城市下拉 + 查询按钮 + 实时天气 + 未来 5 天预报 |

两个工程的 `main_pages.json` 都只注册 `pages/Index`，`EntryAbility` 直接 `loadContent('pages/Index')`，因此**打开即是首页**。

两个 App 已在 `Mate 90 Pro` 模拟器上实测跑通，见 `docs/` 下的截图。

---

## 环境要求

- DevEco Studio 26.0.0.851（内置 Node、hvigor、ohpm）
- HarmonyOS SDK API 26（`D:\deveco studio\sdk`）
- 模拟器：`Mate 90 Pro`（HarmonyOS 7.0.0.107 / API 26 / x86_64 / 1280×2832）

⚠️ **工程路径必须是纯 ASCII**。hvigor 对路径有字符集限制，中文目录直接失败：

```
ERROR: 00306003 Specification Limit Violation
Invalid project path. Current path does not match: D:\华为虚拟机\weather-app
```

所以请放在 `D:\harmony-projects\` 这类纯英文路径下。

## 构建

```bat
set NODE_HOME=D:\deveco studio\tools\node
set DEVECO_SDK_HOME=D:\deveco studio\sdk
set PATH=%NODE_HOME%;%PATH%

cd /d D:\harmony-projects\weather-app
"D:\deveco studio\tools\hvigor\bin\hvigorw.bat" --mode module -p product=default -p buildMode=debug assembleHap --no-daemon
```

产物：`entry/build/default/outputs/default/entry-default-signed.hap`
（无签名配置时为 `entry-default-unsigned.hap`）

## 安装与运行

```bat
hdc -t 127.0.0.1:5555 install -r entry-default-signed.hap
hdc -t 127.0.0.1:5555 shell aa start -a EntryAbility -b <bundleName>
hdc -t 127.0.0.1:5555 shell snapshot_display -f /data/local/tmp/s.jpeg
hdc -t 127.0.0.1:5555 file recv /data/local/tmp/s.jpeg .\s.jpg
```

- `hdc` 位于 `D:\deveco studio\sdk\default\openharmony\toolchains\hdc.exe`
- **截图是 JPEG**，务必用 `.jpg` 后缀
- 设备一直 `Offline` 时执行 `hdc kill` 再重试

---

## 签名

仓库内**不保存任何签名材料**：`build-profile.json5` 的 `signingConfigs` 为空，`*.p12` / `*.cer` / `*.p7b` 已在 `.gitignore` 中排除。

自动签名的前提：

1. DevEco Studio 已登录华为开发者账号，且登录态有效
   （过期症状：`401 [AppGalleryConnectUserAuthService] getTokenInfo return null`，或签名面板报"查询协议签署记录失败"）
2. **模拟器/真机已连接** —— AGC 调试 Profile 绑定"包名 + 设备 UDID"，没有设备生成不了
3. `File → Project Structure → Signing Configs` 勾选「自动生成签名文件」

每个包名要各自生成一套 Profile，不能复用。生成后 DevEco 把材料写到 `~/.ohos/config/` 并回填 `build-profile.json5`。

本机为了继续调试，签名后的配置另存为 `build-profile.signed.bak`（已 gitignore），需要时覆盖回去：

```powershell
Copy-Item build-profile.signed.bak build-profile.json5 -Force
```

已提交的干净版本用 `git update-index --skip-worktree build-profile.json5` 防止误提交。

---

## cloudfunc-app（云函数请求）

### 页面行为

- 首页一个 `Button('请求云函数')`
- 点击后先取 token，再 `POST` 调用云函数，页面展示：**状态码 / 耗时(ms) / token 有效期 / 返回 JSON（格式化滚动展示）**
- 请求失败、取 token 失败都有红字提示，不会白屏

### 配置位置

`entry/src/main/ets/common/CloudConfig.ets`

### AGC 的真实调用协议（逆向官方 SDK 得到）

控制台「触发器」卡片只显示相对路径 `/functions/<appId>/<函数名>-$latest`，
**这不是公网可调用地址**。真实规则来自官方 SDK
（`@hw-agconnect/cloud` 的 `FunctionRequest.ts` 与 `@hw-agconnect/hmcore` 的 `ClientTokenRequest.ts`）：

| 项 | 规则 |
|---|---|
| 网关域名 | `https://` + `agconnect-services.json` 的 `agcgw.url`（中国区 = `connect-drcn.dbankcloud.cn`） |
| 触发地址 | `/agc/apigw/wisefunction/functions/<appId>/<函数名>-$latest` |
| 取 token | `POST /agc/apigw/oauth2/v1/token` |
| appId | `base36(sha256("agc:<cp_id>@<product_id>"))` 取**前 8 位** |

验算过：`sha256("agc:20086000973519127@101653523865475304")` → base36 → `4b7o26s1`，与控制台一致。

#### 取 token

```
POST https://connect-drcn.dbankcloud.cn/agc/apigw/oauth2/v1/token
Content-Type: application/json;charset=UTF-8

{"grant_type":"client_credentials","client_id":"<应用客户端ID>","client_secret":"<应用密钥>","useJwt":1}
```

用的是**应用级** Client ID/Secret（AGC → 项目管理 → 客户端ID），
**不是**「认证凭据」里下载的 API 客户端（那个只对 `connect-api` 管理接口有效）。

#### 调用函数

```
POST https://connect-drcn.dbankcloud.cn/agc/apigw/wisefunction/functions/4b7o26s1/testhan2-$latest
Authorization: Bearer <access_token>
client_id:      <应用客户端ID>
appId:          6917620261826369552
productId:      101653523865475304
sdkServiceName: agconnect-cloud
sdkVersion:     1.0.2
sdkPlatform:    OpenHarmony
sdkType:        TS
packageName:    com.example.cfapp
Content-Type:   application/json;charset=UTF-8

{"request":"Hello World!"}
```

**身份头缺一不可**，否则返回 `401 {"ret":{"code":205524993,"msg":"client token auth failed"}}`。

#### 实测结果

```json
{
  "code": 0,
  "msg": "hello from cloud function",
  "echo": { "request": "Hello World!" },
  "serverTime": "2026-10-28T10:04:35.644Z"
}
```

页面显示：`200` · `277 ms` · `token 已获取，有效期 14399 秒`。

---

## cloudfunction/（云函数端代码）

| 文件 | 说明 |
|---|---|
| `cloudfunction/index.js` | 函数入口，callback 风格 |
| `cloudfunction/function-config.json` | 触发器配置参考（HTTP / POST / apigw-client / 启用 decode） |

### 运行时必须是 callback 风格

AGC 的 Node.js 运行时是「四参数回调」，**`return` 不生效**，不调用 `callback()` 会一直等待直到超时（控制台一直转圈）：

```js
let myHandler = async function (event, context, callback, logger) {
  let body = {};
  try {
    body = event.body ? JSON.parse(event.body) : {};
  } catch (e) {
    body = { raw: event.body };
  }
  callback({ code: 0, msg: 'hello from cloud function', echo: body, serverTime: new Date().toISOString() });
};
export { myHandler };
```

- 控制台「函数入口」= **`文件名.导出名`**，例：文件 `handler.js` + 导出 `myHandler` → `handler.myHandler`
- 改完必须点 **「提交」** 部署，否则测的还是旧版本

### 错误码对照

| 报错 | 原因 |
|---|---|
| `Cannot find module '/dcache/layer/func/index.js'` | 代码没上传，或入口文件名不对 |
| `Can't find function name myHandler` | 文件里没有该导出（没保存/没提交） |
| 一直转圈 | 没调用 `callback()` |
| `{"code":0,...}` | 成功 |

---

## weather-app（天气查询）

- 接口：`http://t.weather.sojson.com/api/weather/city/{cityId}`（sojson 免费天气 API）
- 内置 10 个城市：北京 / 上海 / 天津 / 重庆 / 广州 / 深圳 / 杭州 / 成都 / 武汉 / 西安
- 接口限流 **3 秒一次**，代码里做了节流提示
- 展示：实时温度、天气、高低温、湿度、PM2.5、空气质量、感冒提示、未来 5 天（星期 / 日期 / 天气 / 高低温 / 风向风力）
- 权限：`ohos.permission.INTERNET`
- 明文 HTTP 在 HarmonyOS 7 模拟器上实测未被拦截

---

## 实测记录

| 项 | 结果 |
|---|---|
| 模拟器 | `Mate 90 Pro` → `hdc` 识别 `127.0.0.1:5555 Connected` |
| 签名 | 两个包名各自生成 Profile：`default_weatherapp_*.p7b`、`default_cfapp_*.p7b` |
| weather-app | 编译成功 → 安装成功 → 首页显示天津 10.4℃ / 晴 / 湿度 31% / PM2.5 16 / 优 / 未来 5 天 |
| cloudfunc-app | 编译成功 → 安装成功 → 点按钮返回 `200`、`277 ms`、`{"code":0,...}` |
| 云函数 | 控制台测试返回 `code: 0`，App 端公网调用同样返回 `code: 0` |

## ⚠️ 安全提醒

`CLIENT_ID` / `CLIENT_SECRET` 目前写死在 `CloudConfig.ets` 里（课堂作业为了方便直接可跑）。
本仓库是公开的，**课后建议到 AGC 重建一次 API 客户端让旧密钥失效**，再替换这两行。

## 编码注意（踩过的坑）

本仓库文件一律 **UTF-8（无 BOM）**。不要用 Windows PowerShell 5.1 的
`Get-Content` / `Set-Content` 直接做中文文本的往返改写——它默认按 GBK 解码，
会把中文变成 `浣犺拷涓瓨` 这种乱码。需要改中文文件时用编辑器工具，或：

```powershell
$t = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
[IO.File]::WriteAllText($path, $t, (New-Object Text.UTF8Encoding($false)))
```
