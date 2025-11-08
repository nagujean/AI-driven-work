# NEXT_TASK - 다음 개선 작업 목록

> **작성일**: 2025-11-08
> **작성자**: Claude Code
> **목적**: AI-driven-work 프로젝트의 개선 사항 및 확장 계획 관리

---

## 우선순위 높음 (High Priority)

### 1. Windows OS 대응

**현재 상태**:
- 모든 스크립트가 Bash 기반 (`.sh`)
- macOS/Linux에서만 실행 가능
- Windows 사용자는 WSL 또는 Git Bash 필요

**개선 작업**:

#### 1.1 PowerShell 스크립트 생성

```
scripts/
├── setup.sh                      # 기존 (macOS/Linux)
├── setup.ps1                     # 신규 (Windows PowerShell)
├── jira-rules-setup.sh          # 기존
├── jira-rules-setup.ps1         # 신규
├── github-workflow-setup.sh     # 기존
└── github-workflow-setup.ps1    # 신규
```

**작업 내용**:
- [ ] `setup.ps1` 작성
  - Node.js 버전 확인 (Windows 경로 대응)
  - Claude Code 설치 (`npm install -g`)
  - MCP Server 선택 및 설정
  - 환경 변수 설정 (Windows 레지스트리 또는 사용자 프로필)
  - Claude Code CLI 등록

- [ ] `jira-rules-setup.ps1` 작성
  - Slash commands 복사 (Windows 경로 구분자 `\` 대응)
  - Jira 지침 복사
  - 기존 instructions 통합
  - 백업 기능
  - Dry-run 모드

- [ ] `github-workflow-setup.ps1` 작성
  - GitHub workflow 지침 복사
  - CODEOWNERS 생성
  - Issue 템플릿 생성
  - 기존 instructions 통합
  - 백업 기능
  - Dry-run 모드

#### 1.2 크로스 플랫폼 런처 스크립트

**목적**: 사용자 OS를 자동 감지하여 적절한 스크립트 실행

```bash
# scripts/setup (확장자 없음, 실행 권한 부여)
#!/bin/sh
case "$(uname -s)" in
    Linux*|Darwin*)
        exec bash "$(dirname "$0")/setup.sh" "$@"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        exec powershell -ExecutionPolicy Bypass -File "$(dirname "$0")/setup.ps1" "$@"
        ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
esac
```

**작업 내용**:
- [ ] `scripts/setup` (런처)
- [ ] `scripts/jira-rules-setup` (런처)
- [ ] `scripts/github-workflow-setup` (런처)
- [ ] README.md 업데이트 (Windows 사용자 안내)

#### 1.3 Windows 환경 테스트

**테스트 환경**:
- Windows 10/11
- PowerShell 5.1+
- PowerShell Core 7.x
- Git Bash (대안)
- WSL2 (대안)

**테스트 항목**:
- [ ] Node.js 설치 확인
- [ ] Claude Code 설치
- [ ] MCP Server 설정 (mcp-atlassian Docker on Windows)
- [ ] 경로 처리 (백슬래시 vs 슬래시)
- [ ] 파일 권한 처리
- [ ] 색상 출력 (PowerShell 콘솔)
- [ ] 대화형 입력 (read -p 대체)

---

## 우선순위 중간 (Medium Priority)

### 2. MCP 서버 확장

**현재 상태**:
- mcp-atlassian만 통합됨

**추가 예정 MCP 서버**:

#### 2.1 Slack MCP Server
- [ ] Slack MCP Server 조사 및 선정
- [ ] setup.sh에 Slack MCP 옵션 추가
- [ ] Slack 연동 slash commands 추가
  - `/slack-search <keyword>`: 메시지 검색
  - `/slack-to-confluence <thread-url>`: 스레드를 Confluence로 변환
- [ ] 문서 업데이트

#### 2.2 GitHub MCP Server
- [ ] GitHub MCP Server 조사 및 선정
- [ ] setup.sh에 GitHub MCP 옵션 추가
- [ ] GitHub 연동 slash commands 추가
  - `/gh-pr-list`: 내 PR 목록
  - `/gh-issue-create`: 이슈 생성
  - `/gh-pr-review <pr-number>`: PR 리뷰
- [ ] 문서 업데이트

#### 2.3 Notion MCP Server
- [ ] Notion MCP Server 조사 및 선정
- [ ] Notion → Confluence 마이그레이션 도구
- [ ] 문서 업데이트

#### 2.4 Google Drive MCP Server
- [ ] Google Drive MCP Server 조사 및 선정
- [ ] 문서 검색 및 Confluence 동기화
- [ ] 문서 업데이트

### 3. 설정 자동화 개선

#### 3.1 기존 설정 감지 및 업데이트

**현재 상태**:
- setup.sh는 신규 설치만 잘 지원
- 기존 설정 업데이트 시나리오 개선 필요

**개선 작업**:
- [ ] 기존 MCP 서버 설정 감지
- [ ] 버전 체크 및 업데이트 제안
- [ ] 선택적 MCP 서버 추가/제거
- [ ] 설정 백업 및 복구 기능

#### 3.2 설정 마이그레이션

**목적**: mcp-atlassian 업데이트 시 기존 설정 보존

**작업 내용**:
- [ ] 설정 버전 관리
- [ ] 마이그레이션 스크립트
- [ ] 호환성 체크

### 4. 에러 처리 및 로깅

#### 4.1 에러 처리 강화

**현재 문제**:
- 일부 에러 메시지가 불명확
- 복구 가이드 부족

**개선 작업**:
- [ ] 에러 코드 체계화
- [ ] 에러별 해결 가이드 제공
- [ ] Rollback 기능 추가

#### 4.2 로깅 기능 추가

**작업 내용**:
- [ ] 스크립트 실행 로그 저장 (`~/.ai-driven-work/logs/`)
- [ ] 디버그 모드 (`--debug` 플래그)
- [ ] 로그 분석 도구

---

## 우선순위 낮음 (Low Priority)

### 5. 문서화 개선

#### 5.1 비디오 튜토리얼

**작업 내용**:
- [ ] 초기 설정 영상 (5분)
- [ ] Jira 기능 사용법 영상 (10분)
- [ ] GitHub 워크플로우 영상 (10분)
- [ ] 문제 해결 영상 (5분)

#### 5.2 Troubleshooting 가이드

**작업 내용**:
- [ ] `docs/troubleshooting.md` 생성
- [ ] 자주 묻는 에러와 해결 방법
- [ ] FAQ 확장

#### 5.3 다국어 지원

**작업 내용**:
- [ ] 영어 문서 작성
- [ ] 일어 문서 작성 (선택)

### 6. CI/CD 및 자동화

#### 6.1 GitHub Actions 추가

**작업 내용**:
- [ ] PR 자동 검증 (스크립트 문법 체크)
- [ ] Markdown 린팅
- [ ] 자동 릴리스 노트 생성
- [ ] 버전 태깅 자동화

#### 6.2 스크립트 테스트

**작업 내용**:
- [ ] Bash 스크립트 단위 테스트 (bats)
- [ ] PowerShell 스크립트 Pester 테스트
- [ ] 통합 테스트 (Docker 환경)

### 7. 사용성 개선

#### 7.1 대화형 설정 마법사

**현재 상태**:
- setup.sh가 일부 대화형이지만 개선 여지 있음

**개선 작업**:
- [ ] 단계별 진행 표시 (1/7, 2/7, ...)
- [ ] 설정 요약 및 확인 단계
- [ ] 이전 단계로 돌아가기 옵션

#### 7.2 GUI 설정 도구 (선택)

**작업 내용**:
- [ ] Electron 기반 GUI 설정 도구
- [ ] 웹 기반 설정 인터페이스
- [ ] 설정 현황 대시보드

### 8. 보안 강화

#### 8.1 API 토큰 관리 개선

**현재 상태**:
- `.env` 파일에 평문 저장

**개선 작업**:
- [ ] 운영 체제 키체인 사용 (macOS Keychain, Windows Credential Manager)
- [ ] 토큰 암호화 저장
- [ ] 토큰 만료 알림

#### 8.2 권한 최소화

**작업 내용**:
- [ ] 필요한 최소 권한 문서화
- [ ] 권한 검증 스크립트

---

## 미래 확장 계획 (Future)

### 9. AI Agent 고도화

#### 9.1 Context-Aware Automation

**아이디어**:
- 프로젝트 상태 자동 파악
- 자동 이슈 분류 및 우선순위 지정
- 예측 기반 리소스 할당 제안

#### 9.2 자연어 기반 워크플로우

**아이디어**:
- "이번 주 완료된 일을 팀원별로 정리해서 슬랙에 공유해줘"
- "지난달 대비 이슈 처리 속도가 어떻게 변했는지 분석해줘"

### 10. 팀 대시보드

**아이디어**:
- 실시간 팀 업무 현황 대시보드
- Jira + Confluence + GitHub 통합 뷰
- 개인별/프로젝트별 통계

### 11. 플러그인 시스템

**아이디어**:
- 커스텀 MCP 서버 쉽게 추가
- 커스텀 slash command 등록
- 커뮤니티 플러그인 마켓플레이스

---

## 작업 우선순위 결정 기준

### High Priority
- 사용자 접근성에 직접 영향 (Windows 지원)
- 명백한 버그나 문제
- 보안 이슈

### Medium Priority
- 기능 확장 (MCP 서버 추가)
- 사용자 경험 개선
- 자동화 향상

### Low Priority
- 문서화 개선
- 선택적 기능
- 미래 기능 탐색

---

## 기여 방법

이 문서의 작업 항목을 수행하고 싶다면:

1. GitHub Issue로 해당 작업 선언
2. Feature 브랜치 생성
3. 작업 완료 후 PR 생성
4. popup-kay 리뷰 후 머지
5. 이 문서의 체크박스 업데이트

---

## 버전 히스토리

- **2025-11-08**: 초안 작성 (Windows OS 대응, MCP 서버 확장, 설정 자동화 등)

---

**문의**: 작업 우선순위나 새로운 아이디어가 있다면 GitHub Issue로 제안해주세요.
