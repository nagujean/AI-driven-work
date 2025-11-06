# mcp-atlassian (sooperset) 조사 보고서

## 개요

**mcp-atlassian**은 Confluence와 Jira를 AI 어시스턴트와 통합하는 Model Context Protocol (MCP) 서버입니다. Docker 기반으로 로컬 PC에 배포되며, Cloud와 Server/Data Center 환경을 모두 지원합니다.

**GitHub 저장소**: https://github.com/sooperset/mcp-atlassian

**개발자**: sooperset

**라이선스**: MIT

**인기도**:
- ⭐ 3.5k stars
- 🍴 724 forks
- 활발한 개발 (325+ commits)

## 주요 특징

### 1. 멀티 배포 지원
- Atlassian Cloud 완전 지원
- Server/Data Center 지원 (Confluence 6.0+, Jira 8.14+)

### 2. Docker 기반 배포
- 설치 및 업데이트 간편
- 크로스 플랫폼 호환성
- 격리된 실행 환경

### 3. 포괄적인 도구 세트
- Jira: 11개 도구
- Confluence: 5개 도구
- 읽기/쓰기 작업 모두 지원

### 4. 유연한 인증
- API Token (Cloud)
- Personal Access Token (Server/Data Center)
- OAuth 2.0 (고급 보안)

### 5. 세밀한 제어
- 읽기 전용 모드
- 프로젝트/스페이스 필터링
- 도구별 활성화/비활성화
- 프록시 지원

## 지원 제품 및 버전

| 제품 | 배포 유형 | 최소 버전 | 상태 |
|------|---------|----------|------|
| Confluence | Cloud | - | ✅ 완전 지원 |
| Confluence | Server/Data Center | 6.0+ | ✅ 지원 |
| Jira | Cloud | - | ✅ 완전 지원 |
| Jira | Server/Data Center | 8.14+ | ✅ 지원 |

## 인증 방법

### 방법 1: API Token (Cloud - 권장) ⭐

**대상**: Atlassian Cloud 사용자

**장점**:
- 간단하고 빠른 설정
- 관리 용이

**발급 방법**:
1. https://id.atlassian.com/manage-profile/security/api-tokens 접속
2. "Create API token" 클릭
3. 토큰 이름 입력 (예: "mcp-atlassian")
4. 생성된 토큰 즉시 복사 (다시 볼 수 없음)

**필수 환경 변수**:
```bash
CONFLUENCE_URL=https://your-company.atlassian.net/wiki
CONFLUENCE_USERNAME=your.email@company.com
CONFLUENCE_API_TOKEN=your_api_token

JIRA_URL=https://your-company.atlassian.net
JIRA_USERNAME=your.email@company.com
JIRA_API_TOKEN=your_api_token
```

### 방법 2: Personal Access Token (Server/Data Center)

**대상**: 온프레미스 Atlassian Server/Data Center 사용자

**발급 방법**:
1. 프로필 → Personal Access Tokens
2. Create token
3. 토큰 이름 및 만료 기간 설정
4. 생성된 토큰 복사

**필수 환경 변수**:
```bash
CONFLUENCE_URL=https://confluence.your-company.com
CONFLUENCE_PERSONAL_TOKEN=your_pat

JIRA_URL=https://jira.your-company.com
JIRA_PERSONAL_TOKEN=your_pat
```

**자체 서명 인증서 사용 시**:
```bash
CONFLUENCE_SSL_VERIFY=false
JIRA_SSL_VERIFY=false
```

### 방법 3: OAuth 2.0 (고급 보안)

**대상**: 높은 보안이 필요한 Cloud 환경

**장점**:
- 더 높은 보안
- 세밀한 권한 제어

**설정 방법**:

1. **Atlassian Developer Console에서 OAuth 앱 생성**
   - https://developer.atlassian.com/console/myapps/
   - OAuth 2.0 integration 선택
   - Callback URL: `http://localhost:8080/oauth/callback`

2. **Scope 설정**:
   - `offline_access` (필수)
   - Confluence 관련 스코프
   - Jira 관련 스코프

3. **OAuth 설정 마법사 실행**:
```bash
docker run --rm -i -p 8080:8080 \
  -v "${HOME}/.mcp-atlassian:/home/app/.mcp-atlassian" \
  ghcr.io/sooperset/mcp-atlassian:latest --oauth-setup -v
```

4. **브라우저에서 인증 완료**

**필수 정보**:
- Client ID
- Client Secret
- Redirect URI
- Scope (offline_access 포함)

## 설치

### Docker 이미지 다운로드

```bash
docker pull ghcr.io/sooperset/mcp-atlassian:latest
```

**최신 버전 확인**:
https://github.com/sooperset/mcp-atlassian/releases

## Claude Code 설정 방법

### 방법 1: 환경 변수 직접 전달 ⭐ 권장

`~/.config/claude/mcp/claude_desktop_config.json` 파일 수정:

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
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
        "CONFLUENCE_API_TOKEN": "your_confluence_api_token",
        "JIRA_URL": "https://popupstudio.atlassian.net",
        "JIRA_USERNAME": "your.email@popupstudio.com",
        "JIRA_API_TOKEN": "your_jira_api_token"
      }
    }
  }
}
```

### 방법 2: 환경 파일 사용

**1. `.env` 파일 생성**

`~/.mcp-atlassian/.env`:
```bash
CONFLUENCE_URL=https://popupstudio.atlassian.net/wiki
CONFLUENCE_USERNAME=your.email@popupstudio.com
CONFLUENCE_API_TOKEN=your_confluence_api_token

JIRA_URL=https://popupstudio.atlassian.net
JIRA_USERNAME=your.email@popupstudio.com
JIRA_API_TOKEN=your_jira_api_token
```

**2. Claude Code 설정**

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "--env-file", "/Users/your-username/.mcp-atlassian/.env",
        "ghcr.io/sooperset/mcp-atlassian:latest"
      ]
    }
  }
}
```

### 방법 3: OAuth 설정 사용

OAuth 설정 완료 후:

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v", "${HOME}/.mcp-atlassian:/home/app/.mcp-atlassian",
        "ghcr.io/sooperset/mcp-atlassian:latest"
      ]
    }
  }
}
```

## 지원하는 도구 (Tools)

### Jira 도구 (11개)

#### 이슈 관리
| 도구 이름 | 기능 | 사용 예시 |
|----------|------|----------|
| `jira_create_issue` | 새 이슈 생성 | "PROJ에 버그 이슈 생성해줘" |
| `jira_get_issue` | 이슈 상세 조회 | "PROJ-123 이슈 내용 알려줘" |
| `jira_update_issue` | 이슈 업데이트 | "PROJ-123 설명 수정해줘" |
| `jira_search` | JQL로 이슈 검색 | "지난주 생성된 버그 찾아줘" |
| `jira_change_issue_status` | 이슈 상태 변경 | "PROJ-123을 Done으로 바꿔줘" |

#### 프로젝트 관리
| 도구 이름 | 기능 | 사용 예시 |
|----------|------|----------|
| `jira_get_all_projects` | 모든 프로젝트 조회 | "사용 가능한 프로젝트 보여줘" |

#### Agile/Sprint 관리
| 도구 이름 | 기능 | 사용 예시 |
|----------|------|----------|
| `jira_get_agile_boards` | Scrum/Kanban 보드 조회 | "현재 보드 목록 보여줘" |
| `jira_get_sprints_from_board` | 보드의 스프린트 조회 | "현재 진행 중인 스프린트는?" |
| `jira_get_sprint_issues` | 스프린트의 이슈 조회 | "현재 스프린트 이슈 보여줘" |
| `jira_get_board_issues` | 보드의 이슈 조회 | "백로그 이슈 보여줘" |
| `jira_link_an_issue_to_a_specific_Epic` | 이슈를 Epic에 연결 | "PROJ-123을 Epic에 연결해줘" |

### Confluence 도구 (5개)

| 도구 이름 | 기능 | 사용 예시 |
|----------|------|----------|
| `confluence_search` | 콘텐츠 검색 | "배포 프로세스 문서 찾아줘" |
| `confluence_get_page` | 페이지 상세 조회 | "페이지 ID 12345 내용 보여줘" |
| `confluence_create_page` | 새 페이지 생성 | "회의록 페이지 만들어줘" |
| `confluence_update_page` | 페이지 업데이트 | "페이지에 섹션 추가해줘" |
| `confluence_get_comments` | 페이지 댓글 조회 | "이 페이지 댓글 보여줘" |

## 환경 변수 설정

### 필수 환경 변수

#### Confluence (Cloud - API Token)
```bash
CONFLUENCE_URL=https://your-company.atlassian.net/wiki
CONFLUENCE_USERNAME=your.email@company.com
CONFLUENCE_API_TOKEN=your_api_token
```

#### Confluence (Server/Data Center - PAT)
```bash
CONFLUENCE_URL=https://confluence.your-company.com
CONFLUENCE_PERSONAL_TOKEN=your_pat
CONFLUENCE_SSL_VERIFY=false  # 자체 서명 인증서 사용 시
```

#### Jira (Cloud - API Token)
```bash
JIRA_URL=https://your-company.atlassian.net
JIRA_USERNAME=your.email@company.com
JIRA_API_TOKEN=your_api_token
```

#### Jira (Server/Data Center - PAT)
```bash
JIRA_URL=https://jira.your-company.com
JIRA_PERSONAL_TOKEN=your_pat
JIRA_SSL_VERIFY=false  # 자체 서명 인증서 사용 시
```

### 선택적 환경 변수

#### 필터링
```bash
# Confluence 스페이스 필터 (쉼표로 구분)
CONFLUENCE_SPACES_FILTER=DEV,TEAM,PROJ

# Jira 프로젝트 필터 (쉼표로 구분)
JIRA_PROJECTS_FILTER=PROJ,DEV,DESIGN
```

#### 모드 설정
```bash
# 읽기 전용 모드 (쓰기 작업 비활성화)
READ_ONLY_MODE=true

# 상세 로깅
MCP_VERBOSE=true
```

#### 도구 활성화
```bash
# 특정 도구만 활성화 (쉼표로 구분)
ENABLED_TOOLS=jira_search,jira_get_issue,confluence_search,confluence_get_page
```

#### 프록시 설정
```bash
# HTTP/HTTPS 프록시
HTTP_PROXY=http://proxy.company.com:8080
HTTPS_PROXY=https://proxy.company.com:8443
NO_PROXY=localhost,127.0.0.1

# SOCKS 프록시
SOCKS_PROXY=socks5://proxy.company.com:1080

# 서비스별 오버라이드
JIRA_HTTPS_PROXY=https://jira-proxy.company.com:8443
CONFLUENCE_NO_PROXY=localhost,internal.company.com
```

## 사용 예시

### Jira 작업

#### 이슈 검색 및 조회
```
"지난주에 생성된 PROJ 프로젝트의 긴급 버그 보여줘"
→ jira_search 사용

"PROJ-123 이슈의 상세 내용 알려줘"
→ jira_get_issue 사용
```

#### 이슈 생성 및 업데이트
```
"PROJ 프로젝트에 '로그인 버그' 이슈 만들어줘"
→ jira_create_issue 사용

"PROJ-123 이슈에 '재현 방법' 추가해줘"
→ jira_update_issue 사용

"PROJ-123을 In Progress로 변경해줘"
→ jira_change_issue_status 사용
```

#### Agile/Sprint 관리
```
"현재 진행 중인 스프린트의 이슈들 보여줘"
→ jira_get_sprint_issues 사용

"다음 스프린트에 있는 이슈들은?"
→ jira_get_sprints_from_board + jira_get_sprint_issues 사용

"백로그에 있는 우선순위 높은 이슈 보여줘"
→ jira_get_board_issues 사용
```

### Confluence 작업

#### 문서 검색 및 조회
```
"OKR 가이드 문서를 찾아서 요약해줘"
→ confluence_search + confluence_get_page 사용

"배포 프로세스 관련 문서 찾아줘"
→ confluence_search 사용
```

#### 페이지 생성 및 업데이트
```
"'XYZ 기능 기술 설계' 페이지 만들어줘"
→ confluence_create_page 사용

"회의록 페이지에 액션 아이템 섹션 추가해줘"
→ confluence_update_page 사용
```

#### 댓글 조회
```
"이 페이지에 달린 댓글들 보여줘"
→ confluence_get_comments 사용
```

### 통합 워크플로우

#### 회의록 → Jira 이슈 생성
```
"이 회의록을 읽고 액션 아이템마다 Jira 이슈를 만들어줘"
→ confluence_get_page + jira_create_issue 사용
```

#### Jira 이슈 → Confluence 문서화
```
"PROJ-100 이슈의 내용으로 기술 문서를 Confluence에 작성해줘"
→ jira_get_issue + confluence_create_page 사용
```

#### 스프린트 보고서 자동 생성
```
"현재 스프린트의 완료된 이슈들로 Confluence에 보고서 만들어줘"
→ jira_get_sprint_issues + confluence_create_page 사용
```

## 고급 설정

### 읽기 전용 모드

안전성을 위해 쓰기 작업을 전역적으로 비활성화:

```bash
READ_ONLY_MODE=true
```

이 모드에서는:
- ✅ 조회/검색 작업 가능
- ❌ 생성/수정/삭제 작업 불가

**사용 시나리오**:
- 프로덕션 환경에서 조회만 필요한 경우
- 실수로 데이터 변경 방지
- 교육/데모 환경

### 도구 필터링

필요한 도구만 활성화하여 성능 향상 및 보안 강화:

```bash
# 읽기 전용 도구만 활성화
ENABLED_TOOLS=jira_search,jira_get_issue,confluence_search,confluence_get_page

# Jira 도구만 활성화
ENABLED_TOOLS=jira_search,jira_get_issue,jira_create_issue,jira_update_issue

# Confluence 도구만 활성화
ENABLED_TOOLS=confluence_search,confluence_get_page,confluence_create_page
```

### 프로젝트/스페이스 필터링

특정 프로젝트나 스페이스만 접근 허용:

```bash
# 개발팀 스페이스만
CONFLUENCE_SPACES_FILTER=DEV,DEVOPS

# 특정 프로젝트만
JIRA_PROJECTS_FILTER=PROJ,DESIGN

# 여러 스페이스와 프로젝트
CONFLUENCE_SPACES_FILTER=DEV,TEAM,DOCS
JIRA_PROJECTS_FILTER=PROJ,BUG,FEATURE
```

**효과**:
- 불필요한 데이터 접근 차단
- 검색 성능 향상
- 권한 관리 강화

### 프록시 환경

회사 네트워크에서 프록시 사용:

```bash
# 기본 프록시 설정
HTTPS_PROXY=https://proxy.company.com:8443
NO_PROXY=localhost,127.0.0.1,.company.com

# Jira만 별도 프록시 사용
JIRA_HTTPS_PROXY=https://jira-proxy.company.com:8443

# SOCKS 프록시
SOCKS_PROXY=socks5://proxy.company.com:1080
```

## Rovo MCP Server와 비교

### mcp-atlassian (sooperset)

#### 장점 ✅
- **완전한 제어**: 모든 설정 직접 관리
- **사용량 무제한**: API 제한만 적용
- **오프라인 가능**: 로컬 Docker 실행
- **안정적**: 검증된 오픈소스
- **무료**: MIT 라이선스, 완전 무료
- **세밀한 설정**: 필터링, 읽기 전용 모드 등
- **Server/Data Center 지원**: 온프레미스 환경 지원
- **프록시 지원**: 기업 네트워크 환경에 적합
- **도구 필터링**: 필요한 기능만 활성화

#### 단점 ⚠️
- **복잡한 설정**: Docker + API 토큰 설정 필요
- **수동 업데이트**: 직접 이미지 업데이트 필요
- **API 토큰 관리**: 로컬 저장 및 보안 관리
- **Docker 필수**: Docker 설치 및 실행 환경 필요
- **초기 러닝 커브**: 환경 변수 이해 필요

### Atlassian Rovo MCP Server

#### 장점 ✅
- **간편한 설정**: 한 줄 명령으로 설치
- **OAuth 인증**: API 토큰 관리 불필요
- **자동 업데이트**: Atlassian이 관리
- **무료 (베타)**: 현재 비용 없음

#### 단점 ⚠️
- **Cloud 전용**: Server/Data Center 미지원
- **인터넷 필수**: 클라우드 의존
- **사용량 제한**: 시간당 1,000개 요청 (Premium)
- **베타 안정성**: 재인증 이슈
- **향후 유료화 가능성**: 가격 정책 미정
- **제한된 제어**: Atlassian 정책 의존

### 비교 표

| 항목 | mcp-atlassian (sooperset) | Rovo MCP Server |
|------|--------------------------|-----------------|
| **비용** | 무료 (영구) | 무료 (베타, 향후 미정) |
| **설치** | Docker pull + 설정 | `claude mcp add` |
| **인증** | API Token / PAT / OAuth | OAuth 전용 |
| **호스팅** | 로컬 Docker | Atlassian 클라우드 |
| **업데이트** | 수동 | 자동 |
| **인터넷** | API 호출 시만 필요 | 필수 |
| **사용량** | 무제한 (API 제한만) | 시간당 1,000개 |
| **배포 지원** | Cloud + Server/DC | Cloud 전용 |
| **도구 수** | 16개 (Jira 11 + Confluence 5) | 제한적 |
| **필터링** | 스페이스/프로젝트/도구 | 제한적 |
| **읽기 전용** | 지원 | 미지원 |
| **프록시** | 지원 | 미지원 |
| **안정성** | 높음 | 베타 (재인증 이슈) |
| **팀 공유** | `.env` 파일 공유 | `.mcp.json` 공유 |

## 권장 사항

### mcp-atlassian을 권장하는 경우

#### 필수적인 경우
- ✅ **Server/Data Center 사용**: 온프레미스 환경
- ✅ **대량 작업**: 시간당 1,000개 이상 요청
- ✅ **오프라인 작업**: 인터넷 연결 불안정
- ✅ **완전한 제어**: 모든 설정 관리 필요
- ✅ **보안 정책**: 외부 서비스 사용 제한

#### 선호하는 경우
- ✅ **필터링 필요**: 스페이스/프로젝트 제한
- ✅ **읽기 전용**: 안전한 조회 전용 환경
- ✅ **프록시 환경**: 기업 네트워크
- ✅ **안정성 우선**: 검증된 솔루션 선호
- ✅ **비용 확정**: 무료 영구 사용

### Rovo MCP Server를 권장하는 경우

- ✅ **간편함 우선**: 빠른 설정 선호
- ✅ **Cloud 사용**: Atlassian Cloud 전용
- ✅ **OAuth 선호**: 토큰 관리 부담 회피
- ✅ **일반 업무**: 사용량이 적음

### POPUP STUDIO 권장 사항

**주 사용**: **mcp-atlassian (sooperset)**

**이유**:
1. **무료 영구 사용**: 비용 부담 없음
2. **완전한 제어**: 회사 정책에 맞게 설정
3. **필터링**: 프로젝트별 접근 제어
4. **안정성**: 프로덕션 환경에 적합
5. **대량 작업**: 사용량 제한 없음

**보조 사용**: Rovo MCP Server (간단한 조회 작업)

## 설치 및 설정 가이드 (POPUP STUDIO)

### 1단계: Docker 설치 확인

```bash
# Docker 버전 확인
docker --version

# 미설치 시 설치
# Mac: https://docs.docker.com/desktop/install/mac-install/
# Windows: https://docs.docker.com/desktop/install/windows-install/
```

### 2단계: Docker 이미지 다운로드

```bash
docker pull ghcr.io/sooperset/mcp-atlassian:latest
```

### 3단계: API 토큰 발급

1. https://id.atlassian.com/manage-profile/security/api-tokens 접속
2. "Create API token" 클릭
3. 이름: "POPUP-STUDIO-MCP"
4. 생성된 토큰 안전한 곳에 저장

### 4단계: 환경 변수 설정

`~/.mcp-atlassian/.env` 파일 생성:

```bash
# Confluence 설정
CONFLUENCE_URL=https://popupstudio.atlassian.net/wiki
CONFLUENCE_USERNAME=your.email@popupstudio.com
CONFLUENCE_API_TOKEN=your_confluence_api_token

# Jira 설정
JIRA_URL=https://popupstudio.atlassian.net
JIRA_USERNAME=your.email@popupstudio.com
JIRA_API_TOKEN=your_jira_api_token

# 필터링 (선택)
CONFLUENCE_SPACES_FILTER=POPUP,DEV,DESIGN
JIRA_PROJECTS_FILTER=PROJ,DESIGN,OPS

# 읽기 전용 모드 (선택, 초기 테스트 시 권장)
READ_ONLY_MODE=true
```

**보안 주의**:
```bash
# 파일 권한 설정 (본인만 읽기 가능)
chmod 600 ~/.mcp-atlassian/.env
```

### 5단계: Claude Code 설정

`~/.config/claude/mcp/claude_desktop_config.json` 파일 수정:

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "--env-file", "${HOME}/.mcp-atlassian/.env",
        "ghcr.io/sooperset/mcp-atlassian:latest"
      ]
    }
  }
}
```

### 6단계: Claude Code 재시작 및 테스트

```bash
# Claude Code 실행
claude
```

테스트 명령:
```
"Jira에서 사용 가능한 프로젝트 보여줘"
"Confluence에서 최근 업데이트된 페이지 찾아줘"
```

### 7단계: 읽기 전용 모드 해제 (선택)

테스트 완료 후 쓰기 작업이 필요하면:

`.env` 파일에서:
```bash
# READ_ONLY_MODE=true  # 주석 처리 또는 삭제
```

Claude Code 재시작

## 업데이트 방법

### 1. 최신 이미지 다운로드
```bash
docker pull ghcr.io/sooperset/mcp-atlassian:latest
```

### 2. 기존 컨테이너 정리 (필요 시)
```bash
docker system prune -f
```

### 3. Claude Code 재시작

## 문제 해결

### Docker 관련

#### "Cannot connect to Docker daemon"
```bash
# Docker Desktop이 실행 중인지 확인
# Mac: Docker Desktop 앱 실행
# Windows: Docker Desktop 실행
```

#### "Image not found"
```bash
# 이미지 다운로드 재시도
docker pull ghcr.io/sooperset/mcp-atlassian:latest
```

### 인증 관련

#### "401 Unauthorized"
- API 토큰이 올바른지 확인
- 이메일 주소가 정확한지 확인
- 토큰 만료 여부 확인 (재발급)

#### "403 Forbidden"
- 프로젝트/스페이스 접근 권한 확인
- Atlassian 계정 권한 확인

### 연결 관련

#### "Connection timeout"
- 인터넷 연결 확인
- `CONFLUENCE_URL`, `JIRA_URL` 정확성 확인
- 프록시 설정 확인

#### "SSL verification failed"
Server/Data Center에서 자체 서명 인증서 사용 시:
```bash
CONFLUENCE_SSL_VERIFY=false
JIRA_SSL_VERIFY=false
```

### 도구 관련

#### "Tool not found"
- `ENABLED_TOOLS` 설정 확인
- 올바른 도구 이름 사용 확인

#### "Too many requests"
- API Rate Limit 초과
- 요청 빈도 줄이기
- Atlassian 플랜 확인

## 보안 고려사항

### API 토큰 관리

**해야 할 것** ✅:
- 토큰을 안전한 곳에 저장
- 정기적으로 토큰 갱신
- 사용하지 않는 토큰 삭제
- `.env` 파일 권한 설정 (`chmod 600`)

**하지 말아야 할 것** ❌:
- Git에 커밋
- 팀 채팅에 공유
- 스크린샷에 포함
- 공개 문서에 기재

### 최소 권한 원칙

- 필요한 프로젝트/스페이스만 필터링
- 읽기 전용이 충분하면 `READ_ONLY_MODE=true`
- 필요한 도구만 `ENABLED_TOOLS`로 활성화

### 정기 감사

- 월 1회 API 토큰 검토
- 분기 1회 필터링 설정 재검토
- 미사용 계정 정리

## 추가 리소스

### 공식 문서
- **GitHub**: https://github.com/sooperset/mcp-atlassian
- **Releases**: https://github.com/sooperset/mcp-atlassian/releases
- **Issues**: https://github.com/sooperset/mcp-atlassian/issues

### Atlassian API 문서
- **Jira Cloud REST API**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
- **Confluence Cloud REST API**: https://developer.atlassian.com/cloud/confluence/rest/v1/
- **API Tokens**: https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/

### Docker 문서
- **Docker 설치**: https://docs.docker.com/get-docker/
- **Docker 기본 사용법**: https://docs.docker.com/get-started/

### 커뮤니티
- **MCP Hub**: https://mcphub.tools/detail/sooperset/mcp-atlassian
- **Atlassian Community**: https://community.atlassian.com/

## 결론

**mcp-atlassian (sooperset)**은 Atlassian 제품과 AI 어시스턴트를 통합하는 **강력하고 유연한** MCP 서버입니다.

**핵심 장점**:
- 🆓 **완전 무료** (MIT 라이선스)
- 🔧 **완전한 제어** (모든 설정 관리 가능)
- 🚀 **무제한 사용** (API 제한만 적용)
- 🏢 **Server/Data Center 지원** (온프레미스 환경)
- 🛡️ **보안 강화** (필터링, 읽기 전용 모드)

**POPUP STUDIO에서는 mcp-atlassian을 주력으로 사용**하며, 간단한 조회 작업에는 Rovo MCP Server를 보조로 활용하는 것을 권장합니다.

---

**작성일**: 2025-11-06
**작성자**: Claude Code
**버전**: 1.0
**상태**: mcp-atlassian latest 버전 기준
