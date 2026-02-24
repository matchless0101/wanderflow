# 24-1levelredeme

## 目的
- 作为本阶段功能拆分与推送的总览说明，便于评审与合并。
- 内容涵盖：分支清单、改动摘要、涉及文件、之前 vs 现在、后续建议。

## 分支与说明

### 1) 3D-hui-home-quickplanner
- 目标：在首页实现“快捷选择”集中块（出行方式/人文关怀/偏好/目的地/天数/预算/进度条），一键生成 3 条推荐并可应用到地图。
- 涉及文件：
  - [HomeView.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Features/Home/HomeView.swift)
  - [QuickPlannerView.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Features/Home/QuickPlannerView.swift)
  - [HomeRecommendations.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Features/Home/HomeRecommendations.swift)
  - 变更记录：[README-3D-hui-home-quickplanner.md](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/README-3D-hui-home-quickplanner.md)
- 之前 vs 现在：
  - 之前：首页主要为静态卡片与分类展示。
  - 现在：中部一个功能块即可完成主要选择并生成 3 条方案；语气更温和，支持“一键应用到地图”。
- 建议：预算联动过滤、接入真实评论/点赞数据、与地图策略更深联动。

### 2) 3D-hui-map-task-panel
- 目标：地图页右上角“今日行程”面板，显示 ETA/停留时长、下一站高亮、完成置灰，支持“打卡/撤回”，状态持久化。
- 涉及文件：
  - [MapView.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Features/Map/MapView.swift)
  - [Itinerary.swift → RoutePlanStore](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Models/Itinerary.swift)
  - 变更记录：[README-3D-hui-map-task-panel.md](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/README-3D-hui-map-task-panel.md)
- 之前 vs 现在：
  - 之前：仅有路线与点位，缺少清晰任务清单与进度感。
  - 现在：可展开/收起查看全程并完成打卡；人性化文案与马卡龙高亮。
- 建议：接入定位阈值自动打卡；展示下一步建议出发时间与耗时。

### 3) 3D-hui-profile-onboarding
- 目标：首次启动画像弹窗（昵称/偏好/预算/MBTI，支持留空），新增“个人”页用于后续修改；本地仓库存储画像。
- 涉及文件：
  - [OnboardingView.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Features/Onboarding/OnboardingView.swift)
  - [ProfileView.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Features/Profile/ProfileView.swift)
  - [UserRepository.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Core/Storage/UserRepository.swift)
  - [User.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Models/User.swift)
  - [ContentView.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/ContentView.swift)
  - 变更记录：[README-3D-hui-profile-onboarding.md](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/README-3D-hui-profile-onboarding.md)
- 之前 vs 现在：
  - 之前：无画像弹窗与资料编辑。
  - 现在：首次仅弹一次画像，后续修改引导至“个人”页，首页保持简洁。
- 建议：画像完整度提示与引导；与推荐器深度联动（预算/偏好影响筛选）。

### 4) 3D-hui-routing-travelmode
- 目标：出行方式影响路线策略；步行模式对中间站点执行“就近串联”重排，减少往返，再进行路线计算。
- 涉及文件：
  - [Itinerary.swift → RoutePlanStore](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Models/Itinerary.swift)
  - [HomeView.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Features/Home/HomeView.swift)
  - 变更记录：[README-3D-hui-routing-travelmode.md](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/README-3D-hui-routing-travelmode.md)
- 之前 vs 现在：
  - 之前：统一按驾车默认策略。
  - 现在：步行更贴合短距连线；为公交/打车后续策略预留扩展点。
- 建议：接入高德步行/公交规划接口；驾车策略细分（避拥堵/高速优先/不走高速）。

### 5) 3D-hui-import-vision
- 目标：从图片（OCR）与 URL 文本中提取候选 POI 名称，作为后续加入路线的来源。
- 涉及文件：
  - [ImportService.swift](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/WanderFlow/Services/ImportService.swift)
  - 变更记录：[README-3D-hui-import-vision.md](file:///g:/Hackthion/北回归线-潮汕/WanderFlow-main/README-3D-hui-import-vision.md)
- 之前 vs 现在：
  - 之前：无法从经验帖或截图中批量抽取地点名。
  - 现在：支持识别候选名称，为地图加入途经点打通入口。
- 建议：加入路线的一键操作与坐标确认；批量正向地理编码并去重。

## 合并建议顺序
1. 3D-hui-profile-onboarding
2. 3D-hui-home-quickplanner
3. 3D-hui-map-task-panel
4. 3D-hui-routing-travelmode
5. 3D-hui-import-vision

## 验收建议
- 首页：完成快捷选择 → 生成 3 条推荐 → 一键应用到地图。
- 地图：展开“今日行程”，验证打卡/撤回与下一站高亮、完成置灰、状态持久化。
- 画像：首次启动弹窗；修改在“个人”页完成并保存。
- 出行方式：步行模式下中间站点顺序“就近串联”，路线更贴合步行体验。

## 注意
- 本阶段未引入新第三方依赖；如接入高德步行/公交规划，将在后续 PR 中说明。
