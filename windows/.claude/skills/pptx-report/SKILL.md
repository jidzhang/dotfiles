---
name: pptx-report
description: Use when the user has multiple individual PPTX work reports and wants to consolidate them into one group-level summary report PPTX. Triggers include "汇总多个PPTX", "合并工作汇报", "做整体汇报PPT", "把大家的报告汇总一下".
---

# PPTX Work Report Consolidation

## Overview

从多份个人PPTX工作汇报中提取内容，按组/团队视角整合为一份结构清晰的汇总报告PPT。

## When to Use

- 用户有多份个人工作汇报PPTX，需要做组级/团队级汇总
- 月度/季度工作汇报汇总场景
- 不要用于：单份PPTX的修改、非工作汇报类的PPTX合并

## Workflow

### Step 1: Scan & Extract

扫描目标文件夹中的所有PPTX文件，逐份提取文本和表格内容。

**编码注意：** Windows下Python stdout默认非UTF-8，必须：

- 脚本开头加 `sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')`
- 运行时加 `-X utf8` 参数：`python -X utf8 script.py`
- 使用 `python` 而非 `python3`（Windows环境）

**提取脚本模板：**

```python
from pptx import Presentation
import os

def extract_pptx(filepath):
    """提取单份PPTX的全部文本和表格内容"""
    prs = Presentation(filepath)
    pages = []
    for slide in prs.slides:
        texts = []
        for shape in slide.shapes:
            if shape.has_text_frame:
                for para in shape.text_frame.paragraphs:
                    t = para.text.strip()
                    if t:
                        texts.append(t)
            if shape.has_table:
                table = shape.table
                for row in table.rows:
                    row_texts = [cell.text.strip() for cell in row.cells]
                    texts.append(' | '.join(row_texts))
        if texts:
            pages.append(texts)
    return pages
```

### Step 2: Analyze & Classify

阅读提取的内容，识别以下关键信息：

| 信息维度 | 提取目标                      |
| -------- | ----------------------------- |
| 人员     | 每份报告对应的人员姓名、角色  |
| 项目     | 涉及的项目名称、状态、进度    |
| 成果     | 关键交付物、Bug处理、文档编写 |
| 计划     | 下阶段工作计划                |
| 协作     | 跨人员协作的项目和任务        |

将项目按类型分类：核心产品、定制开发、测试、打包发布、AI研究等。

### Step 3: Design Report Structure

标准汇总报告结构（根据实际情况可调整）：

| 页码 | 内容                                 |
| ---- | ------------------------------------ |
| 1    | 封面（组名、时间、全体成员）         |
| 2    | 目录                                 |
| 3    | 组概况（成员职责表 + 关键数据指标）  |
| 4-5  | 项目总览（如项目多则分两页）         |
| 6+   | 重点项目详情（每类项目1页）          |
| N    | 人员工作亮点（2行×3列或3行×2列卡片） |
| N+1  | 下阶段工作计划表                     |
| 末页 | 结束页                               |

**布局原则：**

- 每页内容不溢出，宁可拆分也不要压缩到看不清
- 表格行高用0.34英寸，字体10-11pt
- 左右分栏时每栏宽度约6英寸
- 不同工作/不同人员用不同颜色区块区分
- 每个人分配一个专属颜色，贯穿全文保持一致

### Step 4: Generate PPTX

使用 `template.py` 生成报告。模板提供了以下可复用函数：

- `bg(slide, color)` - 设置幻灯片背景色
- `tb(slide, x, y, w, h, text, size, bold, color, align)` - 添加文本框
- `rc(slide, x, y, w, h, color)` - 添加矩形色块
- `hdr(slide, title)` - 添加标准页头（深色背景+标题+橙色分割线）
- `tbl(slide, x, y, rows, cols, widths, data)` - 添加表格（自动交替行色）
- `bullets(slide, x, y, items, size, spacing)` - 批量添加要点

**配色方案：** 模板内置6种人员专属颜色，新增人员可扩展：

| 颜色 | 色值    | 适用          |
| ---- | ------- | ------------- |
| 蓝色 | #2E75B6 | 默认/负责人   |
| 绿色 | #00B050 | 已完成/已交付 |
| 橙色 | #ED7D31 | 测试/跟进     |
| 紫色 | #7030A0 | 协同开发      |
| 青色 | #009688 | 打包发布      |
| 橄榄 | #70AD47 | AI/创新       |

### Step 5: Review & Adjust

生成后检查：

- 每页内容是否完整显示（无文字溢出或被截断）
- 表格是否完整（行列数是否正确）
- 同一人在不同页面的颜色是否一致
- 人员亮点页的卡片是否对齐整齐

## Common Mistakes

| 问题             | 解决方案                                  |
| ---------------- | ----------------------------------------- |
| 中文乱码         | `sys.stdout` 包装UTF-8 + `python -X utf8` |
| 表格溢出页面     | 减小行高（0.34in）或拆分成两页            |
| 字体显示为宋体   | python-pptx 设置 `font.name = '微软雅黑'` |
| pip install 失败 | 用 `python -m pip install python-pptx`    |
| PPTX尺寸不对     | 设置 `prs.slide_width = Inches(13.333)`   |

## Dependencies

```
python -m pip install python-pptx
```
