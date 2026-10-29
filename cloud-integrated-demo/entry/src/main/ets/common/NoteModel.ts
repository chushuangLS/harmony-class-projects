/**
 * 笔记数据模型
 */
export class Note {
  id: string = '';
  title: string = '';
  content: string = '';
  updatedAt: number = 0;

  constructor(id: string, title: string, content: string, updatedAt: number) {
    this.id = id;
    this.title = title;
    this.content = content;
    this.updatedAt = updatedAt;
  }

  /** 列表里显示的摘要：取正文前两行的压缩文本 */
  snippet(): string {
    const flat: string = this.content.replace(/\s+/g, ' ').trim();
    if (flat.length === 0) {
      return '暂无内容';
    }
    return flat.length > 60 ? flat.substring(0, 60) + '…' : flat;
  }

  displayTitle(): string {
    const t: string = this.title.trim();
    return t.length > 0 ? t : '无标题笔记';
  }
}
