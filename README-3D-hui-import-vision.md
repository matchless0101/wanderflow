# 3D-hui-import-vision

## 本次变更
- 新增 ImportService：支持从图片（OCR）或 URL 文本中提取候选 POI 名称，形成候选列表供后续映射为途经点

## 涉及文件
- WanderFlow/Services/ImportService.swift（新）

## 之前 vs 现在
- 之前：无法从经验帖或图片快速抽取地点
- 现在：可将小红书或相册截图中的文字识别为候选地点名，后续在地图中转为 waypoint

## 建议与下一步
- 候选 POI 一键“加入路线”并提供二次校正（坐标确认/重复合并）
- 与高德搜索联动：将候选名称批量正向地理编码后展示更精确的点位
