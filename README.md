cris-cancer
==========

The crawler for the cancer report from department of health

* [origin repo](https://github.com/hcchien/doh-cancer)
* [Visualization](http://g0v.github.io/cancer/viz)

Usage
==========

1. `$ npm install`
2. modify config.ls
3. `$ lsc main.ls`

Description
===========
config.ls 可以修改之部分
form-step1:
  * 'WR1_1_Q_DataII' - [1 2]: [發生率 死亡率]
  * 'WR1_1_Q_PointII' - [A B C D]: [粗率 標準化率(1976年世界標準人口) 標準化率(2000年世界標準人口) 年齡別率]
  * 'WR1_1_Q_SexII' - [0 1 2 3]: [不分性別 男性 女性 男性及女性]

form-step2:
  * 'WR1_1_Q_YearBeginII' - [1979~2010]
  * 'WR1_1_Q_YearEndII' - [1979~2010]

TODO
===========
1. 自動抓取所有條件

License
==========
MIT