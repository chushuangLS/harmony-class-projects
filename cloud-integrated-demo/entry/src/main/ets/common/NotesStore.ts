import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { Note } from './NoteModel';

/**
 * 笔记存储（本地 preferences 持久化）
 *
 * 数据结构：单个 key 存一个 Note 数组的 JSON 字符串。
 * 云端切换见 CloudNotesRepo.ets。
 */
export class NotesStore {
  private static readonly STORE_NAME: string = 'notes_store';
  private static readonly KEY: string = 'notes';
  private store: preferences.Preferences | null = null;

  init(context: common.UIAbilityContext): void {
    if (this.store === null) {
      const options: preferences.Options = { name: NotesStore.STORE_NAME };
      this.store = preferences.getPreferencesSync(context, options);
    }
  }

  load(): Note[] {
    if (this.store === null) {
      return [];
    }
    const raw: string = this.store.getSync(NotesStore.KEY, '[]') as string;
    let list: Note[] = [];
    try {
      const arr: Note[] = JSON.parse(raw) as Note[];
      list = arr.map((n: Note): Note => new Note(n.id, n.title, n.content, n.updatedAt));
    } catch (e) {
      list = [];
    }
    list.sort((a: Note, b: Note): number => b.updatedAt - a.updatedAt);
    return list;
  }

  save(list: Note[]): void {
    if (this.store === null) {
      return;
    }
    this.store.putSync(NotesStore.KEY, JSON.stringify(list));
    this.store.flush();
  }

  create(title: string, content: string): Note {
    const list: Note[] = this.load();
    const note: Note = new Note(Date.now().toString(), title, content, Date.now());
    list.unshift(note);
    this.save(list);
    return note;
  }

  update(id: string, title: string, content: string): void {
    const list: Note[] = this.load();
    const idx: number = list.findIndex((n: Note): boolean => n.id === id);
    if (idx >= 0) {
      list[idx].title = title;
      list[idx].content = content;
      list[idx].updatedAt = Date.now();
      this.save(list);
    }
  }

  remove(id: string): void {
    const list: Note[] = this.load();
    const rest: Note[] = list.filter((n: Note): boolean => n.id !== id);
    this.save(rest);
  }
}
