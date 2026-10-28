/**
 * AGC 云函数入口（Node.js · 事件调用 / HTTP 触发器）
 *
 * 重要：AGC 云函数的 Node.js 运行时是「四参数回调」风格
 *       必须调用 callback(结果)，函数才算执行完成，否则平台会一直等待直到超时。
 *
 * 控制台配置：
 *   文件名：handler.js
 *   函数入口：handler.myHandler   ← 文件名 + 导出名
 */
let myHandler = async function (event, context, callback, logger) {
  let body = {};
  try {
    body = event.body ? JSON.parse(event.body) : {};
  } catch (e) {
    body = { raw: event.body };
  }

  if (logger) {
    logger.info('event received: ' + JSON.stringify(event));
  }

  // 关键：必须调用 callback 才算执行完成
  callback({
    code: 0,
    msg: 'hello from cloud function',
    echo: body,
    serverTime: new Date().toISOString()
  });
};

export { myHandler };
