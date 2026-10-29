import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { Note } from '../common/NoteModel';
import { NotesStore } from '../common/NotesStore';

/**
 * 笔记应用 · 首页
 *
 * 交互参考印象笔记：
 *   列表页：搜索 + 卡片列表 + 右下角新建
 *   编辑页：返回自动保存、标题大字、正文占满、底部工具栏可删除
 */
@Entry
@Component
struct Index {
  @State notes: Note[] = [];
  @State keyword: string = '';
  @State editing: boolean = false;
  @State draftId: string = '';
  @State draftTitle: string = '';
  @State draftContent: string = '';
  @State isNew: boolean = false;

  private store: NotesStore = new NotesStore();

  aboutToAppear(): void {
    const ctx = getContext(this) as common.UIAbilityContext;
    this.store.init(ctx);
    this.notes = this.store.load();
    this.seedIfEmpty();
  }

  /**
   * 首次启动、库为空时插入两条示例笔记（方便演示；不需要可删掉本方法与调用处）
   */
  seedIfEmpty(): void {
    if (this.notes.length > 0) {
      return;
    }
    this.store.create('欢迎使用云笔记', '这是一款运行在 HarmonyOS 上的云笔记应用。\n\n' +
      '· 右下角 + 新建笔记\n· 点开任意笔记即可编辑\n· 返回列表时自动保存\n· 编辑页右上角可删除');
    this.store.create('周末采购清单', '牛奶 2 盒\n鸡蛋一板\n面包\n咖啡豆\n\n顺路取快递。');
    this.notes = this.store.load();
  }

  filtered(): Note[] {
    const kw: string = this.keyword.trim().toLowerCase();
    if (kw.length === 0) {
      return this.notes;
    }
    return this.notes.filter((n: Note): boolean => {
      return n.title.toLowerCase().includes(kw) || n.content.toLowerCase().includes(kw);
    });
  }

  timeText(ts: number): string {
    const d: Date = new Date(ts);
    const now: Date = new Date();
    const sameDay: boolean = d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth() &&
      d.getDate() === now.getDate();
    const hh: string = d.getHours().toString().padStart(2, '0');
    const mm: string = d.getMinutes().toString().padStart(2, '0');
    if (sameDay) {
      return hh + ':' + mm;
    }
    const mon: string = (d.getMonth() + 1).toString().padStart(2, '0');
    const day: string = d.getDate().toString().padStart(2, '0');
    return mon + '-' + day;
  }

  openNew(): void {
    this.draftId = '';
    this.draftTitle = '';
    this.draftContent = '';
    this.isNew = true;
    this.editing = true;
  }

  openNote(n: Note): void {
    this.draftId = n.id;
    this.draftTitle = n.title;
    this.draftContent = n.content;
    this.isNew = false;
    this.editing = true;
  }

  /** 返回列表时自动保存（空笔记不落库） */
  backAndSave(): void {
    const t: string = this.draftTitle.trim();
    const c: string = this.draftContent.trim();
    if (this.isNew) {
      if (t.length > 0 || c.length > 0) {
        this.store.create(t, c);
      }
    } else if (this.draftId.length > 0) {
      if (t.length === 0 && c.length === 0) {
        this.store.remove(this.draftId);
      } else {
        this.store.update(this.draftId, t, c);
      }
    }
    this.notes = this.store.load();
    this.editing = false;
  }

  confirmDelete(): void {
    AlertDialog.show({
      title: '删除笔记',
      message: '删除后无法恢复，确定删除这篇笔记吗？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#E84026',
        action: () => {
          if (this.draftId.length > 0) {
            this.store.remove(this.draftId);
          }
          this.notes = this.store.load();
          this.editing = false;
          promptAction.showToast({ message: '已删除' });
        }
      }
    });
  }

  // ---------------- 列表页 ----------------

  @Builder
  header() {
    Row() {
      Text('全部笔记')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2329')
      Blank()
      Text(this.notes.length.toString())
        .fontSize(13)
        .fontColor('#8A929B')
        .margin({ right: 6 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 8 })
  }

  @Builder
  searchBar() {
    Row({ space: 8 }) {
      Text('🔍')
        .fontSize(14)
        .opacity(0.55)
      TextInput({ placeholder: '搜索笔记', text: this.keyword })
        .layoutWeight(1)
        .height(38)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .padding(0)
        .placeholderColor('#9AA1A9')
        .onChange((v: string) => {
          this.keyword = v;
        })
    }
    .width('90%')
    .height(40)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#EDEFF2')
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  @Builder
  emptyState() {
    Column({ space: 10 }) {
      Text('📝')
        .fontSize(52)
      Text(this.keyword.length > 0 ? '没有匹配的笔记' : '还没有笔记')
        .fontSize(16)
        .fontColor('#5A626B')
      Text(this.keyword.length > 0 ? '换个关键词试试' : '点右下角 + 开始记录')
        .fontSize(13)
        .fontColor('#9AA1A9')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  noteCard(n: Note) {
    Column({ space: 6 }) {
      Row() {
        Text(n.displayTitle())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2329')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
        Text(this.timeText(n.updatedAt))
          .fontSize(12)
          .fontColor('#9AA1A9')
          .margin({ left: 8 })
      }
      .width('100%')

      Text(n.snippet())
        .fontSize(13)
        .fontColor('#6B7280')
        .maxLines(2)
        .lineHeight(19)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .onClick(() => {
      this.openNote(n);
    })
  }

  @Builder
  listView() {
    Column() {
      this.header()
      this.searchBar()

      if (this.filtered().length === 0) {
        this.emptyState()
      } else {
        List({ space: 10 }) {
          ForEach(this.filtered(), (n: Note) => {
            ListItem() {
              this.noteCard(n)
            }
          }, (n: Note) => n.id)
        }
        .layoutWeight(1)
        .width('92%')
        .scrollBar(BarState.Off)
        .padding({ top: 2, bottom: 90 })
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  fab() {
    Button() {
      Text('+')
        .fontSize(28)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 3 })
    }
    .width(56)
    .height(56)
    .borderRadius(28)
    .backgroundColor('#00A82D')
    .shadow({ radius: 10, color: '#3300A82D', offsetY: 4 })
    .onClick(() => {
      this.openNew();
    })
  }

  // ---------------- 编辑页 ----------------

  @Builder
  editorView() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor('#1F2329')
          .width(40)
          .onClick(() => {
            this.backAndSave();
          })
        Text(this.isNew ? '新建笔记' : '编辑笔记')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1F2329')
        Blank()
        if (!this.isNew) {
          Text('删除')
            .fontSize(14)
            .fontColor('#E84026')
            .onClick(() => {
              this.confirmDelete();
            })
        }
        Text('完成')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 14, right: 14, top: 6, bottom: 6 })
          .backgroundColor('#00A82D')
          .borderRadius(14)
          .margin({ left: 12 })
          .onClick(() => {
            this.backAndSave();
          })
      }
      .width('100%')
      .height(52)
      .padding({ left: 12, right: 16 })

      Divider().color('#E6E8EB')

      Scroll() {
        Column({ space: 10 }) {
          TextInput({ placeholder: '标题', text: this.draftTitle })
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1F2329')
            .placeholderColor('#B6BCC3')
            .backgroundColor(Color.Transparent)
            .padding({ left: 0, right: 0 })
            .height(48)
            .onChange((v: string) => {
              this.draftTitle = v;
            })

          Divider().color('#EEF0F2')

          TextArea({ placeholder: '开始输入…', text: this.draftContent })
            .fontSize(15)
            .fontColor('#2B3138')
            .placeholderColor('#B6BCC3')
            .lineHeight(24)
            .backgroundColor(Color.Transparent)
            .padding({ left: 0, right: 0, top: 6 })
            .constraintSize({ minHeight: 380 })
            .onChange((v: string) => {
              this.draftContent = v;
            })
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding({ left: 20, right: 20, top: 8, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      if (this.editing) {
        this.editorView()
      } else {
        this.listView()
        Column() {
          this.fab()
        }
        .width('100%')
        .height('100%')
        .padding({ right: 20, bottom: 28 })
        .hitTestBehavior(HitTestMode.Transparent)
        .alignItems(HorizontalAlign.End)
        .justifyContent(FlexAlign.End)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F6F7')
  }
}
