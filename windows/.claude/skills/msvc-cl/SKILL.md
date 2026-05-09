---
name: msvc-cl
description: Windows 下 MSVC 编译器（cl.exe）使用规范。Git Bash 环境必须通过批处理文件执行编译。
disable-model-invocation: false
allowed-tools: Bash, Read, Write, Glob, Edit
---

# MSVC 编译器使用规范

## ⚡ 立即执行规则

### 看到 C++ 编译任务 → 立即执行以下步骤：

```
1. 创建 .bat 批处理文件
2. 将编译命令写入 .bat
3. 在 Git Bash 中执行 ./build.bat
```

**不要尝试**：

- ❌ 在 Bash 中直接调用 `cl -c test.cpp`
- ❌ 使用 `cmd /C "cl ..."`（除非单次快速测试）
- ❌ 在批处理中调用 vcvars64.bat

---

## 🚨 核心约束（绝对不可违反）

### 1. 环境假设

- ✅ MSVC 环境已预配置，cl.exe 可直接使用
- ❌ **禁止**在批处理中调用 vcvars64.bat 或任何环境初始化脚本
- ❌ **禁止**搜索 VS 安装目录

### 2. 执行方式

- ✅ **必须**创建 .bat 批处理文件
- ❌ **禁止**在 Git Bash 中直接调用 cl.exe
- ⚠️ 使用 `cmd /C` 仅限单次测试，不适合正式构建

### 3. 文件编码

- 批处理文件：**必须**使用 GB2312 或 UTF-8 with BOM
- C++ 源文件：UTF-8 (no BOM) + 编译时加 `-utf-8`

---

## 快速开始模板

### 最简单的编译测试（复制即用）

```bat
@echo off
cl -nologo -W4 -EHsc -utf-8 test.cpp && test.exe
if errorlevel 1 exit /b 1
echo Test passed.
exit /b 0
```

保存为 `build.bat`，然后在 Bash 中：

```bash
./build.bat
```

### 标准项目构建脚本

```bat
@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Building Project
echo ============================================

:: 编译
echo [1/2] Compiling...
cl -nologo -W4 -EHsc -utf-8 -O2 -D_CRT_SECURE_NO_WARNINGS -c -Fooutput.obj input.cpp
if errorlevel 1 (
    echo [FAILED] Compilation
    exit /b 1
)
echo       OK

:: 链接
echo [2/2] Linking...
cl -nologo output.obj /link -OUT:program.exe
if errorlevel 1 (
    echo [FAILED] Linking
    exit /b 1
)
echo       OK

:: 测试
echo.
echo Running tests...
program.exe
if errorlevel 1 (
    echo [FAILED] Tests
    exit /b 1
)

echo.
echo ============================================
echo SUCCESS
echo ============================================
exit /b 0
```

---

## Git Bash 兼容性问题详解

### 问题根源

Git Bash 运行在类 Unix 环境中，但 cl.exe 是 Windows 原生工具：

| 问题类型   | 表现                   | 原因                    |
| ---------- | ---------------------- | ----------------------- |
| 路径转换   | `/c` → `C:/`           | Bash 误认为路径         |
| 参数解析   | `/Foobj\test.obj` 失败 | Bash 处理反斜杠         |
| 通配符展开 | `cl *.obj` 失败        | Bash 先展开，可能超长度 |

### 解决方案对比

| 方式           | 适用场景         | 优点             | 缺点           |
| -------------- | ---------------- | ---------------- | -------------- |
| .bat 文件      | **所有编译任务** | 完全兼容，可复用 | 需要额外文件   |
| `cmd /C "..."` | 单次快速测试     | 无需文件         | 复杂命令易出错 |
| PowerShell     | 特殊情况         | 脚本能力强       | 参数转义复杂   |

**结论**：.bat 文件是唯一推荐的生产方式。

---

## MSVC 编译参数速查

### 常用参数

| 参数          | 说明                   | 示例                          |
| ------------- | ---------------------- | ----------------------------- |
| `-c`          | 仅编译不链接           | `cl -c main.cpp`              |
| `-Fo<file>`   | 指定输出对象文件       | `-Foobj\main.obj`             |
| `-Fe<file>`   | 指定输出可执行文件     | `-Feapp.exe`                  |
| `-I<dir>`     | 添加头文件搜索路径     | `-Iinclude`                   |
| `-D<macro>`   | 定义预处理器宏         | `-DNDEBUG`                    |
| `-O1` / `-O2` | 优化级别（2 更高）     | `-O2`                         |
| `-W3` / `-W4` | 警告级别（4 最严格）   | `-W4`                         |
| `-EHsc`       | C++ 异常处理模型       | `-EHsc`                       |
| `-nologo`     | 禁止显示版权信息       | `-nologo`                     |
| `-utf-8`      | 源文件使用 UTF-8 编码  | `-utf-8`                      |
| `/link`       | 分隔编译选项和链接选项 | `cl *.obj /link -OUT:app.exe` |

### 推荐组合

**Debug 模式**：

```bat
cl -nologo -W4 -EHsc -utf-8 -Od -Zi -D_DEBUG -D_CRT_SECURE_NO_WARNINGS ...
```

**Release 模式**：

```bat
cl -nologo -W4 -EHsc -utf-8 -O2 -DNDEBUG -D_CRT_SECURE_NO_WARNINGS ...
```

**通用宏**：

```bat
-D_CRT_SECURE_NO_WARNINGS   # 禁止 strcpy 等警告
-DUNICODE -D_UNICODE        # Unicode 支持
```

---

## 批处理最佳实践

### 错误处理

**规则**：每个重要命令后立即检查 errorlevel

```bat
:: ✅ 正确
cl -c test.cpp
if errorlevel 1 exit /b 1

:: ✅ 正确（带提示）
cl -c test.cpp
if errorlevel 1 (
    echo [ERROR] Compilation failed
    exit /b 1
)

:: ❌ 错误（没有检查）
cl -c test.cpp
cl test.obj /link -OUT:test.exe  # 即使上一步失败也会执行
```

### 输出控制

```bat
:: 显示所有输出（调试时）
cl -c test.cpp

:: 隐藏输出，仅显示错误（正式构建）
cl -c test.cpp >nul 2>&1
if errorlevel 1 (
    echo [FAILED] test.cpp
    exit /b 1
)
echo       OK
```

### 返回码规范

```bat
exit /b 0   # 成功
exit /b 1   # 失败
```

**在 Bash 中检查**：

```bash
./build.bat
if [ $? -eq 0 ]; then
    echo "Build succeeded"
else
    echo "Build failed"
fi
```

---

## 多文件项目组织

### 典型结构

```
project/
├── src/
│   ├── main.cpp
│   └── utils.cpp
├── include/
│   └── utils.h
├── build.bat       # 主构建脚本
├── clean.bat       # 清理脚本
└── demo/
    ├── demo.cpp
    └── build_demo.bat
```

### 主构建脚本（build.bat）

```bat
@echo off
setlocal enabledelayedexpansion

echo Building main project...

:: 编译所有源文件
for %%F in (src\*.cpp) do (
    echo Compiling %%F...
    cl -nologo -W4 -EHsc -utf-8 -O2 -Iinclude -c -Fo%%~nF.obj %%F
    if errorlevel 1 exit /b 1
)

:: 链接
cl -nologo *.obj /link -OUT:program.exe
if errorlevel 1 exit /b 1

echo Build successful.
exit /b 0
```

### 清理脚本（clean.bat）

```bat
@echo off
echo Cleaning build artifacts...
for %%f in (*.obj *.exe *.pdb *.ilk) do @del /Q "%%f" 2>nul
for %%D in (demo tests) do @if exist %%D (
    del /Q "%%D\*.obj" "%%D\*.exe" 2>nul
)
echo Cleaned.
exit /b 0
```

---

## 常见错误诊断

### 错误 1：cl 无法识别参数

**症状**：

```
cl : 无法将"/c"项识别为 cmdlet、函数、脚本文件或可运行程序的名称。
```

**原因**：在 Git Bash 中直接调用 cl.exe

**解决**：创建 .bat 文件

---

### 错误 2：批处理"挂起"不退出

**症状**：批处理执行后不返回命令行

**原因**：

1. 程序使用 stderr 输出（常见于测试框架）
2. 程序等待输入

**解决**：

```bat
:: 重定向 stderr
program.exe 2>&1
if errorlevel 1 exit /b 1

:: 或静默执行
program.exe >nul 2>&1
```

---

### 错误 3：中文乱码

**检查清单**：

- [ ] 批处理文件编码：GB2312 或 UTF-8 with BOM
- [ ] C++ 源文件编码：UTF-8 (no BOM)
- [ ] 编译选项包含 `-utf-8`
- [ ] 输出中文时使用 `std::wcout` + 宽字符

---

### 错误 4：找不到 cl.exe

**原因**：MSVC 环境未配置

**检查**：

```bash
# 在 Bash 中测试
cl 2>&1 | head -1
# 应该显示 Microsoft (R) C/C++ Optimizing Compiler ...
```

**如果确实未配置**：

- 在 Windows 终端中手动执行 `vcvars64.bat`
- 然后重新启动 Git Bash

---

## 检查清单（执行前确认）

编译任务执行前，快速检查：

- [ ] 已创建 .bat 批处理文件
- [ ] 批处理编码：GB2312 或 UTF-8 with BOM
- [ ] 包含 `-nologo -utf-8 -O2` 等基本选项
- [ ] 每个命令后有 `if errorlevel 1 exit /b 1`
- [ ] 使用 `exit /b 0` 表示成功
- [ ] 测试程序输出到 stdout（不要只用 stderr）

---

## 代码风格

- 函数/变量：PascalCase（`CalculateTotal`），变量首字母小写（`bufferSize`）
- 宏/常量：UPPER_SNAKE_CASE（`MAX_BUFFER_SIZE`）
- 一行代码限制在 200 字符以内
- 不要有连续多个空行

---

## 完整示例：单元测试项目

### 目录结构

```
tests/
├── test_main.cpp
├── build_tests.bat
└── run_tests.bat
```

### build_tests.bat

```bat
@echo off
setlocal enabledelayedexpansion

echo Building tests...
cl -nologo -W4 -EHsc -utf-8 -O2 -I..\include -c test_main.cpp
if errorlevel 1 exit /b 1

cl -nologo test_main.obj ..\src\utils.obj /link -OUT:test.exe
if errorlevel 1 exit /b 1

echo Build successful.
exit /b 0
```

### run_tests.bat

```bat
@echo off
call build_tests.bat
if errorlevel 1 exit /b 1

echo.
echo Running tests...
test.exe
if errorlevel 1 (
    echo [FAILED] Tests failed
    exit /b 1
)

echo [PASSED] All tests passed
exit /b 0
```

---

## 总结

**核心原则**：

1. 看到编译 → 立即创建 .bat
2. 环境已配置 → 不要调用 vcvars64.bat
3. 每个命令 → 检查 errorlevel
4. 成功返回 0 → 失败返回 1

**快速决策**：

- 简单测试 → 单个 .bat 包含编译+测试
- 正式项目 → build.bat + clean.bat + test.bat
- 遇到错误 → 先检查是否用了 .bat

**记住**：Git Bash 和 cl.exe 不兼容，批处理是桥梁。
