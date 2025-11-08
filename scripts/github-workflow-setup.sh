#!/bin/bash

# GitHub Workflow Setup Script
# AI-driven-work 프로젝트의 GitHub 워크플로우 설정을 다른 프로젝트에 추가합니다.
#
# Usage:
#   ./scripts/github-workflow-setup.sh <target-project-path> [--dry-run]
#
# Examples:
#   ./scripts/github-workflow-setup.sh ~/projects/my-web-app
#   ./scripts/github-workflow-setup.sh /path/to/project --dry-run

set -e

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 현재 스크립트의 디렉토리 (AI-driven-work 프로젝트 루트)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 소스 경로
SOURCE_INSTRUCTIONS_DIR="$SOURCE_PROJECT_DIR/.claude/instructions"
SOURCE_GITHUB_WORKFLOW="$SOURCE_INSTRUCTIONS_DIR/github-workflow.md"

# 백업 디렉토리
BACKUP_DIR=""

# Dry-run 모드
DRY_RUN=false

# ============================================================
# 헬퍼 함수들
# ============================================================

# 사용법 표시
show_usage() {
    echo ""
    echo "Usage: $0 <target-project-path> [--dry-run]"
    echo ""
    echo "Examples:"
    echo "  $0 ~/projects/my-web-app"
    echo "  $0 /path/to/project --dry-run"
    echo ""
    exit 1
}

# 에러 메시지 출력 및 종료
error_exit() {
    echo -e "${RED}❌ 오류: $1${NC}" >&2
    exit 1
}

# 백업 생성
create_backup() {
    local target_file="$1"

    if [ ! -f "$target_file" ]; then
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CYAN}[DRY-RUN]${NC} 백업 생성: $target_file"
        return 0
    fi

    local backup_file="${BACKUP_DIR}/$(basename "$target_file").backup"
    cp "$target_file" "$backup_file"
    echo -e "  💾 백업 생성: $(basename "$target_file")"
}

# 파일 복사 (충돌 처리 포함)
copy_file_with_conflict_handling() {
    local source_file="$1"
    local target_file="$2"

    if [ ! -f "$source_file" ]; then
        echo -e "  ${YELLOW}⚠️  소스 파일이 존재하지 않습니다: $(basename "$source_file")${NC}"
        return 1
    fi

    # 타겟 파일이 이미 존재하는 경우
    if [ -f "$target_file" ]; then
        echo -e "  ${YELLOW}⚠️  $(basename "$target_file") 이미 존재합니다.${NC}"

        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${CYAN}[DRY-RUN]${NC} 사용자에게 선택을 물어볼 예정"
            return 0
        fi

        echo -e "     ${CYAN}(o)${NC}덮어쓰기 / ${CYAN}(s)${NC}건너뛰기 / ${CYAN}(r)${NC}이름변경 / ${CYAN}(d)${NC}차이점 보기"
        read -p "     선택: " choice

        case "$choice" in
            o|O)
                create_backup "$target_file"
                cp "$source_file" "$target_file"
                echo -e "  ${GREEN}✅ $(basename "$target_file") 덮어쓰기 완료${NC}"
                return 0
                ;;
            s|S)
                echo -e "  ${BLUE}⏭️  $(basename "$target_file") 건너뜀${NC}"
                return 0
                ;;
            r|R)
                read -p "     새 파일명 (확장자 제외): " new_name
                local new_target="${target_file%.*}-${new_name}.${target_file##*.}"
                cp "$source_file" "$new_target"
                echo -e "  ${GREEN}✅ $(basename "$new_target") 생성 완료${NC}"
                return 0
                ;;
            d|D)
                echo ""
                echo "=========================================="
                echo "차이점:"
                echo "=========================================="
                diff "$target_file" "$source_file" || true
                echo "=========================================="
                echo ""
                # 재귀 호출로 다시 선택하게 함
                copy_file_with_conflict_handling "$source_file" "$target_file"
                return $?
                ;;
            *)
                echo -e "  ${BLUE}⏭️  잘못된 입력. 건너뜀${NC}"
                return 0
                ;;
        esac
    else
        # 타겟 파일이 없는 경우 - 그냥 복사
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${CYAN}[DRY-RUN]${NC} 복사: $(basename "$source_file") → $(basename "$target_file")"
        else
            cp "$source_file" "$target_file"
            echo -e "  ${GREEN}✅ $(basename "$target_file") 복사 완료${NC}"
        fi
        return 0
    fi
}

# CODEOWNERS 파일 생성
create_codeowners() {
    local target_github_dir="$1"
    local github_username="$2"
    local codeowners_file="$target_github_dir/CODEOWNERS"

    if [ -f "$codeowners_file" ]; then
        echo -e "  ${YELLOW}⚠️  CODEOWNERS 파일이 이미 존재합니다.${NC}"

        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${CYAN}[DRY-RUN]${NC} 사용자에게 선택을 물어볼 예정"
            return 0
        fi

        echo -e "     ${CYAN}(o)${NC}덮어쓰기 / ${CYAN}(s)${NC}건너뛰기 / ${CYAN}(a)${NC}소유자 추가"
        read -p "     선택: " choice

        case "$choice" in
            o|O)
                create_backup "$codeowners_file"
                cat > "$codeowners_file" <<EOF
# CODEOWNERS
# 모든 파일의 기본 소유자

* @${github_username}

# 특정 디렉토리 소유자 (필요 시 수정)
/scripts/ @${github_username}
/.claude/ @${github_username}
/docs/ @${github_username}
EOF
                echo -e "  ${GREEN}✅ CODEOWNERS 덮어쓰기 완료${NC}"
                ;;
            s|S)
                echo -e "  ${BLUE}⏭️  CODEOWNERS 건너뜀${NC}"
                ;;
            a|A)
                create_backup "$codeowners_file"
                # 파일 끝에 소유자 추가 (중복 체크)
                if ! grep -q "@${github_username}" "$codeowners_file"; then
                    echo "" >> "$codeowners_file"
                    echo "# Added by github-workflow-setup.sh" >> "$codeowners_file"
                    echo "* @${github_username}" >> "$codeowners_file"
                    echo -e "  ${GREEN}✅ CODEOWNERS에 @${github_username} 추가 완료${NC}"
                else
                    echo -e "  ${BLUE}ℹ️  @${github_username}는 이미 CODEOWNERS에 있습니다${NC}"
                fi
                ;;
            *)
                echo -e "  ${BLUE}⏭️  잘못된 입력. 건너뜀${NC}"
                ;;
        esac
    else
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${CYAN}[DRY-RUN]${NC} CODEOWNERS 생성 예정"
        else
            cat > "$codeowners_file" <<EOF
# CODEOWNERS
# 모든 파일의 기본 소유자

* @${github_username}

# 특정 디렉토리 소유자 (필요 시 수정)
/scripts/ @${github_username}
/.claude/ @${github_username}
/docs/ @${github_username}
EOF
            echo -e "  ${GREEN}✅ CODEOWNERS 생성 완료${NC}"
        fi
    fi
}

# Issue 템플릿 생성
create_issue_templates() {
    local target_github_dir="$1"
    local github_username="$2"
    local template_dir="$target_github_dir/ISSUE_TEMPLATE"

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CYAN}[DRY-RUN]${NC} Issue 템플릿 디렉토리 생성 예정"
    else
        mkdir -p "$template_dir"
        echo -e "  ${GREEN}✅ Issue 템플릿 디렉토리 생성${NC}"
    fi

    # Bug Report 템플릿
    local bug_report_file="$template_dir/bug_report.md"
    if [ -f "$bug_report_file" ]; then
        echo -e "  ${BLUE}ℹ️  bug_report.md 이미 존재 - 건너뜀${NC}"
    else
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${CYAN}[DRY-RUN]${NC} bug_report.md 생성 예정"
        else
            cat > "$bug_report_file" <<EOF
---
name: Bug Report
about: 버그 리포트
title: '[BUG] '
labels: bug
assignees: ${github_username}
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
- OS: [예: macOS 14.0]
- Shell: [예: zsh 5.9]
- Node.js: [예: v20.10.0]

## 추가 정보
<!-- 스크린샷, 에러 로그 등 -->
EOF
            echo -e "  ${GREEN}✅ bug_report.md 생성 완료${NC}"
        fi
    fi

    # Feature Request 템플릿
    local feature_request_file="$template_dir/feature_request.md"
    if [ -f "$feature_request_file" ]; then
        echo -e "  ${BLUE}ℹ️  feature_request.md 이미 존재 - 건너뜀${NC}"
    else
        if [ "$DRY_RUN" = true ]; then
            echo -e "  ${CYAN}[DRY-RUN]${NC} feature_request.md 생성 예정"
        else
            cat > "$feature_request_file" <<EOF
---
name: Feature Request
about: 새로운 기능 제안
title: '[FEATURE] '
labels: enhancement
assignees: ${github_username}
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
EOF
            echo -e "  ${GREEN}✅ feature_request.md 생성 완료${NC}"
        fi
    fi
}

# instructions 파일에 github-workflow.md 참조 추가
add_github_workflow_reference() {
    local instruction_file="$1"
    local relative_path=".claude/instructions/github-workflow.md"

    # 이미 참조가 있는지 확인
    if grep -q "github-workflow.md" "$instruction_file" 2>/dev/null; then
        echo -e "  ${BLUE}ℹ️  $(basename "$instruction_file"): 이미 github-workflow.md 참조 존재${NC}"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "  ${CYAN}[DRY-RUN]${NC} 참조 추가 예정: $(basename "$instruction_file")"
        return 0
    fi

    # 백업 생성
    create_backup "$instruction_file"

    # 파일 시작 부분에 참조 추가
    local temp_file="${instruction_file}.tmp"

    cat > "$temp_file" <<EOF
---

> **🔀 GitHub Workflow**: This project follows standardized branch and PR workflows.
> See: \`$relative_path\`

---

EOF

    cat "$instruction_file" >> "$temp_file"
    mv "$temp_file" "$instruction_file"

    echo -e "  ${GREEN}✅ $(basename "$instruction_file"): github-workflow.md 참조 추가 완료${NC}"
}

# ============================================================
# 메인 로직
# ============================================================

echo ""
echo "=========================================="
echo -e "${BLUE}🔀 GitHub Workflow Setup${NC}"
echo "=========================================="
echo ""

# 파라미터 확인
if [ $# -lt 1 ]; then
    echo -e "${RED}❌ 타겟 프로젝트 경로를 입력해주세요.${NC}"
    show_usage
fi

TARGET_PROJECT_DIR="$1"

# Dry-run 옵션 확인
if [ $# -ge 2 ] && [ "$2" = "--dry-run" ]; then
    DRY_RUN=true
    echo -e "${CYAN}🔍 DRY-RUN 모드: 실제 변경 없이 미리보기만 수행합니다.${NC}"
    echo ""
fi

# 타겟 경로 절대 경로로 변환
TARGET_PROJECT_DIR="$(cd "$TARGET_PROJECT_DIR" 2>/dev/null && pwd)" || error_exit "타겟 디렉토리가 존재하지 않습니다: $1"

# 타겟 경로
TARGET_INSTRUCTIONS_DIR="$TARGET_PROJECT_DIR/.claude/instructions"
TARGET_GITHUB_WORKFLOW="$TARGET_INSTRUCTIONS_DIR/github-workflow.md"
TARGET_GITHUB_DIR="$TARGET_PROJECT_DIR/.github"

echo -e "${CYAN}소스 프로젝트:${NC} $SOURCE_PROJECT_DIR"
echo -e "${CYAN}타겟 프로젝트:${NC} $TARGET_PROJECT_DIR"
echo ""

# 소스 파일 확인
if [ ! -f "$SOURCE_GITHUB_WORKFLOW" ]; then
    error_exit "소스 프로젝트에 github-workflow.md가 없습니다. AI-driven-work 프로젝트에서 실행하세요."
fi

# GitHub username 입력받기
if [ "$DRY_RUN" = false ]; then
    echo -e "${YELLOW}📝 GitHub 설정 정보 입력${NC}"
    echo ""
    read -p "GitHub Username (예: popup-kay): " GITHUB_USERNAME

    if [ -z "$GITHUB_USERNAME" ]; then
        error_exit "GitHub username을 입력해주세요."
    fi

    echo ""
fi

# 백업 디렉토리 생성
if [ "$DRY_RUN" = false ]; then
    BACKUP_DIR="$TARGET_PROJECT_DIR/.claude/.backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo -e "${GREEN}📦 백업 디렉토리 생성: $BACKUP_DIR${NC}"
    echo ""
fi

# ============================================================
# 1단계: GitHub Workflow 지침 복사
# ============================================================
echo "=========================================="
echo -e "${BLUE}[1/4] GitHub Workflow 지침 복사${NC}"
echo "=========================================="
echo ""

# 타겟 instructions 디렉토리 생성
if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}[DRY-RUN]${NC} 디렉토리 생성: $TARGET_INSTRUCTIONS_DIR"
else
    mkdir -p "$TARGET_INSTRUCTIONS_DIR"
    echo -e "${GREEN}✅ 디렉토리 생성: $TARGET_INSTRUCTIONS_DIR${NC}"
fi
echo ""

# github-workflow.md 복사
copy_file_with_conflict_handling "$SOURCE_GITHUB_WORKFLOW" "$TARGET_GITHUB_WORKFLOW"

echo ""

# ============================================================
# 2단계: .github 디렉토리 설정
# ============================================================
echo "=========================================="
echo -e "${BLUE}[2/4] GitHub 설정 파일 생성${NC}"
echo "=========================================="
echo ""

# .github 디렉토리 생성
if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}[DRY-RUN]${NC} 디렉토리 생성: $TARGET_GITHUB_DIR"
else
    mkdir -p "$TARGET_GITHUB_DIR"
    echo -e "${GREEN}✅ 디렉토리 생성: $TARGET_GITHUB_DIR${NC}"
fi
echo ""

# CODEOWNERS 생성
if [ "$DRY_RUN" = false ]; then
    create_codeowners "$TARGET_GITHUB_DIR" "$GITHUB_USERNAME"
fi

echo ""

# Issue 템플릿 생성
if [ "$DRY_RUN" = false ]; then
    create_issue_templates "$TARGET_GITHUB_DIR" "$GITHUB_USERNAME"
fi

echo ""

# ============================================================
# 3단계: 기존 instructions 파일에 참조 추가
# ============================================================
echo "=========================================="
echo -e "${BLUE}[3/4] 기존 Instructions 파일 확인${NC}"
echo "=========================================="
echo ""

# 타겟에 있는 다른 instruction 파일들 찾기
if [ -d "$TARGET_INSTRUCTIONS_DIR" ]; then
    OTHER_INSTRUCTIONS=()

    while IFS= read -r -d '' file; do
        # github-workflow.md는 제외
        if [ "$(basename "$file")" != "github-workflow.md" ]; then
            OTHER_INSTRUCTIONS+=("$file")
        fi
    done < <(find "$TARGET_INSTRUCTIONS_DIR" -maxdepth 1 -type f -name "*.md" -print0 2>/dev/null)

    if [ ${#OTHER_INSTRUCTIONS[@]} -eq 0 ]; then
        echo -e "${BLUE}ℹ️  다른 instruction 파일이 없습니다.${NC}"
    else
        echo -e "${CYAN}발견된 instruction 파일: ${#OTHER_INSTRUCTIONS[@]}개${NC}"
        echo ""

        for inst_file in "${OTHER_INSTRUCTIONS[@]}"; do
            echo -e "  📄 $(basename "$inst_file")"
            add_github_workflow_reference "$inst_file"
        done
    fi
else
    echo -e "${BLUE}ℹ️  instructions 디렉토리가 없습니다.${NC}"
fi

echo ""

# ============================================================
# 4단계: 완료 메시지
# ============================================================
echo "=========================================="
echo -e "${GREEN}✨ [4/4] 설정 완료! ✨${NC}"
echo "=========================================="
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${CYAN}🔍 DRY-RUN 모드였습니다. 실제 변경은 이루어지지 않았습니다.${NC}"
    echo ""
    echo "실제로 적용하려면 --dry-run 옵션 없이 다시 실행하세요:"
    echo -e "  ${YELLOW}$0 $TARGET_PROJECT_DIR${NC}"
else
    echo -e "${YELLOW}📝 다음 단계:${NC}"
    echo ""
    echo "1. GitHub 저장소 설정:"
    echo -e "   ${CYAN}https://github.com/<your-org>/<your-repo>/settings/branches${NC}"
    echo ""
    echo "   Branch Protection Rules 적용:"
    echo "   - main 브랜치: PR 필수, @${GITHUB_USERNAME} 승인 필수"
    echo "   - develop 브랜치: PR 필수, @${GITHUB_USERNAME} 승인 필수"
    echo ""
    echo "2. CODEOWNERS 파일 커밋:"
    echo -e "   ${CYAN}git add .github/CODEOWNERS${NC}"
    echo -e "   ${CYAN}git commit -m \"chore: Add CODEOWNERS file\"${NC}"
    echo ""
    echo "3. Issue 템플릿 커밋:"
    echo -e "   ${CYAN}git add .github/ISSUE_TEMPLATE/${NC}"
    echo -e "   ${CYAN}git commit -m \"chore: Add issue templates\"${NC}"
    echo ""
    echo "4. GitHub Workflow 지침 커밋:"
    echo -e "   ${CYAN}git add .claude/instructions/github-workflow.md${NC}"
    echo -e "   ${CYAN}git commit -m \"docs: Add GitHub workflow guidelines\"${NC}"
    echo ""
    echo "5. Claude Code로 확인:"
    echo -e "   ${CYAN}cd $TARGET_PROJECT_DIR${NC}"
    echo -e "   ${CYAN}claude${NC}"
    echo -e "   ${CYAN}> GitHub 워크플로우 규칙 알려줘${NC}"
    echo ""

    if [ -n "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}💾 백업 위치:${NC}"
        echo -e "   $BACKUP_DIR"
        echo ""
        echo -e "${YELLOW}⚠️  문제가 발생한 경우 백업에서 복구할 수 있습니다.${NC}"
        echo ""
    fi
fi

echo "=========================================="
echo -e "${GREEN}🎉 완료! 즐거운 작업 되세요! 🎉${NC}"
echo "=========================================="
echo ""
