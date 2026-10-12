# ============================================================================
# dotfiles 安装脚本（Windows / PowerShell）
# 用法（普通用户即可，符号链接需开发者模式或管理员）:
#   .\install.ps1              # 默认符号链接
#   .\install.ps1 -Copy        # 复制而非链接
#   .\install.ps1 -DryRun      # 只打印动作
# 幂等：可反复执行；冲突文件备份为 *.bak
# ============================================================================
[CmdletBinding()]
param(
  [switch]$Copy,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$Repo      = Split-Path -Parent $PSScriptRoot      # windows/ 的上一级 = 仓库根
$CommonDir = Join-Path $Repo 'common'
$Home_     = $env:USERPROFILE

function Say($m) { Write-Host "  $m" }
function Act($scriptBlock) {
  if ($DryRun) { Write-Host "  [dry-run] $($scriptBlock.ToString().Trim())" }
  else { & $scriptBlock }
}

function Install-One([string]$Src, [string]$Dst, [switch]$SkipIfExists) {
  if (-not (Test-Path $Src)) { return }
  $existing = Get-Item -LiteralPath $Dst -Force -ErrorAction SilentlyContinue
  if ($existing -and $existing.LinkType -eq 'SymbolicLink' -and $existing.Target -eq $Src) {
    Say "已就位  $Dst"; return
  }
  if (-not ($existing -and $existing.LinkType -eq 'SymbolicLink') -and $existing -and (Test-Path $Dst -PathType Leaf) -and (Get-FileHash $Src).Hash -eq (Get-FileHash $Dst).Hash) {
    Say "已就位  $Dst"; return
  }
  if ($SkipIfExists -and $existing) {
    Say "已跳过  $Dst（已存在，未覆盖）"; return
  }
  if ($existing) {
    Act { Move-Item -LiteralPath $Dst -Destination "$Dst.bak" -Force }
    Say "已备份  $Dst -> $Dst.bak"
  }
  Act { New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dst) | Out-Null }
  if ($Copy) {
    Act { Copy-Item -LiteralPath $Src -Destination $Dst -Force }
  } else {
    try {
      Act { New-Item -ItemType SymbolicLink -Path $Dst -Target $Src -Force | Out-Null }
    } catch {
      Say "符号链接失败（需开发者模式/管理员），降级为复制: $Dst"
      Act { Copy-Item -LiteralPath $Src -Destination $Dst -Force }
    }
  }
  Say "已安装  $Dst"
}

Write-Host "== 通用配置 =="
foreach ($f in '.vimrc', '.gitignore_global', '.editorconfig', '.gemrc') {
  Install-One (Join-Path $CommonDir $f) (Join-Path $Home_ $f)
}
# .gitconfig 仓库里是占位符：目标不存在才装，已存在绝不覆盖真实身份
Install-One (Join-Path $CommonDir '.gitconfig') (Join-Path $Home_ '.gitconfig') -SkipIfExists
Install-One (Join-Path $CommonDir 'vim\.ycm_extra_conf.py') (Join-Path $Home_ '.vim\.ycm_extra_conf.py')

Write-Host "== Windows 专属 =="
# windows/ 下的普通点文件直接映射到 %USERPROFILE%
foreach ($f in '.condarc', '.npmrc', '.minttyrc', '.wezterm.lua', '_vsvimrc') {
  Install-One (Join-Path $PSScriptRoot $f) (Join-Path $Home_ $f)
}
# AppData 下的配置按相对路径还原
Install-One (Join-Path $PSScriptRoot 'AppData\Roaming\pip\pip.ini') `
            (Join-Path $Home_ 'AppData\Roaming\pip\pip.ini')
Install-One (Join-Path $PSScriptRoot 'AppData\Roaming\Zed\settings.json') `
            (Join-Path $Home_ 'AppData\Roaming\Zed\settings.json')

if ($DryRun) { Write-Host "== dry-run 结束，未做任何改动 ==" } else { Write-Host "== 完成 ==" }
