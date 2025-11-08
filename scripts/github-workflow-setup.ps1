# GitHub Workflow Setup Script (Windows PowerShell)
# AI-driven-work 프로젝트의 GitHub 워크플로우 설정을 다른 프로젝트에 추가합니다.
#
# Usage:
#   .\scripts\github-workflow-setup.ps1 <target-project-path> [-DryRun]
#
# Examples:
#   .\scripts\github-workflow-setup.ps1 C:\projects\my-web-app
#   .\scripts\github-workflow-setup.ps1 C:\projects\my-web-app -DryRun

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$TargetProjectPath,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# 에러 발생 시 중단
$ErrorActionPreference = "Stop"

# 색상 출력 함수
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "🔀 GitHub Workflow Setup" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

if ($DryRun) {
    Write-ColorOutput "🔍 DRY-RUN 모드: 실제 변경 없이 미리보기만 수행합니다." "Cyan"
    Write-Host ""
}

# 타겟 경로 확인
if (-not (Test-Path $TargetProjectPath)) {
    Write-ColorOutput "❌ 타겟 디렉토리가 존재하지 않습니다: $TargetProjectPath" "Red"
    exit 1
}

$TargetProjectPath = Resolve-Path $TargetProjectPath

# 소스 경로
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$SOURCE_PROJECT_DIR = Split-Path -Parent $SCRIPT_DIR
$SOURCE_INSTRUCTIONS_DIR = Join-Path $SOURCE_PROJECT_DIR ".claude\instructions"
$SOURCE_GITHUB_WORKFLOW = Join-Path $SOURCE_INSTRUCTIONS_DIR "github-workflow.md"

# 타겟 경로
$TARGET_INSTRUCTIONS_DIR = Join-Path $TargetProjectPath ".claude\instructions"
$TARGET_GITHUB_WORKFLOW = Join-Path $TARGET_INSTRUCTIONS_DIR "github-workflow.md"
$TARGET_GITHUB_DIR = Join-Path $TargetProjectPath ".github"

Write-ColorOutput "소스 프로젝트: $SOURCE_PROJECT_DIR" "Cyan"
Write-ColorOutput "타겟 프로젝트: $TargetProjectPath" "Cyan"
Write-Host ""

# 소스 파일 확인
if (-not (Test-Path $SOURCE_GITHUB_WORKFLOW)) {
    Write-ColorOutput "❌ 소스 프로젝트에 github-workflow.md가 없습니다. AI-driven-work 프로젝트에서 실행하세요." "Red"
    exit 1
}

# GitHub username 입력받기
$GITHUB_USERNAME = ""
if (-not $DryRun) {
    Write-ColorOutput "📝 GitHub 설정 정보 입력" "Yellow"
    Write-Host ""
    $GITHUB_USERNAME = Read-Host "GitHub Username (예: popup-kay)"

    if ([string]::IsNullOrWhiteSpace($GITHUB_USERNAME)) {
        Write-ColorOutput "❌ GitHub username을 입력해주세요." "Red"
        exit 1
    }

    Write-Host ""
}

# 백업 디렉토리 생성
$BACKUP_DIR = ""
if (-not $DryRun) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $BACKUP_DIR = Join-Path $TargetProjectPath ".claude\.backup-$timestamp"
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
    Write-ColorOutput "📦 백업 디렉토리 생성: $BACKUP_DIR" "Green"
    Write-Host ""
}

# ============================================================
# 헬퍼 함수
# ============================================================

function Backup-File {
    param([string]$FilePath)

    if (-not (Test-Path $FilePath)) {
        return
    }

    if ($DryRun) {
        Write-ColorOutput "  [DRY-RUN] 백업 생성: $FilePath" "Cyan"
        return
    }

    $fileName = Split-Path $FilePath -Leaf
    $backupFile = Join-Path $BACKUP_DIR "$fileName.backup"
    Copy-Item $FilePath $backupFile
    Write-Host "  💾 백업 생성: $fileName"
}

function Copy-FileWithConflictHandling {
    param(
        [string]$SourceFile,
        [string]$TargetFile
    )

    if (-not (Test-Path $SourceFile)) {
        Write-ColorOutput "  ⚠️  소스 파일이 존재하지 않습니다: $(Split-Path $SourceFile -Leaf)" "Yellow"
        return $false
    }

    # 타겟 파일이 이미 존재하는 경우
    if (Test-Path $TargetFile) {
        Write-ColorOutput "  ⚠️  $(Split-Path $TargetFile -Leaf) 이미 존재합니다." "Yellow"

        if ($DryRun) {
            Write-ColorOutput "  [DRY-RUN] 사용자에게 선택을 물어볼 예정" "Cyan"
            return $true
        }

        Write-Host "     (o)덮어쓰기 / (s)건너뛰기 / (r)이름변경 / (d)차이점 보기" -ForegroundColor Cyan
        $choice = Read-Host "     선택"

        switch ($choice.ToLower()) {
            "o" {
                Backup-File $TargetFile
                Copy-Item $SourceFile $TargetFile -Force
                Write-ColorOutput "  ✅ $(Split-Path $TargetFile -Leaf) 덮어쓰기 완료" "Green"
                return $true
            }
            "s" {
                Write-ColorOutput "  ⏭️  $(Split-Path $TargetFile -Leaf) 건너뜀" "Blue"
                return $true
            }
            "r" {
                $newName = Read-Host "     새 파일명 (확장자 제외)"
                $extension = [System.IO.Path]::GetExtension($TargetFile)
                $directory = Split-Path $TargetFile
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension($TargetFile)
                $newTarget = Join-Path $directory "$baseName-$newName$extension"
                Copy-Item $SourceFile $newTarget
                Write-ColorOutput "  ✅ $(Split-Path $newTarget -Leaf) 생성 완료" "Green"
                return $true
            }
            "d" {
                Write-Host ""
                Write-Host "==========================================" -ForegroundColor White
                Write-Host "차이점:" -ForegroundColor White
                Write-Host "==========================================" -ForegroundColor White
                Compare-Object (Get-Content $TargetFile) (Get-Content $SourceFile) | Format-Table -AutoSize
                Write-Host "==========================================" -ForegroundColor White
                Write-Host ""
                # 재귀 호출
                return Copy-FileWithConflictHandling $SourceFile $TargetFile
            }
            default {
                Write-ColorOutput "  ⏭️  잘못된 입력. 건너뜀" "Blue"
                return $true
            }
        }
    } else {
        # 타겟 파일이 없는 경우 - 그냥 복사
        if ($DryRun) {
            Write-ColorOutput "  [DRY-RUN] 복사: $(Split-Path $SourceFile -Leaf) → $(Split-Path $TargetFile -Leaf)" "Cyan"
        } else {
            Copy-Item $SourceFile $TargetFile
            Write-ColorOutput "  ✅ $(Split-Path $TargetFile -Leaf) 복사 완료" "Green"
        }
        return $true
    }
}

function New-CodeownersFile {
    param(
        [string]$TargetGitHubDir,
        [string]$GitHubUsername
    )

    $codeownersFile = Join-Path $TargetGitHubDir "CODEOWNERS"

    if (Test-Path $codeownersFile) {
        Write-ColorOutput "  ⚠️  CODEOWNERS 파일이 이미 존재합니다." "Yellow"

        if ($DryRun) {
            Write-ColorOutput "  [DRY-RUN] 사용자에게 선택을 물어볼 예정" "Cyan"
            return
        }

        Write-Host "     (o)덮어쓰기 / (s)건너뛰기 / (a)소유자 추가" -ForegroundColor Cyan
        $choice = Read-Host "     선택"

        switch ($choice.ToLower()) {
            "o" {
                Backup-File $codeownersFile
                $content = @"
# CODEOWNERS
# 모든 파일의 기본 소유자

* @$GitHubUsername

# 특정 디렉토리 소유자 (필요 시 수정)
/scripts/ @$GitHubUsername
/.claude/ @$GitHubUsername
/docs/ @$GitHubUsername
"@
                Set-Content -Path $codeownersFile -Value $content -Encoding UTF8
                Write-ColorOutput "  ✅ CODEOWNERS 덮어쓰기 완료" "Green"
            }
            "s" {
                Write-ColorOutput "  ⏭️  CODEOWNERS 건너뜀" "Blue"
            }
            "a" {
                Backup-File $codeownersFile
                $content = Get-Content $codeownersFile -Raw
                if ($content -notmatch "@$GitHubUsername") {
                    $addition = "`n`n# Added by github-workflow-setup.ps1`n* @$GitHubUsername`n"
                    Add-Content -Path $codeownersFile -Value $addition -Encoding UTF8
                    Write-ColorOutput "  ✅ CODEOWNERS에 @$GitHubUsername 추가 완료" "Green"
                } else {
                    Write-ColorOutput "  ℹ️  @$GitHubUsername는 이미 CODEOWNERS에 있습니다" "Blue"
                }
            }
            default {
                Write-ColorOutput "  ⏭️  잘못된 입력. 건너뜀" "Blue"
            }
        }
    } else {
        if ($DryRun) {
            Write-ColorOutput "  [DRY-RUN] CODEOWNERS 생성 예정" "Cyan"
        } else {
            $content = @"
# CODEOWNERS
# 모든 파일의 기본 소유자

* @$GitHubUsername

# 특정 디렉토리 소유자 (필요 시 수정)
/scripts/ @$GitHubUsername
/.claude/ @$GitHubUsername
/docs/ @$GitHubUsername
"@
            Set-Content -Path $codeownersFile -Value $content -Encoding UTF8
            Write-ColorOutput "  ✅ CODEOWNERS 생성 완료" "Green"
        }
    }
}

function New-IssueTemplates {
    param(
        [string]$TargetGitHubDir,
        [string]$GitHubUsername
    )

    $templateDir = Join-Path $TargetGitHubDir "ISSUE_TEMPLATE"

    if ($DryRun) {
        Write-ColorOutput "  [DRY-RUN] Issue 템플릿 디렉토리 생성 예정" "Cyan"
    } else {
        if (-not (Test-Path $templateDir)) {
            New-Item -ItemType Directory -Path $templateDir -Force | Out-Null
        }
        Write-ColorOutput "  ✅ Issue 템플릿 디렉토리 생성" "Green"
    }

    # Bug Report 템플릿
    $bugReportFile = Join-Path $templateDir "bug_report.md"
    if (Test-Path $bugReportFile) {
        Write-ColorOutput "  ℹ️  bug_report.md 이미 존재 - 건너뜀" "Blue"
    } else {
        if ($DryRun) {
            Write-ColorOutput "  [DRY-RUN] bug_report.md 생성 예정" "Cyan"
        } else {
            $content = @"
---
name: Bug Report
about: 버그 리포트
title: '[BUG] '
labels: bug
assignees: $GitHubUsername
---

## 버그 설명
<!-- 버그에 대한 명확하고 간결한 설명 -->

## 재현 방법
1. '...'로 이동
2. '...' 클릭
3. '...' 스크롤
4. 에러 발생

## 예상 동작
<!-- 예상했던 정상 동작 설명 -->

## 실제 동작
<!-- 실제로 발생한 동작 설명 -->

## 환경
- OS: [예: Windows 11]
- Shell: [예: PowerShell 7.4]
- Node.js: [예: v20.10.0]

## 추가 정보
<!-- 스크린샷, 에러 로그 등 -->
"@
            Set-Content -Path $bugReportFile -Value $content -Encoding UTF8
            Write-ColorOutput "  ✅ bug_report.md 생성 완료" "Green"
        }
    }

    # Feature Request 템플릿
    $featureRequestFile = Join-Path $templateDir "feature_request.md"
    if (Test-Path $featureRequestFile) {
        Write-ColorOutput "  ℹ️  feature_request.md 이미 존재 - 건너뜀" "Blue"
    } else {
        if ($DryRun) {
            Write-ColorOutput "  [DRY-RUN] feature_request.md 생성 예정" "Cyan"
        } else {
            $content = @"
---
name: Feature Request
about: 새로운 기능 제안
title: '[FEATURE] '
labels: enhancement
assignees: $GitHubUsername
---

## 기능 설명
<!-- 제안하는 기능에 대한 명확한 설명 -->

## 문제 또는 필요성
<!-- 이 기능이 왜 필요한지 설명 -->

## 제안하는 해결 방법
<!-- 어떻게 구현되면 좋을지 설명 -->

## 대안
<!-- 고려한 다른 방법이 있다면 설명 -->

## 추가 정보
<!-- 참고 자료, 링크 등 -->
"@
            Set-Content -Path $featureRequestFile -Value $content -Encoding UTF8
            Write-ColorOutput "  ✅ feature_request.md 생성 완료" "Green"
        }
    }
}

function Add-GitHubWorkflowReference {
    param([string]$InstructionFile)

    $relativePath = ".claude\instructions\github-workflow.md"

    # 이미 참조가 있는지 확인
    if (Test-Path $InstructionFile) {
        $content = Get-Content $InstructionFile -Raw
        if ($content -match "github-workflow\.md") {
            Write-ColorOutput "  ℹ️  $(Split-Path $InstructionFile -Leaf): 이미 github-workflow.md 참조 존재" "Blue"
            return
        }
    }

    if ($DryRun) {
        Write-ColorOutput "  [DRY-RUN] 참조 추가 예정: $(Split-Path $InstructionFile -Leaf)" "Cyan"
        return
    }

    # 백업 생성
    Backup-File $InstructionFile

    # 파일 시작 부분에 참조 추가
    $reference = @"
---

> **🔀 GitHub Workflow**: This project follows standardized branch and PR workflows.
> See: ``$relativePath``

---


"@

    $originalContent = Get-Content $InstructionFile -Raw -ErrorAction SilentlyContinue
    $newContent = $reference + $originalContent
    Set-Content -Path $InstructionFile -Value $newContent -Encoding UTF8

    Write-ColorOutput "  ✅ $(Split-Path $InstructionFile -Leaf): github-workflow.md 참조 추가 완료" "Green"
}

# ============================================================
# 1단계: GitHub Workflow 지침 복사
# ============================================================
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "[1/4] GitHub Workflow 지침 복사" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# 타겟 instructions 디렉토리 생성
if ($DryRun) {
    Write-ColorOutput "[DRY-RUN] 디렉토리 생성: $TARGET_INSTRUCTIONS_DIR" "Cyan"
} else {
    if (-not (Test-Path $TARGET_INSTRUCTIONS_DIR)) {
        New-Item -ItemType Directory -Path $TARGET_INSTRUCTIONS_DIR -Force | Out-Null
    }
    Write-ColorOutput "✅ 디렉토리 생성: $TARGET_INSTRUCTIONS_DIR" "Green"
}
Write-Host ""

# github-workflow.md 복사
Copy-FileWithConflictHandling $SOURCE_GITHUB_WORKFLOW $TARGET_GITHUB_WORKFLOW | Out-Null

Write-Host ""

# ============================================================
# 2단계: .github 디렉토리 설정
# ============================================================
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "[2/4] GitHub 설정 파일 생성" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# .github 디렉토리 생성
if ($DryRun) {
    Write-ColorOutput "[DRY-RUN] 디렉토리 생성: $TARGET_GITHUB_DIR" "Cyan"
} else {
    if (-not (Test-Path $TARGET_GITHUB_DIR)) {
        New-Item -ItemType Directory -Path $TARGET_GITHUB_DIR -Force | Out-Null
    }
    Write-ColorOutput "✅ 디렉토리 생성: $TARGET_GITHUB_DIR" "Green"
}
Write-Host ""

# CODEOWNERS 생성
if (-not $DryRun) {
    New-CodeownersFile $TARGET_GITHUB_DIR $GITHUB_USERNAME
}

Write-Host ""

# Issue 템플릿 생성
if (-not $DryRun) {
    New-IssueTemplates $TARGET_GITHUB_DIR $GITHUB_USERNAME
}

Write-Host ""

# ============================================================
# 3단계: 기존 instructions 파일에 참조 추가
# ============================================================
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "[3/4] 기존 Instructions 파일 확인" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# 타겟에 있는 다른 instruction 파일들 찾기
if (Test-Path $TARGET_INSTRUCTIONS_DIR) {
    $otherInstructions = Get-ChildItem -Path $TARGET_INSTRUCTIONS_DIR -Filter "*.md" |
                         Where-Object { $_.Name -ne "github-workflow.md" }

    if ($otherInstructions.Count -eq 0) {
        Write-ColorOutput "ℹ️  다른 instruction 파일이 없습니다." "Blue"
    } else {
        Write-ColorOutput "발견된 instruction 파일: $($otherInstructions.Count)개" "Cyan"
        Write-Host ""

        foreach ($instFile in $otherInstructions) {
            Write-Host "  📄 $($instFile.Name)"
            Add-GitHubWorkflowReference $instFile.FullName
        }
    }
} else {
    Write-ColorOutput "ℹ️  instructions 디렉토리가 없습니다." "Blue"
}

Write-Host ""

# ============================================================
# 4단계: 완료 메시지
# ============================================================
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✨ [4/4] 설정 완료! ✨" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

if ($DryRun) {
    Write-ColorOutput "🔍 DRY-RUN 모드였습니다. 실제 변경은 이루어지지 않았습니다." "Cyan"
    Write-Host ""
    Write-Host "실제로 적용하려면 -DryRun 옵션 없이 다시 실행하세요:"
    Write-ColorOutput "  .\scripts\github-workflow-setup.ps1 $TargetProjectPath" "Yellow"
} else {
    Write-ColorOutput "📝 다음 단계:" "Yellow"
    Write-Host ""
    Write-Host "1. GitHub 저장소 설정:"
    Write-ColorOutput "   https://github.com/<your-org>/<your-repo>/settings/branches" "Cyan"
    Write-Host ""
    Write-Host "   Branch Protection Rules 적용:"
    Write-Host "   - main 브랜치: PR 필수, @$GITHUB_USERNAME 승인 필수"
    Write-Host "   - develop 브랜치: PR 필수, @$GITHUB_USERNAME 승인 필수"
    Write-Host ""
    Write-Host "2. CODEOWNERS 파일 커밋:"
    Write-ColorOutput "   git add .github/CODEOWNERS" "Cyan"
    Write-ColorOutput "   git commit -m `"chore: Add CODEOWNERS file`"" "Cyan"
    Write-Host ""
    Write-Host "3. Issue 템플릿 커밋:"
    Write-ColorOutput "   git add .github/ISSUE_TEMPLATE/" "Cyan"
    Write-ColorOutput "   git commit -m `"chore: Add issue templates`"" "Cyan"
    Write-Host ""
    Write-Host "4. GitHub Workflow 지침 커밋:"
    Write-ColorOutput "   git add .claude/instructions/github-workflow.md" "Cyan"
    Write-ColorOutput "   git commit -m `"docs: Add GitHub workflow guidelines`"" "Cyan"
    Write-Host ""
    Write-Host "5. Claude Code로 확인:"
    Write-ColorOutput "   cd $TargetProjectPath" "Cyan"
    Write-ColorOutput "   claude" "Cyan"
    Write-ColorOutput "   > GitHub 워크플로우 규칙 알려줘" "Cyan"
    Write-Host ""

    if ($BACKUP_DIR) {
        Write-ColorOutput "💾 백업 위치:" "Yellow"
        Write-Host "   $BACKUP_DIR"
        Write-Host ""
        Write-ColorOutput "⚠️  문제가 발생한 경우 백업에서 복구할 수 있습니다." "Yellow"
        Write-Host ""
    }
}

Write-Host "==========================================" -ForegroundColor Green
Write-Host "🎉 완료! 즐거운 작업 되세요! 🎉" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
