# Claude Code 开发配置（Windows + MSVC）

## 核心规则

**MSVC 编译必须使用 .bat 文件**，禁止在 Bash 中直接调用 cl.exe（Git Bash 会误解析 `/c`、`/Fo` 等参数）。

```
编译任务 → 创建 .bat 文件 → ./build.bat
禁止：cl -c test.cpp | cmd /C "cl ..."
```

## 环境信息

| 项目 | 配置 |
|------|------|
| 系统 | Windows（Git Bash） |
| 编译器 | MSVC (VS2019)，环境已配置 |
| Python | 3.13, 环境已配置 |
| C++源文件 | UTF-8 (no BOM) + 编译时加 `-utf-8` |
| 批处理文件 | GB2312 或 UTF-8 with BOM |

## C++ 标准

- **生产代码**：C++03（兼容 VS2005-2022）；C++11/17 需用户明确指定或项目 CLAUDE.md 中声明
- **测试代码**：可用 C++11

## 批处理要点

- 编译/链接/运行每步必须检查 `errorlevel`
- 成功返回 `exit /b 0`，失败返回 `exit /b 1`
- 完整模板见各项目 CLAUDE.md 或用 `/msvc-cl` skill 查询

## 代码规范

| 类别 | 规则 |
|------|------|
| 命名 | 函数/变量 PascalCase（变量首字母小写）；宏 UPPER_SNAKE_CASE |
| 函数 | 禁止 static 局部变量；const 正确性；输入用 const 引用 |
| 修改前 | 读构造/析构 → 搜索重载 → 确认 C++ 标准 → 写伪代码 |

## 行为准则

**Think Before Coding：不确定就问，不瞎猜。**
- 有歧义时列出多种理解，让用户选择，不要静默选一个
- 如果存在更简单的方案，主动提出来
- 理不清需求时，先说清哪里不懂

**Goal-Driven Execution：把任务转成可验证的目标。**
- 修 bug → 先写复现测试，再改代码让它通过
- 加功能 → 先定成功标准，做完后验证
- 重构 → 确认测试前后都通过

## 交付要求

如果用户未指定项目结构，默认按此组织：

```
project/
├── src/           # 源文件
├── include/       # 头文件
├── build.bat      # 编译脚本
├── test.bat       # 测试脚本（返回 0 表示成功）
└── README.txt     # 简要说明
```

测试框架：C++ 默认用 catch2（测试代码可用 C++11），Python 默认用 pytest

## 故障排除

| 症状 | 检查项 |
|------|--------|
| cl 找不到/参数错误 | 是否在 Bash 直接调用？改用 .bat |
| 批处理挂起 | 程序向 stderr 输出？用 `program.exe 2>&1` |
| 中文乱码 | .bat 用 GB2312/UTF-8 BOM；源文件加 `-utf-8` |

## Git 提交

- 提交信息保持干净，**禁止** AI 署名
- 概括修改内容和用途，不要罗列所有文件

## Python 规范

- 类型注解：必须注解参数和返回值
- 包管理：提供 `environment.yml` 或 `requirements.txt`
- 风格：PEP 8，命名可用 PascalCase

