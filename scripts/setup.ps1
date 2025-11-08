# POPUP STUDIO AI-Driven Work 환경 설정 스크립트 (Windows PowerShell)
# Claude Code와 Atlassian MCP Server를 설정합니다.

# 에러 발생 시 중단
$ErrorActionPreference = "Stop"

# 색상 정의 (PowerShell)
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "🚀 POPUP STUDIO AI-Driven Work" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""
Write-Host "이 스크립트는 Claude Code와 Atlassian MCP Server를 설정합니다."
Write-Host ""

# 직군 확인 (권장 사항 제시용)
Write-ColorOutput "📋 먼저 몇 가지 질문에 답해주세요:" "Cyan"
Write-Host ""
Write-Host "1. 개발자 (백엔드/프론트엔드/DevOps/QA)"
Write-Host "2. 비개발자 (기획/디자인/마케팅/운영)"
Write-Host ""
$JOB_TYPE = Read-Host "직군을 선택하세요 (1 또는 2)"
Write-Host ""

# ============================================================
# 1단계: Node.js 확인
# ============================================================
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "📦 1단계: Node.js 확인" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# Node.js 설치 확인
try {
    $nodeVersion = node --version
    $versionNumber = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')

    if ($versionNumber -lt 18) {
        Write-ColorOutput "❌ Node.js 버전이 18 미만입니다. (현재: $nodeVersion)" "Red"
        Write-Host "Node.js 18 이상을 설치해주세요."
        Write-Host "  https://nodejs.org/"
        Write-Host ""
        exit 1
    }

    Write-ColorOutput "✅ Node.js $nodeVersion 확인됨" "Green"
} catch {
    Write-ColorOutput "❌ Node.js가 설치되어 있지 않습니다." "Red"
    Write-Host ""
    Write-Host "Node.js를 설치해주세요:"
    Write-Host "  https://nodejs.org/"
    Write-Host ""
    exit 1
}
Write-Host ""

# ============================================================
# 2단계: Claude Code 설치
# ============================================================
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "🤖 2단계: Claude Code 설치" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# Claude Code 설치 확인
try {
    $claudeVersion = claude --version 2>$null
    Write-ColorOutput "✅ Claude Code 설치 확인됨" "Green"
} catch {
    Write-ColorOutput "⚠️  Claude Code가 설치되어 있지 않습니다." "Yellow"
    Write-Host ""
    $installClaude = Read-Host "Claude Code를 설치하시겠습니까? (y/n)"

    if ($installClaude -match '^[yY]') {
        Write-Host ""
        Write-Host "Claude Code 설치 중..."
        try {
            npm install -g @anthropic-ai/claude-code
            Write-Host ""
            Write-ColorOutput "✅ Claude Code 설치 완료" "Green"
        } catch {
            Write-ColorOutput "❌ Claude Code 설치 실패" "Red"
            Write-Host $_.Exception.Message
            exit 1
        }
    } else {
        Write-Host ""
        Write-ColorOutput "❌ Claude Code는 필수입니다. 설치를 취소합니다." "Red"
        exit 1
    }
}
Write-Host ""

# ============================================================
# 3단계: Claude Code 설정 디렉토리 생성
# ============================================================
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "📁 3단계: 설정 디렉토리 생성" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# Windows에서 Claude Config 디렉토리 경로
$CLAUDE_CONFIG_DIR = Join-Path $env:USERPROFILE ".config\claude"
$CLAUDE_MCP_DIR = $CLAUDE_CONFIG_DIR

# 디렉토리 생성
if (-not (Test-Path $CLAUDE_CONFIG_DIR)) {
    New-Item -ItemType Directory -Path $CLAUDE_CONFIG_DIR -Force | Out-Null
}
if (-not (Test-Path $CLAUDE_MCP_DIR)) {
    New-Item -ItemType Directory -Path $CLAUDE_MCP_DIR -Force | Out-Null
}

Write-ColorOutput "✅ 설정 디렉토리 생성 완료" "Green"
Write-Host "   $CLAUDE_CONFIG_DIR"
Write-Host "   $CLAUDE_MCP_DIR"
Write-Host ""

# ============================================================
# 4단계: Slash Commands 복사
# ============================================================
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "⚡ 4단계: Slash Commands 복사" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

$CLAUDE_COMMANDS_DIR = Join-Path $CLAUDE_CONFIG_DIR ".claude\commands"
if (-not (Test-Path $CLAUDE_COMMANDS_DIR)) {
    New-Item -ItemType Directory -Path $CLAUDE_COMMANDS_DIR -Force | Out-Null
}

# 스크립트 디렉토리 경로
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$PROJECT_DIR = Split-Path -Parent $SCRIPT_DIR
$SOURCE_COMMANDS_DIR = Join-Path $PROJECT_DIR ".claude\commands"

if (Test-Path $SOURCE_COMMANDS_DIR) {
    Copy-Item -Path "$SOURCE_COMMANDS_DIR\*" -Destination $CLAUDE_COMMANDS_DIR -Recurse -Force
    Write-ColorOutput "✅ Slash commands 복사 완료" "Green"
    Write-Host "   - /daily-standup"
    Write-Host "   - /weekly-report"
    Write-Host "   - /assign-me"
    Write-Host "   - /save-slack-thread"
} else {
    Write-ColorOutput "⚠️  Slash commands 디렉토리를 찾을 수 없습니다." "Yellow"
}
Write-Host ""

# ============================================================
# 5단계: MCP Server 선택
# ============================================================
Write-Host "==========================================" -ForegroundColor Blue
Write-Host "🔧 5단계: MCP Server 선택" -ForegroundColor Blue
Write-Host "==========================================" -ForegroundColor Blue
Write-Host ""

# 직군별 권장 사항 표시
if ($JOB_TYPE -eq "1") {
    Write-ColorOutput "💡 개발자에게 권장: mcp-atlassian" "Cyan"
    Write-Host "   - 16개 전체 도구"
    Write-Host "   - 사용량 무제한"
    Write-Host "   - 완전한 제어"
    Write-Host "   - CI/CD 통합 가능"
    Write-Host ""
} else {
    Write-ColorOutput "💡 비개발자에게 권장: Rovo MCP Server" "Cyan"
    Write-Host "   - 설정이 매우 간단 (2분)"
    Write-Host "   - OAuth 인증"
    Write-Host "   - 자동 업데이트"
    Write-Host ""
}

Write-Host "사용할 MCP Server를 선택하세요:"
Write-Host ""
Write-Host "1. Rovo MCP Server (클라우드 기반, 간편 설정)"
Write-Host "   - 설정 시간: 2분"
Write-Host "   - 인증: OAuth (브라우저 클릭)"
Write-Host "   - 비용: 무료 (베타)"
Write-Host "   - 권장: 비개발자, 일반 업무"
Write-Host ""
Write-Host "2. mcp-atlassian (로컬 Docker 기반, 고급 기능)"
Write-Host "   - 설정 시간: 15분"
Write-Host "   - 인증: API 토큰"
Write-Host "   - 비용: 무료 (영구)"
Write-Host "   - 권장: 개발자, 대량 작업, CI/CD"
Write-Host ""
$MCP_CHOICE = Read-Host "선택하세요 (1 또는 2)"
Write-Host ""

# ============================================================
# 6단계: 선택한 MCP Server 설정
# ============================================================

if ($MCP_CHOICE -eq "1") {
    # ========================================================
    # Rovo MCP Server 설정
    # ========================================================
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host "🌐 Rovo MCP Server 설정" -ForegroundColor Blue
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host ""

    Write-Host "Rovo MCP Server를 설정합니다..."
    Write-Host ""

    Write-ColorOutput "다음 명령어를 실행합니다:" "Cyan"
    Write-Host "  claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse"
    Write-Host ""

    # claude mcp add 명령어 실행
    try {
        claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
        Write-Host ""
        Write-ColorOutput "✅ Rovo MCP Server 설정 완료" "Green"
        Write-Host ""
        Write-ColorOutput "브라우저가 열리면 Atlassian 계정으로 로그인해주세요." "Cyan"
        Write-Host ""
    } catch {
        Write-Host ""
        Write-ColorOutput "❌ Rovo MCP Server 설정 실패" "Red"
        Write-Host $_.Exception.Message
        Write-Host ""
        Write-Host "수동으로 설정하려면 다음 명령어를 실행하세요:"
        Write-Host "  claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse"
        Write-Host ""
    }

} elseif ($MCP_CHOICE -eq "2") {
    # ========================================================
    # mcp-atlassian 설정
    # ========================================================
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host "🐳 mcp-atlassian 설정" -ForegroundColor Blue
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host ""

    # Docker 설치 확인
    Write-ColorOutput "Docker 설치를 확인합니다..." "Cyan"
    try {
        $dockerVersion = docker --version
        Write-ColorOutput "✅ Docker 설치 확인됨: $dockerVersion" "Green"
    } catch {
        Write-ColorOutput "❌ Docker가 설치되어 있지 않습니다." "Red"
        Write-Host ""
        Write-Host "Docker Desktop을 설치해주세요:"
        Write-Host "  https://www.docker.com/products/docker-desktop/"
        Write-Host ""
        Write-Host "Docker 설치 후 이 스크립트를 다시 실행하세요."
        Write-Host ""
        exit 1
    }
    Write-Host ""

    # 기존 설정 확인
    $MCP_ATLASSIAN_DIR = Join-Path $env:USERPROFILE ".mcp-atlassian"
    $ENV_FILE = Join-Path $MCP_ATLASSIAN_DIR ".env"

    if (Test-Path $ENV_FILE) {
        Write-ColorOutput "✅ 기존 mcp-atlassian 설정을 발견했습니다." "Green"
        Write-Host ""
        $reuseConfig = Read-Host "기존 설정을 재사용하시겠습니까? (y/n)"

        if ($reuseConfig -match '^[yY]') {
            Write-Host ""
            Write-ColorOutput "기존 설정을 사용합니다." "Cyan"
            $REUSE_CONFIG = $true
        } else {
            $REUSE_CONFIG = $false
        }
    } else {
        $REUSE_CONFIG = $false
    }

    if (-not $REUSE_CONFIG) {
        Write-Host ""
        Write-ColorOutput "Atlassian API 토큰이 필요합니다." "Cyan"
        Write-Host ""
        Write-Host "API 토큰 생성 방법:"
        Write-Host "  1. https://id.atlassian.com/manage-profile/security/api-tokens 방문"
        Write-Host "  2. 'Create API token' 클릭"
        Write-Host "  3. 토큰 이름 입력 (예: claude-code)"
        Write-Host "  4. 생성된 토큰 복사"
        Write-Host ""

        $JIRA_URL = Read-Host "Jira URL을 입력하세요 (예: https://your-domain.atlassian.net)"
        $JIRA_EMAIL = Read-Host "Atlassian 계정 이메일을 입력하세요"
        $JIRA_API_TOKEN = Read-Host "API 토큰을 입력하세요" -AsSecureString
        $JIRA_API_TOKEN_PLAIN = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($JIRA_API_TOKEN))

        Write-Host ""

        # .mcp-atlassian 디렉토리 생성
        if (-not (Test-Path $MCP_ATLASSIAN_DIR)) {
            New-Item -ItemType Directory -Path $MCP_ATLASSIAN_DIR -Force | Out-Null
        }

        # .env 파일 생성
        $envContent = @"
JIRA_URL=$JIRA_URL
JIRA_EMAIL=$JIRA_EMAIL
JIRA_API_TOKEN=$JIRA_API_TOKEN_PLAIN
"@
        Set-Content -Path $ENV_FILE -Value $envContent -Encoding UTF8

        Write-ColorOutput "✅ .env 파일 생성 완료: $ENV_FILE" "Green"
        Write-Host ""
    }

    # Claude Code MCP 등록
    Write-Host ""
    Write-ColorOutput "Claude Code에 mcp-atlassian을 등록합니다..." "Cyan"
    Write-Host ""

    Write-Host "사용 범위를 선택하세요:"
    Write-Host "  1. 모든 프로젝트에서 사용 (전역 설정)"
    Write-Host "  2. 현재 프로젝트에서만 사용 (로컬 설정)"
    Write-Host ""
    $scopeChoice = Read-Host "선택하세요 (1 또는 2)"

    $mcpAddCommand = "claude mcp add --transport docker-compose mcp-atlassian `"$MCP_ATLASSIAN_DIR\docker-compose.yml`""

    if ($scopeChoice -eq "1") {
        Write-Host ""
        Write-ColorOutput "전역 설정으로 등록합니다..." "Cyan"
        try {
            Invoke-Expression $mcpAddCommand
            Write-ColorOutput "✅ mcp-atlassian 전역 등록 완료" "Green"
        } catch {
            Write-ColorOutput "❌ 등록 실패" "Red"
            Write-Host $_.Exception.Message
        }
    } else {
        Write-Host ""
        Write-ColorOutput "로컬 설정으로 등록합니다..." "Cyan"
        try {
            Invoke-Expression "$mcpAddCommand --local"
            Write-ColorOutput "✅ mcp-atlassian 로컬 등록 완료" "Green"
        } catch {
            Write-ColorOutput "❌ 등록 실패" "Red"
            Write-Host $_.Exception.Message
        }
    }

    Write-Host ""
    Write-ColorOutput "연결을 테스트합니다..." "Cyan"
    Write-Host ""
    Write-Host "Claude Code를 실행하고 다음을 시도해보세요:"
    Write-Host "  > Jira 프로젝트 목록 보여줘"
    Write-Host ""

} else {
    Write-ColorOutput "❌ 잘못된 선택입니다." "Red"
    exit 1
}

# ============================================================
# 완료
# ============================================================
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✨ 설정 완료! ✨" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

Write-ColorOutput "다음 단계:" "Yellow"
Write-Host ""
Write-Host "1. PowerShell 또는 터미널에서 Claude Code 실행:"
Write-Host "   claude"
Write-Host ""
Write-Host "2. 연결 테스트:"
Write-Host "   > Jira 프로젝트 목록 보여줘"
Write-Host ""
Write-Host "3. 첫 slash command 실행:"
Write-Host "   > /daily-standup"
Write-Host ""
Write-Host "4. 문서 참고:"
Write-Host "   - README.md: 프로젝트 개요"
Write-Host "   - docs/claude-code-guide.md: 사용 가이드"
Write-Host "   - docs/jira-guidelines.md: Jira 규칙"
Write-Host ""

Write-Host "==========================================" -ForegroundColor Green
Write-Host "🎉 즐거운 작업 되세요! 🎉" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
