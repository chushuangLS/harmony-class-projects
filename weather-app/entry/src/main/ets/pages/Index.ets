import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

interface CityItem {
  name: string;
  code: string;
}

interface ForecastItem {
  date: string;
  ymd: string;
  week: string;
  high: string;
  low: string;
  type: string;
  fx: string;
  fl: string;
  sunrise: string;
  sunset: string;
}

interface WeatherData {
  shidu: string;
  pm25: number;
  pm10: number;
  quality: string;
  wendu: string;
  ganmao: string;
  forecast: ForecastItem[];
}

interface CityInfo {
  city: string;
  parent: string;
  updateTime: string;
}

interface WeatherResp {
  status: number;
  message: string;
  date: string;
  time: string;
  cityInfo: CityInfo;
  data: WeatherData;
}

const CITY_LIST: CityItem[] = [
  { name: '北京', code: '101010100' },
  { name: '上海', code: '101020100' },
  { name: '天津', code: '101030100' },
  { name: '重庆', code: '101040100' },
  { name: '广州', code: '101280101' },
  { name: '深圳', code: '101280601' },
  { name: '杭州', code: '101210101' },
  { name: '成都', code: '101270101' },
  { name: '武汉', code: '101200101' },
  { name: '西安', code: '101110101' }
];

@Entry
@Component
struct Index {
  @State cityName: string = '天津';
  @State cityCode: string = '101030100';
  @State selectedIndex: number = 2;
  @State options: SelectOption[] = [];
  @State loading: boolean = false;
  @State errMsg: string = '';
  @State hasData: boolean = false;
  @State wendu: string = '';
  @State weatherType: string = '';
  @State high: string = '';
  @State low: string = '';
  @State shidu: string = '';
  @State pm25: string = '';
  @State quality: string = '';
  @State ganmao: string = '';
  @State updateTime: string = '';
  @State realCity: string = '';
  @State forecast: ForecastItem[] = [];
  @State tipText: string = '点「查询天气」获取实时数据';

  private lastRequestTs: number = 0;

  aboutToAppear(): void {
    this.options = CITY_LIST.map((item: CityItem): SelectOption => {
      return { value: item.name };
    });
    this.queryWeather();
  }

  async queryWeather(): Promise<void> {
    const now: number = Date.now();
    if (now - this.lastRequestTs < 3000 && this.lastRequestTs > 0) {
      this.tipText = '接口限制 3 秒一次，请稍后再点';
      return;
    }
    this.lastRequestTs = now;
    this.loading = true;
    this.errMsg = '';
    this.tipText = '';
    const request = http.createHttp();
    try {
      const url: string = 'http://t.weather.sojson.com/api/weather/city/' + this.cityCode;
      const response = await request.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: 15000,
        readTimeout: 15000
      });
      const body: string = response.result as string;
      const resp: WeatherResp = JSON.parse(body) as WeatherResp;
      if (resp.status !== 200) {
        throw new Error('接口返回 status=' + resp.status + ' (' + resp.message + ')');
      }
      const today: ForecastItem = resp.data.forecast[0];
      this.wendu = resp.data.wendu;
      this.weatherType = today.type;
      this.high = today.high;
      this.low = today.low;
      this.shidu = resp.data.shidu;
      this.pm25 = resp.data.pm25.toFixed(0);
      this.quality = resp.data.quality;
      this.ganmao = resp.data.ganmao;
      this.realCity = resp.cityInfo.city;
      this.updateTime = resp.cityInfo.updateTime;
      this.forecast = resp.data.forecast;
      this.hasData = true;
      this.tipText = '';
    } catch (e) {
      const err = e as BusinessError;
      this.errMsg = '请求失败：' + (err.message !== undefined ? err.message : JSON.stringify(e));
      this.hasData = false;
    } finally {
      request.destroy();
      this.loading = false;
    }
  }

  @Builder
  infoCell(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2D3D')
      Text(label)
        .fontSize(12)
        .fontColor('#7A8B9A')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
  }

  build() {
    Column() {
      Row() {
        Text('天气查询')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2D3D')
        Blank()
        Text(this.updateTime.length > 0 ? ('更新 ' + this.updateTime) : '')
          .fontSize(12)
          .fontColor('#7A8B9A')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 8 })

      Row() {
        Select(this.options)
          .selected(this.selectedIndex)
          .value(this.cityName)
          .font({ size: 16 })
          .width(130)
          .onSelect((index: number, value?: string) => {
            this.selectedIndex = index;
            this.cityName = CITY_LIST[index].name;
            this.cityCode = CITY_LIST[index].code;
          })
        Blank()
        Button('查询天气')
          .fontSize(16)
          .height(40)
          .backgroundColor('#3A7AFE')
          .onClick(() => {
            this.queryWeather();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 12 })

      if (this.loading) {
        LoadingProgress()
          .width(48)
          .height(48)
          .margin({ top: 24 })
      }

      if (this.errMsg.length > 0) {
        Text(this.errMsg)
          .fontSize(14)
          .fontColor('#E84026')
          .padding(12)
          .width('100%')
      }

      if (!this.loading && !this.hasData && this.errMsg.length === 0) {
        Text(this.tipText)
          .fontSize(14)
          .fontColor('#7A8B9A')
          .margin({ top: 40 })
      }

      if (this.hasData) {
        Scroll() {
          Column() {
            Column() {
              Row() {
                Text(this.realCity)
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                Blank()
                Text(this.weatherType)
                  .fontSize(16)
                  .fontColor('#FFFFFF')
              }
              .width('100%')

              Row() {
                Text(this.wendu)
                  .fontSize(64)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('℃')
                  .fontSize(22)
                  .fontColor('#FFFFFF')
                  .margin({ top: 18 })
                Blank()
                Column() {
                  Text(this.high)
                    .fontSize(14)
                    .fontColor('#EAF2FF')
                  Text(this.low)
                    .fontSize(14)
                    .fontColor('#EAF2FF')
                    .margin({ top: 6 })
                }
              }
              .width('100%')
              .margin({ top: 4 })
            }
            .width('100%')
            .padding(20)
            .borderRadius(16)
            .linearGradient({
              angle: 135,
              colors: [['#3A7AFE', 0.0], ['#6AA8FF', 1.0]]
            })

            Row() {
              this.infoCell('湿度', this.shidu)
              this.infoCell('PM2.5', this.pm25)
              this.infoCell('空气质量', this.quality)
            }
            .width('100%')
            .padding(16)
            .margin({ top: 12 })
            .borderRadius(16)
            .backgroundColor('#FFFFFF')

            Text('感冒提示：' + this.ganmao)
              .fontSize(13)
              .fontColor('#4A5B6B')
              .width('100%')
              .padding(14)
              .margin({ top: 12 })
              .borderRadius(12)
              .backgroundColor('#FFF7E6')

            Text('未来几天')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F2D3D')
              .width('100%')
              .margin({ top: 18, bottom: 8 })

            ForEach(this.forecast, (item: ForecastItem) => {
              Row() {
                Column() {
                  Text(item.week)
                    .fontSize(14)
                    .fontColor('#1F2D3D')
                  Text(item.ymd)
                    .fontSize(11)
                    .fontColor('#9AA7B4')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1.2)

                Text(item.type)
                  .fontSize(14)
                  .fontColor('#3A7AFE')
                  .layoutWeight(1)

                Column() {
                  Text(item.high)
                    .fontSize(13)
                    .fontColor('#E84026')
                  Text(item.low)
                    .fontSize(13)
                    .fontColor('#3A7AFE')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)

                Text(item.fx + ' ' + item.fl)
                  .fontSize(12)
                  .fontColor('#7A8B9A')
                  .layoutWeight(1.4)
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .padding({ top: 12, bottom: 12, left: 14, right: 14 })
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .margin({ bottom: 8 })
            }, (item: ForecastItem) => item.ymd)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F6FC')
  }
}
