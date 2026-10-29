# 端云一体空项目（HarmonyOS）

按 DevEco Studio 内置模板 `[CloudDev]Empty Ability` 的结构搭的空工程，用于课程练习起步。

## 结构

```
cloud-integrated-demo/
├── AppScope/
│   ├── app.json5                                  bundleName = com.chushuangls.clouddemo
│   └── resources/rawfile/agconnect-services.json   AGC 项目配置（云端调用必需）
├── entry/                                         端侧模块（首页 pages/Index）
├── cloud_objects/                                 云端对象生成的调用接口（har 模块）
│   ├── Index.ets
│   └── src/main/ets/
│       ├── ImportObject.ts                        cloudFunction.call 的通用封装
│       └── id-generator/IdGenerator.ts
├── CloudProgram/                                  云端代码
│   ├── clouddb/db-config.json                     云数据库配置
│   └── cloudfunctions/id-generator/               云函数示例
│       ├── function-config.json                   HTTP 触发器 / apigw-client
│       ├── idGenerator.ts
│       └── package.json
├── build-profile.json5                            modules: entry + cloud_objects
├── hvigorfile.ts
└── oh-package.json5
```

## 关键点

| 项 | 说明 |
|---|---|
| 云端调用方式（API 12+） | `import { cloudFunction } from '@kit.CloudFoundationKit'` → `cloudFunction.call({name, version, data})` |
| `@kit.CloudFoundationKit` 来源 | **HMS SDK**（`D:\deveco studio\sdk\default\hms`），openharmony SDK 里没有 |
| 必需权限 | `ohos.permission.INTERNET`（`entry/src/main/module.json5` 已声明） |
| 必需配置 | `AppScope/resources/rawfile/agconnect-services.json`，其中 `package_name` 必须等于本工程 `bundleName` |
| 依赖 | `entry/oh-package.json5` 里有 `"cloud_objects": "file:../cloud_objects"` |

## 注意

- 当前 `bundleName = com.chushuangls.clouddemo`，复用的是 AGC 上已创建的 `com.chushuangls.clouddemo` 应用，
  所以 `agconnect-services.json` 能直接匹配。
- 与仓库里的 `cloudfunc-app` **包名相同**，两个 App 不能同时安装在设备上（后装的会覆盖前者）。
  若想共存，把本工程 `AppScope/app.json5` 的 `bundleName` 改掉，并到 AGC 新建对应应用、
  重新下载 `agconnect-services.json` 覆盖 `rawfile/` 里的那份。

## 构建

```powershell
$env:NODE_HOME='D:\deveco studio\tools\node'
$env:DEVECO_SDK_HOME='D:\deveco studio\sdk'
$env:PATH="$env:NODE_HOME;$env:PATH"
Set-Location 'D:\harmony-projects\cloud-integrated-demo'
& 'D:\deveco studio\tools\hvigor\bin\hvigorw.bat' --mode module -p product=default -p buildMode=debug assembleHap --no-daemon
```

签名：用 DevEco 打开工程 → `File → Project Structure → Signing Configs` → 勾「自动生成签名文件」
（需登录态有效 + 模拟器在线）。

## 下一步（课堂上通常会做的）

1. `CloudProgram/cloudfunctions/` 下新增函数 → 右键 `Deploy Cloud Function` 部署
2. 函数右键 `Generate Invoke Interface` → 自动生成到 `cloud_objects/`
3. 端侧 `import { IdGenerator, importObject } from 'cloud_objects'` 直接调用
4. 云数据库：`CloudProgram/clouddb/objecttype/` 下加对象类型 → 部署 → 端侧 `cloudDatabase`

## 包名与 AGC 配置（独立项目，勿与旧工程混用）

本工程包名固定为 **`com.chushuangls.clouddemo`**，与仓库里的 `cloudfunc-app`（`com.example.cfapp`）完全独立，
可同时安装、互不覆盖。

`@kit.CloudFoundationKit` 的云端调用要求：
`AppScope/resources/rawfile/agconnect-services.json` 里的 `package_name` **必须等于本工程 bundleName**。

当前 `rawfile/` 里只有 `agconnect-services.example.json`（那是 `com.example.cfapp` 的旧文件，仅作格式参考）。
启用云端能力前必须：

1. AGC 控制台 → 应用管理 → 新建应用，包名填 **`com.chushuangls.clouddemo`**
2. 该应用页底部 `SDK配置` → 下载 `agconnect-services.json`
3. 重命名去掉 `.example`，覆盖到 `AppScope/resources/rawfile/`（并删除 example 文件）
4. DevEco 打开本工程 → `Project Structure → Signing Configs` → 勾「自动生成签名文件」（新包名需新 Profile）

## 关于「我在工程里找不到 testhan2」

`CloudProgram/cloudfunctions/` 是**本地源码目录**，只放"准备部署到云端"的函数；
AGC 上已有的函数**不会自动同步到本地**，所以在工程树里看不到是正常的。

要在端侧调用云端的 `testhan2`，**不需要它有本地源码**，直接：

```ts
import { cloudFunction } from '@kit.CloudFoundationKit';

const res = await cloudFunction.call({
  name: 'testhan2',
  version: '$latest',
  data: { request: 'Hello World!' }
});
```

如果希望它在 IDE 里可见可改，就在 `CloudProgram/cloudfunctions/` 下新建同名函数，
再右键 `Deploy Cloud Function`（会覆盖云端同名函数的代码）。
## 实际调用链路（当前实现，已实测 200）

```
POST https://connect-drcn.dbankcloud.cn/agc/apigw/oauth2/v1/token
     {"grant_type":"client_credentials","client_id":...,"client_secret":...,"useJwt":1}
  → access_token

POST https://connect-drcn.dbankcloud.cn/agc/apigw/wisefunction/functions/4b7o26s1/testhan2-$latest
     Authorization: Bearer <token>
     client_id / appId / productId / sdkServiceName / sdkPlatform / sdkType / packageName
  → 200 {"code":0,"msg":"hello from cloud function",...}
```

配置在 `entry/src/main/ets/common/CloudGateway.ets`。
实测结果：状态码 200、耗时 564 ms。

## 关于官方 `cloudFunction.call`（未走通，已记录）

`@kit.CloudFoundationKit` 的 `cloudFunction.call({name:'testhan2', version:'$latest', data})`
请求能到达服务端，但一直返回：

```
code: 1008211001
message: 401:205525007:verify signature failed
```

已排查并排除：
- 网络 / 网关可达 ✅
- 应用与云函数同属项目 `101653523865475304` ✅
- `agconnect-services.json` 包名匹配 ✅
- AGC 已登记公钥指纹 `FA870D8A…420FA` ✅
- 指纹变更后重新下载过配置文件（`client_secret` 已重新加密）✅

仍失败，推测还需要在 DevEco 签名面板勾选「关联已注册应用」，让 AGC 把证书与项目正式绑定。
在那之前，端侧调用走上面的直连方式。