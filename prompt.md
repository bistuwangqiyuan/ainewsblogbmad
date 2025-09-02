@bmad-master.mdc @analyst 唤起 bmad-method 智能体，开发 ai 编程新闻网站.针对 ai 编程新闻网站，首先进行深入调研，编制针对每个网站的详细到可以据之进行开发的详细设计文档。详细设计文档包含所有需要的内容，一定要尽量完善，要模块清晰、绞尽脑汁，十分全面，完整无缺、不能有遗漏！然后按照设计文档完成所有开发并测试。网站展示最新的 ai 编程类新闻并提供文章资讯、用户论坛、ai 专家问答、用户登录/注册、会员等级、积分体系、具有商业网站必备其他功能等。数据库用的是 supabase 的云数据库，用户权限管理和文件存储也基于 supabase。部署平台为 netlify。ai 相关应用技术实现方案为调用 ai 的 api。前端用尽量简单快速的技术，例如 html、js、css 等，不要使用 typescript。网站每天自动爬取 100 条最流行的不重复的相关新闻或帖子或论文（例如 arxiv、Google Scholar 或其他数据和新闻网站，数据来源网站需深入调研 20 个最可行的可获取最新相关论文和新闻的网站，每个网站爬取 10-100 条相关数据，综合去重后放入 supabase 数据库并在网站展示），爬取的相关新闻数据放入数据库并显示；要非常完善，完善到能根据这个分析报告立即进行开发的程度，详细到可以据之完成所有模块的开发和上线。 目标用户群体是个人用户。没有参考的竞品网站和网站风格。计划开发网页端（PC），app 等其他形式都不需要。涉及用户登录/注册功能,登录注册功能均基于 supabase 实现 。没有预期的技术栈，越简单越好，最好没有后端，后端全部由 supabase 实现，若迫不得已还是需要后端，可用 python 的 fast api 实现。、前端用最简单的 html、js 和 css。网站不包含后台管理系统，不需要也设计一套后台的详细模块。不需要支持第三方登录。不需要包括广告位、品牌专区、商城、付费咨询等商业变现模块。 页面风格偏简洁明快。需要列出建议页面结构。要有用户反馈系统，要包含关于我们、隐私和服务协议、网站介绍等常见的商业网站的页面。目标是创建高端商业网站。展示格式是表格形式。有分类/筛选功能，例如按来源、时间、关键词过滤数据。不需要后端，后端用 supabase 实现。不需要开发排期，不需要风险分析。需要用户可以收藏、点赞或评论。用户反馈系统要求支持文件上传并限制类型为常见文件类型和大小小于 10M。不需要后端，后端用 supabase 实现。不需要开发排期，不需要风险分析。用户反馈系统要求支持文件上传并限制大小。需要分页加载数据。网站仅中文。网站不涉及付费功能或订阅系统，网站完全免费。除点赞、评论、收藏外，没有其他互动功能需求。用户不可以编辑或删除自己的评论或收藏。关于评论系统，不需要支持@用户、嵌套评论，仅支持一级评论。无内容审核。无设计稿或 UI 草图，也不用出设计图和 ui 设计，需要同时提出页面布局建议。
目标用户群体是个人用户。没有参考的竞品网站和网站风格。计划开发网页端（PC），app 等其他形式都不需要。涉及用户登录/注册、会员等级、积分体系等复杂功能。没有预期的技术栈，越简单越好，最好没有后端，后端全部由 supabase 实现，若迫不得已还是需要后端，可用 python 的 fast api 实现。、前端用最简单的 html、js 和 css。网站不包含后台管理系统，不需要也设计一套后台的详细模块。不需要支持第三方登录。专家问答像知乎一样公开。不需要包括广告位、品牌专区、商城、付费咨询等商业变现模块。网站需要评论、点赞、收藏、举报等互动功能。 用户发帖、提问是否不要审核机制。 支持图片、视频上传（比如用户发帖或专家回答中）。 需要敏感词过滤或内容违规检测。 需要数据统计功能（如浏览量、用户积分记录等）。 希望有站内消息系统（如私信、系统通知）。 需要支持分页、搜索、筛选等内容浏览体验。用户也可以投稿，不需要审核。用户论坛和 ai 专家问答希望是同一套内容结构下的两个标签页。对积分体系没有预设机制。数据统计功能供用户查看自己的信息。 用户等级和积分体系：需要设计一个从零开始的机制，如等级划分、积分获取规则、积分用途。 敏感词过滤/内容违规检测：使用简单规则匹配。 上传图片视频限制大小/格式。 不需要支持多用户角色（如普通用户、专家）权限区分。 评论系统不需要支持子评论/楼中楼。 页面风格偏简洁。没有参考的竞品网站和网站风格。计划开发网页端（PC），app 等其他形式都不需要。涉及用户登录/注册、会员等级、积分体系等复杂功能。没有预期的技术栈，越简单越好，最好没有后端，后端全部由 supabase 实现，若迫不得已还是需要后端，可用 python 的 fast api 实现。、前端用最简单的 html、js 和 css。网站不包含后台管理系统，不需要也设计一套后台的详细模块。不需要支持第三方登录。专家问答像知乎一样公开。不需要包括广告位、品牌专区、商城、付费咨询等商业变现模块。网站需要评论、点赞、收藏、举报等互动功能。 用户发帖、提问是否不要审核机制。 支持图片、视频上传（比如用户发帖或专家回答中）。 需要敏感词过滤或内容违规检测。 需要数据统计功能（如浏览量、用户积分记录等）。 希望有站内消息系统（如私信、系统通知）。 需要支持分页、搜索、筛选等内容浏览体验。网站仅聚焦在“ai 相关的编程”领域。用户也可以投稿，不需要审核。用户论坛和专家问答希望是同一套内容结构下的两个标签页。对积分体系没有预设机制。数据统计功能供用户查看自己的信息。
SUPABASE_URL = "https://zzyueuweeoakopuuwfau.supabase.co";
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp6eXVldXdlZW9ha29wdXV3ZmF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQzODEzMDEsImV4cCI6MjA1OTk1NzMwMX0.y8V3EXK9QVd3txSWdE3gZrSs96Ao0nvpnd0ntZw_dQ4";
//可选的 ai 的 api_key 如下：若一个不通则启用另一个。
deepseek_API_KEY = "sk-6d326d3e272045868de050be8ddd698f";
GLM_API_KEY = "1cf8de9e31b94d6ba77786f706de2ce7.uQB9GXSVrj8ykogF";
MOONSHOT_API_KEY=sk-M2vL6A8EY9QhhdzdUodSi6jRZHp01fOFxhETQu3T1zTjuHyp
TONGYI_API_KEY=sk-5354ea96c69b44ed96705e8e446f84f9
TENGCENT_API_KEY=sk-9oEqzHR0V9725Bl2YTWyDzsJBDuQbiQqwXrysk0N991R6IKt
SPARK_API_KEY=DdOqdySdMfPVdUPKleqG:oynXFFHutBcilZdqMvpK
DOUBAO_API_KEY=414f57a5-bca0-4e05-bca2-bd6b066e8165
MINIMAX_API_KEY=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJHcm91cE5hbWUiOiLkuK3no4HmlbDmmbrvvIjljJfkuqzvvInnp5HmioDmnInpmZDlhazlj7giLCJVc2VyTmFtZSI6IuS4reejgeaVsOaZuu-8iOWMl-S6rO-8ieenkeaKgOaciemZkOWFrOWPuCIsIkFjY291bnQiOiIiLCJTdWJqZWN0SUQiOiIxOTE1NDI2OTQ3MDc3MjUxNTc1IiwiUGhvbmUiOiIxMzQyNjA4Njg2MSIsIkdyb3VwSUQiOiIxOTE1NDI2OTQ3MDM1MzA4NTM1IiwiUGFnZU5hbWUiOiIiLCJNYWlsIjoiIiwiQ3JlYXRlVGltZSI6IjIwMjUtMDQtMjYgMTE6NTk6NDgiLCJUb2tlblR5cGUiOjEsImlzcyI6Im1pbmltYXgifQ.sV21FKQXA8Ce3s5QHrz66a5cx8dgFVWVlGngtKVcmFgvegJwin7WedaxeWiY-pxGQjt_ZuieSaNGf6X2e33AJCHvIP4m88TX5jlp5Bp_Zw-heEa1J7yeOFo0cmftpJRW2MCcNrmySDPVmB2xeOYKXa7QdIApEXZlBOKtB5EZLEQbPa73HWQPOcveOCXxsq_DzsZQ2UQktlKC8PzFb_zcDmhQLnJJ9vFrpcfnmXCtMDKhBYvPYvRwtvwn6AdcVqSKOPv3kJNIeqIXU494zonpUczylQLyW7zFFRzCE-8My6CjXNp8rG_iWo5cupD7w2z5MP1qvHvVVGl0QyM_LxnSvQ
环境准备：快速安装
在开始使用 BMAD-METHOD 之前，首先需要在你的项目中安装框架：

npx bmad-method install
这个命令会在你的项目中安装 BMAD-METHOD 框架，自动配置所有必要的 AI 代理和模板文件。安装完成后，你就可以开始使用各种角色命令了。

第一步：需求分析与头脑风暴
🧠 使用 /analyst 命令启动分析师角色

/analyst
分析师会与你进行深入的头脑风暴对话
探讨项目背景、目标用户、核心需求
根据内置模板自动生成一份完整的项目简报
为后续的产品设计奠定基础
@analyst 进行深入的头脑风暴对话
探讨项目背景、目标用户、核心需求
根据内置模板自动生成一份完整的项目简报
为后续的产品设计奠定基础
第二步：产品规划与需求文档
📋 使用 /pm 命令呼唤产品经理角色

/pm
产品经理基于项目简报进行深入分析
自动生成详细的 PRD（产品需求文档）
创建项目的 Epic（史诗故事）
确定功能优先级和产品路线图 2) perform-market-research 或 3) create-competitor-analysis
第三步：系统架构设计
🏗️ 使用 /architect 命令呼唤架构师角色

/architect
架构师基于 PRD 和 Epic 进行技术分析
设计完整的系统架构文档
确定技术栈、数据库设计、API 结构
为开发团队提供技术实施指导
第四步：创建用户故事
📝 使用 /sm 命令呼唤 Scrum Master 角色

/sm
Scrum Master 基于 PRD、Epic 和架构文档
创建下一个待开发的用户故事（User Story）
定义验收标准和完成定义
估算故事点数和优先级
第五步：故事开发实现
💻 使用 /dev 命令呼唤开发者角色

/dev
开发者接收刚刚创建的用户故事
进行编码实现、单元测试、集成测试
确保代码质量和功能完整性
完成故事的最终交付
第六步：持续迭代循环
🔄 重复步骤 4-5，直到项目完成

/sm → 创建下一个故事
↓
/dev → 实现故事
↓
/sm → 创建下一个故事
↓
/dev → 实现故事
↓
... 持续循环
