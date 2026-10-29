# 端云一体空项目（HarmonyOS）

按 DevEco Studio 内置模板 `[CloudDev]Empty Ability` 的结构搭的空工程，用于课程练习起步。

## 结构

```
cloud-integrated-demo/
├── AppScope/
│   ├── app.json5                                  bundleName = com.example.cfapp
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

- 当前 `bundleName = com.example.cfapp`，复用的是 AGC 上已创建的 `com.example.cfapp` 应用，
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
