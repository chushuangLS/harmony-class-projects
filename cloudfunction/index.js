/**
 * AGC 云函数入口（Node.js 18 / 事件调用 · HTTP 触发器）
 *
 * 控制台「函数代码」里把这段整段粘进去即可，入口写 index.handler。
 * 注意：如果模板里导出的是 myHandler，请把 exports.handler 改成 exports.myHandler，
 *      同时把控制台的「函数入口」写成 index.myHandler —— 两边必须一致。
 */
exports.handler = async (event, context) => {
  let body = {};
  try {
    body = event.body ? JSON.parse(event.body) : {};
  } catch (e) {
    body = { raw: event.body };
  }
  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({
      code: 0,
      msg: 'hello from cloud function',
      echo: body,
      serverTime: new Date().toISOString()
    })
  };
};
