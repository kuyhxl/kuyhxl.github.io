#!/bin/bash
# ================================================
# 사용 설명서 (new-post.sh)
# -----------------------------------------------
# 이 스크립트는 Hugo 블로그에 새 글을 작성하고,
# 이미지 폴더를 생성한 뒤, 커밋 & 푸시까지 자동화합니다.
#
# 사용법:
#   newpost "글 제목"       # alias 사용 권장
#   또는 직접 실행: ./new-post.sh "글 제목"
#
# 실행 시 동작:
# 1. 제목으로 Markdown 파일 생성 (content/post/)
# 2. static/images/ 에 동일 이름 폴더 생성 (이미지 보관용)
# 3. Typora로 글 파일 열기 → 작성 후 저장
# 4. Enter 키 입력 시 Hugo 빌드 + git add/commit/push 자동 수행
# 5. GitHub Actions가 실행되어 블로그가 배포됩니다.
#
# 유의사항:
# - Hugo 프로젝트 루트(=hugo.toml 있는 위치)에서 실행해야 함
# - draft=false 로 설정해야 배포됨
# - Typora 설치 필요 (설치 안 된 경우 직접 파일 열기)
# ================================================
# new-post.sh : 새 글 + 이미지 폴더 생성 + 커밋/푸시까지 자동화

TITLE=$1

if [ -z "$TITLE" ]; then
  echo "? 제목을 입력해주세요. 예: ./new-post.sh '오늘의 블로그 글'"
  exit 1
fi

SLUG="${TITLE// /-}" # 공백을 -로 바꿔서 파일명 생성
POST_PATH="content/post/$SLUG.md"
IMAGE_DIR="static/images/$SLUG"


# 글 생성
echo "? 새 글 생성: $POST_PATH"
hugo new "$POST_PATH"

# UTF-8 인코딩 강제 적용
iconv -f UTF-8 -t UTF-8 "$POST_PATH" > "$POST_PATH.tmp" && mv "$POST_PATH.tmp" "$POST_PATH"

# 이미지 폴더 생성
mkdir -p "$IMAGE_DIR"
echo "? 이미지 폴더 생성: $IMAGE_DIR"

# Typora로 글 파일 열기
if open -Ra "Typora.app"; then
  open -a "Typora.app" "$POST_PATH"
else
  echo "⚠️ Typora 실행 실패: 수동으로 파일을 열어 편집하세요."
fi

# 글 작성 완료 대기
read -p "?? 글 작성 후 저장했으면 Enter 키를 눌러 계속 진행 → "

# 배포 여부 확인
read -r -p "🚀 지금 배포할까요? [Y/N]: " CONFIRM
case "$CONFIRM" in
  [yY]|[Yy][Ee][Ss])
    echo "✅ Hugo 빌드 실행 중..."
    hugo --minify

    echo "✅ Git 커밋 & 푸시 시작..."
    git add .
    git commit -m "post: ${TITLE}"
    git push origin main

    echo "🚀 배포 완료! GitHub Actions에서 자동 배포가 시작됩니다."
    echo "🌐 https://kuyhxl.github.io/ 에서 잠시 후 확인하세요."
    ;;
  *)
    echo "⏸ 배포를 건너뜁니다. 나중에 배포하려면 아래 명령 중 하나를 사용하세요:"
    echo "   blogpush \"post: ${TITLE}\"   # 또는 git add/commit/push"
    ;;
esac