# HarmonyOS 课堂练习：云函数请求 + 天气查询

一个仓库，两个独立的 HarmonyOS 工程（ArkTS + Stage 模型，API 26 / HarmonyOS 7.0.0）。

| 工程 | 首页 | 说明 |
|---|---|---|
| `cloudfunc-app/` | `pages/Index` | 点按钮请求云函数（HTTP 触发器 POST / apigw-client），页面显示状态码、耗时与返回 JSON |
| `weather-app/` | `pages/Index` | 天气查询：城市下拉 + 查询按钮 + 实时天气 + 未来 5 天预报 |

两个工程的 `main_pages.json` 都只注册了 `pages/Index`，`EntryAbility` 也直接 `loadContent('pages/Index')`，因此**打开即是首页**。

---

## 环境要求

- DevEco Studio 26.0.0.851（内置 Node、hvigor、ohpm）
- HarmonyOS SDK API 26（`D:\deveco studio\sdk`）
- 模拟器：`Mate 90 Pro`（HarmonyOS 7.0.0.107 / API 26 / x86_64）

⚠️ **工程路径必须是纯 ASCII**。hvigor 对项目路径有字符限制，中文路径会直接报错：

```
ERROR: 00306003 Specification Limit Violation
Invalid project path. Current path does not match: D:\华为虚拟机\weather-app
```

所以本仓库请放在 `D:\harmony-projects\` 这类纯英文路径下。

## 命令行构建

```bat
set NODE_HOME=D:\deveco studio\tools\node
set DEVECO_SDK_HOME=D:\deveco studio\sdk
set PATH=%NODE_HOME%;%PATH%

cd /d D:\harmony-projects\weather-app
"D:\deveco studio\tools\hvigor\bin\hvigorw.bat" --mode module -p product=default -p buildMode=debug assembleHap --no-daemon
```

产物：`entry/build/default/outputs/default/entry-default-signed.hap`（签名配置存在时）或 `entry-default-unsigned.hap`。

安装运行：

```bat
hdc -t 127.0.0.1:5555 install -r entry-default-signed.hap
hdc -t 127.0.0.1:5555 shell aa start -a EntryAbility -b <bundleName>
hdc -t 127.0.0.1:5555 shell snapshot_display -f /data/local/tmp/s.jpeg
hdc -t 127.0.0.1:5555 file recv /data/local/tmp/s.jpeg .\s.jpeg
```

---

## 签名说明

仓库内**不保存任何签名材料**（`build-profile.json5` 的 `signingConfigs` 为空，`.p12/.cer/.p7b` 已在 `.gitignore` 里排除）。

自动签名的前提：

1. DevEco Studio 已登录华为开发者账号，且登录态有效（token 过期时签名面板会报
   `401 [AppGalleryConnectUserAuthService] getTokenInfo return null`，重新登录即可）
2. **模拟器/真机已连接**（AGC 的调试 Profile 绑定"包名 + 设备 UDID"，没有设备就生成不了 Profile）
3. `File → Project Structure → Signing Configs` 勾选「自动生成签名文件」

生成后 DevEco 会把证书与 Profile 写到 `~/.ohos/config/` 并自动回填 `build-profile.json5`。

---

## cloudfunc-app

### 页面行为

- 首页一个 `Button('请求云函数')`
- 点击后 `POST` 请求 HTTP 触发器，页面展示：**状态码 / 耗时(ms) / 返回 JSON（格式化后滚动展示）**
- 请求失败、未配置域名等情况都有明确提示，不会白屏

### 配置位置

`entry/src/main/ets/common/CloudConfig.ets`

```ts
static readonly BASE_URL: string = '';                 // ← 填 AGC 触发器域名 https://xxx
static readonly TRIGGER_PATH: string = '/functions/4b7o26s1/testhan2-$latest';
static readonly CLIENT_ID: string = '';                // apigw-client 认证需要
static readonly CLIENT_SECRET: string = '';
```

认证流程（`apigw-client`）：

```
POST https://oauth-login.cloud.huawei.com/oauth2/v3/token
     grant_type=client_credentials&client_id=...&client_secret=...
  → access_token
POST {BASE_URL}{TRIGGER_PATH}
     Authorization: Bearer <access_token>
     Content-Type: application/json
     {"request":"Hello World!"}
```

### 当前状态

- 代码、页面、编译、装机全部通过；**未配置 `BASE_URL` 时页面显示引导文案**（已实测截图，见 `docs/cloudfunc-app.jpg`）
- AGC 控制台的触发器卡片只给出相对路径 `/functions/xxx/testhan2-$latest`，域名需要在控制台其他位置（或用 F12 抓一次真实请求）拿到后填入 `BASE_URL`
- 云函数端代码也需要部署（控制台报过 `Cannot find module 'index.js'`，说明函数体没上传成功）

### 包名与签名（重要）

| 工程 | 包名 | AGC 状态 |
|---|---|---|
| `cloudfunc-app` | `com.example.cfapp` | 已在 AGC 创建应用（APP ID `6917620261826369552`），云函数 `testhan2` 建在其项目下 |
| `weather-app` | `com.example.weatherapp` | DevEco 自动签名时自动注册 |

两个包名的调试 Profile **各自独立**（绑定"包名 + 设备 UDID"），需要各自在 DevEco 里生成一次。

本地若已生成过，DevEco 会把签名配置写进 `build-profile.json5`；**仓库里始终是空配置**，请注意：

- 仓库版本 = 干净版（`signingConfigs: []`），克隆后需自己重新签名
- 本机为了继续调试，签名后的配置另存为 `build-profile.signed.bak`（已在 `.gitignore` 中排除），需要时覆盖回去：

```powershell
Copy-Item build-profile.signed.bak build-profile.json5 -Force
```

---

## weather-app

- 接口：`http://t.weather.sojson.com/api/weather/city/{cityId}`（sojson 免费天气 API）
- 内置 10 个城市：北京/上海/天津/重庆/广州/深圳/杭州/成都/武汉/西安
- 接口限流 **3 秒一次**，代码里做了节流提示
- 展示：实时温度、天气、高低温、湿度、PM2.5、空气质量、感冒提示、未来 5 天（星期/日期/天气/高低温/风向风力）
- 权限：`ohos.permission.INTERNET`
- 明文 HTTP 可用（HarmonyOS 7 模拟器实测未拦截）
- **已在 Mate 90 Pro 模拟器实测跑通**，见 `docs/weather-app.jpg`

---

## 实测记录

| 项 | 结果 |
|---|---|
| 模拟器启动 | `Mate 90 Pro` → `hdc` 识别 `127.0.0.1:5555 Connected` |
| DevEco 登录态 | 重新登录后 `LoginSuccessListener - receive login success`，`real-name: true` |
| weather-app 签名 | 生成 `default_weather-app_*.p7b`（bundle `com.example.weatherapp`） |
| weather-app 编译/安装/运行 | BUILD SUCCESSFUL → `install bundle successfully` → 首页显示天津 10.4℃、晴、湿度 31%、PM2.5 16、优、未来 5 天 |
| cloudfunc-app 签名 | 生成 `default_cloudfunc-app_*.p7b`（bundle `com.example.cfapp`） |
| cloudfunc-app 编译/安装/运行 | BUILD SUCCESSFUL → 安装成功 → 点按钮显示配置引导（未填域名） |

## 待补

1. `CloudConfig.BASE_URL`（AGC 触发器域名）
2. `CLIENT_ID` / `CLIENT_SECRET`（AGC → 认证凭据 → 下载认证凭证）
3. AGC 云函数端代码部署（`index.handler`，之前报 `Cannot find module 'index.js'`）
