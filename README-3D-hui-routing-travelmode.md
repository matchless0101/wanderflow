# 3D-hui-routing-travelmode

## 本次变更
- 新增 TravelMode（driving/taxi/transit/walking）并在 RoutePlanStore 中保存
- 步行模式：在行程地理编码完成后，对中间站点执行“就近串联”重排，减少往返，再计算路线
- 首页“应用到地图”前，将 QuickPlanner 选择的出行方式写入 RoutePlanStore

## 涉及文件
- WanderFlow/Models/Itinerary.swift（改：TravelMode、setTravelMode、reorderForWalking）
- WanderFlow/Features/Home/HomeView.swift（改：applyTravelModeToStore）

## 之前 vs 现在
- 之前：统一按驾车默认策略规划
- 现在：步行场景下更贴合步行连线逻辑；为公交/打车后续策略预留了扩展点

## 建议与下一步
- 接入高德步行/公交规划接口，替代当前用驾车计算的过渡方案
- 驾车策略细分：避拥堵/高速优先/不走高速，根据 QuickPlanner 的出行方式自动选择
