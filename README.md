# HarmonyOS 璇惧爞缁冧範锛氫簯鍑芥暟璇锋眰 + 澶╂皵鏌ヨ

涓€涓粨搴擄紝涓や釜鐙珛鐨?HarmonyOS 宸ョ▼锛圓rkTS + Stage 妯″瀷锛孉PI 26 / HarmonyOS 7.0.0锛夈€?
| 宸ョ▼ | 棣栭〉 | 璇存槑 |
|---|---|---|
| `cloudfunc-app/` | `pages/Index` | 鐐规寜閽姹備簯鍑芥暟锛圚TTP 瑙﹀彂鍣?POST / apigw-client锛夛紝椤甸潰鏄剧ず鐘舵€佺爜銆佽€楁椂涓庤繑鍥?JSON |
| `weather-app/` | `pages/Index` | 澶╂皵鏌ヨ锛氬煄甯備笅鎷?+ 鏌ヨ鎸夐挳 + 瀹炴椂澶╂皵 + 鏈潵 5 澶╅鎶?|

涓や釜宸ョ▼鐨?`main_pages.json` 閮藉彧娉ㄥ唽浜?`pages/Index`锛宍EntryAbility` 涔熺洿鎺?`loadContent('pages/Index')`锛屽洜姝?*鎵撳紑鍗虫槸棣栭〉**銆?
---

## 鐜瑕佹眰

- DevEco Studio 26.0.0.851锛堝唴缃?Node銆乭vigor銆乷hpm锛?- HarmonyOS SDK API 26锛坄D:\deveco studio\sdk`锛?- 妯℃嫙鍣細`Mate 90 Pro`锛圚armonyOS 7.0.0.107 / API 26 / x86_64锛?
鈿狅笍 **宸ョ▼璺緞蹇呴』鏄函 ASCII**銆俬vigor 瀵归」鐩矾寰勬湁瀛楃闄愬埗锛屼腑鏂囪矾寰勪細鐩存帴鎶ラ敊锛?
```
ERROR: 00306003 Specification Limit Violation
Invalid project path. Current path does not match: D:\鍗庝负铏氭嫙鏈篭weather-app
```

鎵€浠ユ湰浠撳簱璇锋斁鍦?`D:\harmony-projects\` 杩欑被绾嫳鏂囪矾寰勪笅銆?
## 鍛戒护琛屾瀯寤?
```bat
set NODE_HOME=D:\deveco studio\tools\node
set DEVECO_SDK_HOME=D:\deveco studio\sdk
set PATH=%NODE_HOME%;%PATH%

cd /d D:\harmony-projects\weather-app
"D:\deveco studio\tools\hvigor\bin\hvigorw.bat" --mode module -p product=default -p buildMode=debug assembleHap --no-daemon
```

浜х墿锛歚entry/build/default/outputs/default/entry-default-signed.hap`锛堢鍚嶉厤缃瓨鍦ㄦ椂锛夋垨 `entry-default-unsigned.hap`銆?
瀹夎杩愯锛?
```bat
hdc -t 127.0.0.1:5555 install -r entry-default-signed.hap
hdc -t 127.0.0.1:5555 shell aa start -a EntryAbility -b <bundleName>
hdc -t 127.0.0.1:5555 shell snapshot_display -f /data/local/tmp/s.jpeg
hdc -t 127.0.0.1:5555 file recv /data/local/tmp/s.jpeg .\s.jpeg
```

---

## 绛惧悕璇存槑

浠撳簱鍐?*涓嶄繚瀛樹换浣曠鍚嶆潗鏂?*锛坄build-profile.json5` 鐨?`signingConfigs` 涓虹┖锛宍.p12/.cer/.p7b` 宸插湪 `.gitignore` 閲屾帓闄わ級銆?
鑷姩绛惧悕鐨勫墠鎻愶細

1. DevEco Studio 宸茬櫥褰曞崕涓哄紑鍙戣€呰处鍙凤紝涓旂櫥褰曟€佹湁鏁堬紙token 杩囨湡鏃剁鍚嶉潰鏉夸細鎶?   `401 [AppGalleryConnectUserAuthService] getTokenInfo return null`锛岄噸鏂扮櫥褰曞嵆鍙級
2. **妯℃嫙鍣?鐪熸満宸茶繛鎺?*锛圓GC 鐨勮皟璇?Profile 缁戝畾"鍖呭悕 + 璁惧 UDID"锛屾病鏈夎澶囧氨鐢熸垚涓嶄簡 Profile锛?3. `File 鈫?Project Structure 鈫?Signing Configs` 鍕鹃€夈€岃嚜鍔ㄧ敓鎴愮鍚嶆枃浠躲€?
鐢熸垚鍚?DevEco 浼氭妸璇佷功涓?Profile 鍐欏埌 `~/.ohos/config/` 骞惰嚜鍔ㄥ洖濉?`build-profile.json5`銆?
---

## cloudfunc-app

### 椤甸潰琛屼负

- 棣栭〉涓€涓?`Button('璇锋眰浜戝嚱鏁?)`
- 鐐瑰嚮鍚?`POST` 璇锋眰 HTTP 瑙﹀彂鍣紝椤甸潰灞曠ず锛?*鐘舵€佺爜 / 鑰楁椂(ms) / 杩斿洖 JSON锛堟牸寮忓寲鍚庢粴鍔ㄥ睍绀猴級**
- 璇锋眰澶辫触銆佹湭閰嶇疆鍩熷悕绛夋儏鍐甸兘鏈夋槑纭彁绀猴紝涓嶄細鐧藉睆

### 閰嶇疆浣嶇疆

`entry/src/main/ets/common/CloudConfig.ets`

```ts
static readonly BASE_URL: string = '';                 // 鈫?濉?AGC 瑙﹀彂鍣ㄥ煙鍚?https://xxx
static readonly TRIGGER_PATH: string = '/functions/4b7o26s1/testhan2-$latest';
static readonly CLIENT_ID: string = '';                // apigw-client 璁よ瘉闇€瑕?static readonly CLIENT_SECRET: string = '';
```

璁よ瘉娴佺▼锛坄apigw-client`锛夛細

```
POST https://oauth-login.cloud.huawei.com/oauth2/v3/token
     grant_type=client_credentials&client_id=...&client_secret=...
  鈫?access_token
POST {BASE_URL}{TRIGGER_PATH}
     Authorization: Bearer <access_token>
     Content-Type: application/json
     {"request":"Hello World!"}
```

### 褰撳墠鐘舵€?
- 浠ｇ爜銆侀〉闈€佺紪璇戙€佽鏈哄叏閮ㄩ€氳繃锛?*鏈厤缃?`BASE_URL` 鏃堕〉闈㈡樉绀哄紩瀵兼枃妗?*锛堝凡瀹炴祴鎴浘锛岃 `docs/cloudfunc-app.jpg`锛?- AGC 鎺у埗鍙扮殑瑙﹀彂鍣ㄥ崱鐗囧彧缁欏嚭鐩稿璺緞 `/functions/xxx/testhan2-$latest`锛屽煙鍚嶉渶瑕佸湪鎺у埗鍙板叾浠栦綅缃紙鎴栫敤 F12 鎶撲竴娆＄湡瀹炶姹傦級鎷垮埌鍚庡～鍏?`BASE_URL`
- 浜戝嚱鏁扮浠ｇ爜涔熼渶瑕侀儴缃诧紙鎺у埗鍙版姤杩?`Cannot find module 'index.js'`锛岃鏄庡嚱鏁颁綋娌′笂浼犳垚鍔燂級

### 鍖呭悕涓庣鍚嶏紙閲嶈锛?
| 宸ョ▼ | 鍖呭悕 | AGC 鐘舵€?|
|---|---|---|
| `cloudfunc-app` | `com.example.cfapp` | 宸插湪 AGC 鍒涘缓搴旂敤锛圓PP ID `6917620261826369552`锛夛紝浜戝嚱鏁?`testhan2` 寤哄湪鍏堕」鐩笅 |
| `weather-app` | `com.example.weatherapp` | DevEco 鑷姩绛惧悕鏃惰嚜鍔ㄦ敞鍐?|

涓や釜鍖呭悕鐨勮皟璇?Profile **鍚勮嚜鐙珛**锛堢粦瀹?鍖呭悕 + 璁惧 UDID"锛夛紝闇€瑕佸悇鑷湪 DevEco 閲岀敓鎴愪竴娆°€?
鏈湴鑻ュ凡鐢熸垚杩囷紝DevEco 浼氭妸绛惧悕閰嶇疆鍐欒繘 `build-profile.json5`锛?*浠撳簱閲屽缁堟槸绌洪厤缃?*锛岃娉ㄦ剰锛?
- 浠撳簱鐗堟湰 = 骞插噣鐗堬紙`signingConfigs: []`锛夛紝鍏嬮殕鍚庨渶鑷繁閲嶆柊绛惧悕
- 鏈満涓轰簡缁х画璋冭瘯锛岀鍚嶅悗鐨勯厤缃彟瀛樹负 `build-profile.signed.bak`锛堝凡鍦?`.gitignore` 涓帓闄わ級锛岄渶瑕佹椂瑕嗙洊鍥炲幓锛?
```powershell
Copy-Item build-profile.signed.bak build-profile.json5 -Force
```

---

## weather-app

- 鎺ュ彛锛歚http://t.weather.sojson.com/api/weather/city/{cityId}`锛坰ojson 鍏嶈垂澶╂皵 API锛?- 鍐呯疆 10 涓煄甯傦細鍖椾含/涓婃捣/澶╂触/閲嶅簡/骞垮窞/娣卞湷/鏉窞/鎴愰兘/姝︽眽/瑗垮畨
- 鎺ュ彛闄愭祦 **3 绉掍竴娆?*锛屼唬鐮侀噷鍋氫簡鑺傛祦鎻愮ず
- 灞曠ず锛氬疄鏃舵俯搴︺€佸ぉ姘斻€侀珮浣庢俯銆佹箍搴︺€丳M2.5銆佺┖姘旇川閲忋€佹劅鍐掓彁绀恒€佹湭鏉?5 澶╋紙鏄熸湡/鏃ユ湡/澶╂皵/楂樹綆娓?椋庡悜椋庡姏锛?- 鏉冮檺锛歚ohos.permission.INTERNET`
- 鏄庢枃 HTTP 鍙敤锛圚armonyOS 7 妯℃嫙鍣ㄥ疄娴嬫湭鎷︽埅锛?- **宸插湪 Mate 90 Pro 妯℃嫙鍣ㄥ疄娴嬭窇閫?*锛岃 `docs/weather-app.jpg`

---

## 瀹炴祴璁板綍

| 椤?| 缁撴灉 |
|---|---|
| 妯℃嫙鍣ㄥ惎鍔?| `Mate 90 Pro` 鈫?`hdc` 璇嗗埆 `127.0.0.1:5555 Connected` |
| DevEco 鐧诲綍鎬?| 閲嶆柊鐧诲綍鍚?`LoginSuccessListener - receive login success`锛宍real-name: true` |
| weather-app 绛惧悕 | 鐢熸垚 `default_weather-app_*.p7b`锛坆undle `com.example.weatherapp`锛?|
| weather-app 缂栬瘧/瀹夎/杩愯 | BUILD SUCCESSFUL 鈫?`install bundle successfully` 鈫?棣栭〉鏄剧ず澶╂触 10.4鈩冦€佹櫞銆佹箍搴?31%銆丳M2.5 16銆佷紭銆佹湭鏉?5 澶?|
| cloudfunc-app 绛惧悕 | 鐢熸垚 `default_cloudfunc-app_*.p7b`锛坆undle `com.example.cfapp`锛?|
| cloudfunc-app 缂栬瘧/瀹夎/杩愯 | BUILD SUCCESSFUL 鈫?瀹夎鎴愬姛 鈫?鐐规寜閽樉绀洪厤缃紩瀵硷紙鏈～鍩熷悕锛?|

## 寰呰ˉ

1. `CloudConfig.BASE_URL`锛圓GC 瑙﹀彂鍣ㄥ煙鍚嶏級
2. `CLIENT_ID` / `CLIENT_SECRET`锛圓GC 鈫?璁よ瘉鍑嵁 鈫?涓嬭浇璁よ瘉鍑瘉锛?3. AGC 浜戝嚱鏁扮浠ｇ爜閮ㄧ讲锛坄index.handler`锛屼箣鍓嶆姤 `Cannot find module 'index.js'`锛?
---

## cloudfunction/（云函数端代码，供控制台粘贴）

- `cloudfunction/index.js`：函数入口 `handler.myHandler`（callback 风格），回显请求体并返回服务器时间
- `cloudfunction/function-config.json`：触发器配置参考（HTTP / POST / apigw-client / 启用 decode）

部署方法：AGC 控制台 → 云函数 → `testhan2` → 「函数代码」→ 运行环境 Node.js 18、入口 `handler.myHandler` → 粘贴 `index.js` 内容 → 保存并部署。
部署后用「测试」验证，返回应为：

```json
{ "code": 0, "msg": "hello from cloud function", "echo": {...}, "serverTime": "..." }
```

之前控制台报 `Cannot find module '/dcache/layer/func/index.js'`，说明函数体没有上传成功，必须先解决这一步。
---

## 【已打通】云函数真实调用链路（逆向 AGC 官方 SDK 得到）

AGC 新版控制台的「触发URL」只给相对路径，真实公网地址需要按官方 `@hw-agconnect/cloud` SDK 的规则拼装。
以下参数已在本项目实测跑通（模拟器 → HTTP 200 → `{"code":0,...}`）：

| 项 | 值 |
|---|---|
| 网关域名 | `https://connect-drcn.dbankcloud.cn`（= agconnect-services.json 里的 `agcgw.url`） |
| 触发路径 | `/agc/apigw/wisefunction/functions/4b7o26s1/testhan2-$latest` |
| 取 token | `POST /agc/apigw/oauth2/v1/token` |
| appId 算法 | `base36(sha256("agc:<cp_id>@<product_id>"))` 取前 8 位 → `4b7o26s1` |

### 取 token

```
POST https://connect-drcn.dbankcloud.cn/agc/apigw/oauth2/v1/token
Content-Type: application/json;charset=UTF-8

{
  "grant_type": "client_credentials",
  "client_id": "<应用客户端ID>",
  "client_secret": "<应用客户端密钥>",
  "useJwt": 1
}
```

### 调用函数

```
POST https://connect-drcn.dbankcloud.cn/agc/apigw/wisefunction/functions/4b7o26s1/testhan2-$latest
Authorization: Bearer <access_token>
client_id:     <应用客户端ID>
appId:         6917620261826369552
productId:     101653523865475304
sdkServiceName: agconnect-cloud
sdkVersion:    1.0.2
sdkPlatform:   OpenHarmony
sdkType:       TS
packageName:   com.example.cfapp
Content-Type:  application/json;charset=UTF-8

{"request":"Hello World!"}
```

**注意**：缺任何一个身份头都会返回 `401 {"ret":{"code":205524993,"msg":"client token auth failed"}}`。

### 实测结果

```json
{
  "code": 0,
  "msg": "hello from cloud function",
  "echo": { "request": "Hello World!" },
  "serverTime": "2026-10-28T10:04:35.644Z"
}
```

页面展示：状态码 `200`、耗时 `277 ms`、token 有效期 `14399 秒`、返回 JSON 格式化后滚动显示。

### ⚠️ 安全提醒

`CLIENT_ID` / `CLIENT_SECRET` 目前**写死在 `CloudConfig.ets` 里**（课堂作业为了方便直接可跑）。
本仓库是公开的，课后建议到 AGC 重建一次 API 客户端并作废该密钥。