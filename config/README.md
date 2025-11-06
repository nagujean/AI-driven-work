# Configuration 설정 가이드

이 폴더에는 mcp-atlassian (sooperset) 설정 파일과 예시가 포함되어 있습니다.

## 파일 설명

- **mcp-atlassian-config.json**: Claude Code MCP 설정 파일 템플릿
- **.env.example**: 환경 변수 설정 예시 파일

## 자동 설정 (권장)

가장 쉬운 방법은 setup.sh 스크립트를 사용하는 것입니다:

```bash
cd AI-driven-work
./scripts/setup.sh
```

스크립트가 자동으로:
1. Claude Code 설치
2. MCP Server 선택 (Rovo 또는 mcp-atlassian)
3. 필요한 설정 파일 생성
4. 권한 설정

## 수동 설정 (mcp-atlassian)

자동 스크립트를 사용하지 않는 경우 다음 단계를 따르세요.

### 사전 준비

#### 1. Docker 설치 확인

```bash
docker --version
# Docker version 20.10.0 이상이어야 합니다
```

Docker가 없으면 설치:
- **Mac**: https://docs.docker.com/desktop/install/mac-install/
- **Windows**: https://docs.docker.com/desktop/install/windows-install/

#### 2. Docker 이미지 다운로드

```bash
docker pull ghcr.io/sooperset/mcp-atlassian:latest
```

#### 3. Atlassian API 토큰 발급

1. https://id.atlassian.com/manage-profile/security/api-tokens 접속
2. "Create API token" 클릭
3. 토큰 이름 입력 (예: "MCP-ATLASSIAN")
4. 생성된 토큰 복사 (다시 볼 수 없으니 안전하게 보관)

### 설정 단계

#### 1단계: 환경 변수 파일 생성

**디렉토리 생성**:
```bash
mkdir -p ~/.mcp-atlassian
```

**환경 변수 파일 생성**:
```bash
# 템플릿 복사
cp config/.env.example ~/.mcp-atlassian/.env

# 에디터로 열기
nano ~/.mcp-atlassian/.env
# 또는
code ~/.mcp-atlassian/.env
```

**필수 값 입력**:

```bash
# Confluence 설정
CONFLUENCE_URL=https://popupstudio.atlassian.net/wiki
CONFLUENCE_USERNAME=your.email@popupstudio.com
CONFLUENCE_API_TOKEN=발급받은_API_토큰

# Jira 설정
JIRA_URL=https://popupstudio.atlassian.net
JIRA_USERNAME=your.email@popupstudio.com
JIRA_API_TOKEN=발급받은_API_토큰
```

**선택적 설정** (필요한 경우 주석 제거):

```bash
# 특정 프로젝트만 접근
JIRA_PROJECTS_FILTER=PROJ,DEV,INFRA

# 특정 스페이스만 접근
CONFLUENCE_SPACES_FILTER=POPUP,DEV,TECH

# 읽기 전용 모드 (안전)
READ_ONLY_MODE=true
```

**파일 권한 설정** (보안):
```bash
chmod 600 ~/.mcp-atlassian/.env
```

#### 2단계: Claude Code 설정 파일 생성

**디렉토리 생성**:
```bash
mkdir -p ~/.config/claude/mcp
```

**설정 파일 생성**:
```bash
# 템플릿 복사
cp config/mcp-atlassian-config.json ~/.config/claude/mcp/claude_desktop_config.json
```

또는 직접 생성:

```bash
cat > ~/.config/claude/mcp/claude_desktop_config.json <<'EOF'
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "--env-file",
        "${HOME}/.mcp-atlassian/.env",
        "ghcr.io/sooperset/mcp-atlassian:latest"
      ]
    }
  }
}
EOF
```

**파일 권한 설정**:
```bash
chmod 600 ~/.config/claude/mcp/claude_desktop_config.json
```

#### 3단계: Claude Code 재시작

```bash
# Claude Code 실행
claude
```

### 설정 확인

Claude Code에서 다음 명령으로 연결 테스트:

```
Jira에서 사용 가능한 프로젝트 보여줘
```

정상 작동하면:
```
PROJ, DEV, INFRA 프로젝트를 찾았습니다.
```

## 두 가지 설정 방식 비교

### 방식 1: 환경 파일 (권장) ⭐

**장점**:
- ✅ 보안 강화 (토큰이 JSON 파일에 노출 안됨)
- ✅ 쉬운 관리 (.env 파일 하나만 수정)
- ✅ 권한 분리 (600 권한)

**파일 구조**:
```
~/.mcp-atlassian/.env          # 환경 변수 (토큰 포함)
~/.config/claude/mcp/claude_desktop_config.json  # MCP 설정
```

### 방식 2: 직접 전달

**장점**:
- ✅ 단일 파일 관리
- ✅ 설정 한눈에 파악

**단점**:
- ❌ 보안 취약 (토큰이 JSON에 노출)
- ❌ Git 커밋 시 실수 위험

**설정 예시**:
```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "CONFLUENCE_URL",
        "-e", "CONFLUENCE_USERNAME",
        "-e", "CONFLUENCE_API_TOKEN",
        "-e", "JIRA_URL",
        "-e", "JIRA_USERNAME",
        "-e", "JIRA_API_TOKEN",
        "ghcr.io/sooperset/mcp-atlassian:latest"
      ],
      "env": {
        "CONFLUENCE_URL": "https://popupstudio.atlassian.net/wiki",
        "CONFLUENCE_USERNAME": "your.email@popupstudio.com",
        "CONFLUENCE_API_TOKEN": "your_token",
        "JIRA_URL": "https://popupstudio.atlassian.net",
        "JIRA_USERNAME": "your.email@popupstudio.com",
        "JIRA_API_TOKEN": "your_token"
      }
    }
  }
}
```

**⚠️ 권장하지 않음**: 보안상 환경 파일 방식을 사용하세요.

## 고급 설정

### 프로젝트/스페이스 필터링

특정 프로젝트나 스페이스만 접근하도록 제한:

`~/.mcp-atlassian/.env`:
```bash
# 개발 관련만
JIRA_PROJECTS_FILTER=PROJ,DEV,INFRA
CONFLUENCE_SPACES_FILTER=DEV,DEVOPS,TECH
```

**효과**:
- 불필요한 프로젝트 접근 차단
- 검색 성능 향상
- 권한 관리 강화

### 읽기 전용 모드

실수로 데이터를 변경하지 않도록 안전 장치:

`~/.mcp-atlassian/.env`:
```bash
READ_ONLY_MODE=true
```

**효과**:
- ✅ 조회/검색만 가능
- ❌ 생성/수정/삭제 불가

**사용 시나리오**:
- 프로덕션 데이터 조회
- 교육/데모 환경
- 안전한 분석 작업

### 도구 필터링

필요한 도구만 활성화:

`~/.mcp-atlassian/.env`:
```bash
# 읽기 전용 도구만
ENABLED_TOOLS=jira_search,jira_get_issue,confluence_search,confluence_get_page

# Jira만
ENABLED_TOOLS=jira_search,jira_get_issue,jira_create_issue,jira_update_issue

# Confluence만
ENABLED_TOOLS=confluence_search,confluence_get_page,confluence_create_page
```

### 프록시 설정

회사 프록시 환경:

`~/.mcp-atlassian/.env`:
```bash
HTTPS_PROXY=https://proxy.company.com:8443
NO_PROXY=localhost,127.0.0.1,.company.com

# Jira만 별도 프록시
JIRA_HTTPS_PROXY=https://jira-proxy.company.com:8443
```

### Server/Data Center 설정

온프레미스 Atlassian 사용:

`~/.mcp-atlassian/.env`:
```bash
# Personal Access Token 사용
CONFLUENCE_URL=https://confluence.your-company.com
CONFLUENCE_PERSONAL_TOKEN=your_pat
CONFLUENCE_SSL_VERIFY=false  # 자체 서명 인증서

JIRA_URL=https://jira.your-company.com
JIRA_PERSONAL_TOKEN=your_pat
JIRA_SSL_VERIFY=false
```

## 문제 해결

### "Cannot connect to Docker daemon"

**원인**: Docker Desktop이 실행되지 않음

**해결**:
```bash
# Mac/Windows: Docker Desktop 실행
# Linux: Docker 서비스 시작
sudo systemctl start docker
```

### "Image not found"

**원인**: Docker 이미지 미다운로드

**해결**:
```bash
docker pull ghcr.io/sooperset/mcp-atlassian:latest
```

### "401 Unauthorized"

**원인**: API 토큰 오류

**해결**:
1. API 토큰 재발급
2. `~/.mcp-atlassian/.env`에서 토큰 업데이트
3. 이메일 주소 정확성 확인
4. Claude Code 재시작

### "403 Forbidden"

**원인**: 프로젝트/스페이스 접근 권한 없음

**해결**:
1. Jira/Confluence에서 권한 확인
2. 프로젝트 키/스페이스 키 정확성 확인
3. 필터 설정 확인

### "Connection timeout"

**원인**: 네트워크 또는 프록시 문제

**해결**:
1. 인터넷 연결 확인
2. URL 정확성 확인
3. 프록시 설정 확인 (필요 시)

### "SSL verification failed"

**원인**: 자체 서명 인증서 사용 (Server/DC)

**해결**:

`~/.mcp-atlassian/.env`:
```bash
CONFLUENCE_SSL_VERIFY=false
JIRA_SSL_VERIFY=false
```

## 보안 고려사항

### API 토큰 관리

**해야 할 것** ✅:
- `.env` 파일 권한 600으로 설정
- 토큰을 안전한 곳에 백업
- 정기적으로 토큰 갱신
- 사용하지 않는 토큰 삭제

**하지 말아야 할 것** ❌:
- Git에 커밋
- 팀 채팅에 공유
- 스크린샷에 포함
- 공개 문서에 기재

### 파일 권한

```bash
# 본인만 읽기/쓰기 가능
chmod 600 ~/.mcp-atlassian/.env
chmod 600 ~/.config/claude/mcp/claude_desktop_config.json

# 확인
ls -la ~/.mcp-atlassian/.env
# -rw------- (600)
```

### 정기 감사

- 월 1회: API 토큰 검토
- 분기 1회: 필터링 설정 재검토
- 연 1회: 미사용 계정 정리

## 업데이트

### Docker 이미지 업데이트

```bash
# 최신 이미지 다운로드
docker pull ghcr.io/sooperset/mcp-atlassian:latest

# 기존 컨테이너 정리
docker system prune -f

# Claude Code 재시작
claude
```

### 설정 백업

```bash
# 환경 변수 백업
cp ~/.mcp-atlassian/.env ~/.mcp-atlassian/.env.backup

# 설정 파일 백업
cp ~/.config/claude/mcp/claude_desktop_config.json \
   ~/.config/claude/mcp/claude_desktop_config.json.backup
```

### 설정 복원

```bash
# 백업에서 복원
cp ~/.mcp-atlassian/.env.backup ~/.mcp-atlassian/.env
cp ~/.config/claude/mcp/claude_desktop_config.json.backup \
   ~/.config/claude/mcp/claude_desktop_config.json

# Claude Code 재시작
```

## 추가 리소스

### 상세 문서
- **mcp-atlassian 가이드**: `../reference/mcp-atlassian.md`
- **MCP Server 선택 가이드**: `../docs/mcp-server-selection-guide.md`
- **Claude Code 사용법**: `../docs/claude-code-guide.md`

### 외부 링크
- [mcp-atlassian GitHub](https://github.com/sooperset/mcp-atlassian)
- [Docker 설치](https://docs.docker.com/get-docker/)
- [Atlassian API 문서](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)

## 요약

### 빠른 시작 (권장)

```bash
# 1. 자동 설정 스크립트 실행
./scripts/setup.sh

# 2. mcp-atlassian 선택 (개발자)
# 3. 안내에 따라 진행
# 4. Claude Code 실행
claude
```

### 수동 설정

```bash
# 1. Docker 확인
docker --version

# 2. 이미지 다운로드
docker pull ghcr.io/sooperset/mcp-atlassian:latest

# 3. 환경 변수 파일 생성
mkdir -p ~/.mcp-atlassian
cp config/.env.example ~/.mcp-atlassian/.env
# .env 파일 편집
chmod 600 ~/.mcp-atlassian/.env

# 4. Claude Code 설정
mkdir -p ~/.config/claude/mcp
cp config/mcp-atlassian-config.json ~/.config/claude/mcp/claude_desktop_config.json
chmod 600 ~/.config/claude/mcp/claude_desktop_config.json

# 5. Claude Code 실행
claude
```

**질문이나 문제가 있으면 `../reference/mcp-atlassian.md`를 참고하세요.**
