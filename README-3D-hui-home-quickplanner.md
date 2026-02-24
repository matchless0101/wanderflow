# 3D-hui-home-quickplanner

## 本次变更
- 新增首页“快捷选择”功能块（出行方式/人文关怀/偏好标签/目的地/天数/预算/进度条）；一键生成 3 条推荐并可应用到地图
- 新增推荐器与精选案例库，支持城市/天数/标签筛选与人文关怀打分
- 首页文案与交互微动效优化，强调“温和不打扰”的引导

## 涉及文件
- WanderFlow/Features/Home/QuickPlannerView.swift（新）
- WanderFlow/Features/Home/HomeRecommendations.swift（新）
- WanderFlow/Features/Home/HomeView.swift（改）

## 之前 vs 现在
- 之前：首页仅有静态卡片与分类标签
- 现在：首页集中一个“快捷选择”功能块，用户可直接在首页中部完成主要条件选择并生成 3 条适配路线，减少跳转与决策成本

## 建议与下一步
- 预算联动过滤/标注（预算友好、需门票）
- 将出行方式写入地图侧策略（公交/步行专用线路规划）
- 扩充精选案例库并接入真实评论与点赞数据
