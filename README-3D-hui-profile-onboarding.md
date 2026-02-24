# 3D-hui-profile-onboarding

## 本次变更
- 首次启动画像弹窗：昵称、偏好、预算、MBTI（可留空），保存后进入首页
- 新增个人页：可修改画像信息并保存
- 新增本地仓库存储画像（UserDefaults）

## 涉及文件
- WanderFlow/Features/Onboarding/OnboardingView.swift（新/改）
- WanderFlow/Features/Profile/ProfileView.swift（新）
- WanderFlow/Core/Storage/UserRepository.swift（新）
- WanderFlow/Models/User.swift（改：新增 mbti 与 personaTags）
- WanderFlow/ContentView.swift（改：接入 Onboarding 与 Profile Tab）

## 之前 vs 现在
- 之前：无画像弹窗与个人资料编辑
- 现在：首次仅弹一次画像，后续改动引导到“个人”页完成，保证首页简洁

## 建议与下一步
- 增加画像完整度提示与温柔引导
- 将画像与推荐器深度联动（如偏好/预算影响筛选）
