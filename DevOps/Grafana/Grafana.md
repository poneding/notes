# Grafana

官方文档：https://grafana.com/docs/grafana/latest/

## 简介

## 特性

- 可视化：通过图表展示指标信息，直观，便于分析

- 报警：指标数据超出阈值

- 统一：多种数据源可以应用到同一个Dashboard中

- 多平台支持：windows、linux、docker、mac

- 丰富的插件扩展

- 丰富的模板支持

## 使用Grafana监控Jenkins

> 监控指标包括:jenkins发布状态,jenkins的发布时长等.

### 前提条件

1. 已安装jenkins

2. 已安装prometheus

3. 已安装grafana

### Jenkins安装插件

登入Jenkins => Manage Jenkins => Manage Plugins => Available页签 搜索Prometheus插件,安装即可.

此节可以参考:https://medium.com/@eng.mohamed.m.saeed/monitoring-jenkins-with-grafana-and-prometheus-a7e037cbb376
