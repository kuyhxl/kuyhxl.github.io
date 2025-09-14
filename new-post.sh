#!/bin/bash
# ================================================
# ��� ���� (new-post.sh)
# -----------------------------------------------
# �� ��ũ��Ʈ�� Hugo ��α׿� �� ���� �ۼ��ϰ�,
# �̹��� ������ ������ ��, Ŀ�� & Ǫ�ñ��� �ڵ�ȭ�մϴ�.
#
# ����:
#   newpost "�� ����"       # alias ��� ����
#   �Ǵ� ���� ����: ./new-post.sh "�� ����"
#
# ���� �� ����:
# 1. ���� ��¥ + �������� Markdown ���� ���� (content/post/)
# 2. static/images/ �� ���� �̸� ���� ���� (�̹��� ������)
# 3. Typora�� �� ���� ���� �� �ۼ� �� ����
# 4. Enter Ű �Է� �� Hugo ���� + git add/commit/push �ڵ� ����
# 5. GitHub Actions�� ����Ǿ� ��αװ� �����˴ϴ�.
#
# ���ǻ���:
# - Hugo ������Ʈ ��Ʈ(=hugo.toml �ִ� ��ġ)���� �����ؾ� ��
# - draft=false �� �����ؾ� ������
# - Typora ��ġ �ʿ� (��ġ �� �� ��� ���� ���� ����)
# ================================================
# new-post.sh : �� �� + �̹��� ���� ���� + Ŀ��/Ǫ�ñ��� �ڵ�ȭ

TITLE=$1

if [ -z "$TITLE" ]; then
  echo "? ������ �Է����ּ���. ��: ./new-post.sh '������ ��α� ��'"
  exit 1
fi

# ���� ��¥ + ������ ����
DATE=$(date +%Y-%m-%d)
SLUG="${DATE}-${TITLE// /-}" # ������ -�� �ٲ㼭 ���ϸ� ����
POST_PATH="content/post/$SLUG.md"
IMAGE_DIR="static/images/$SLUG"


# �� ����
echo "? �� �� ����: $POST_PATH"
hugo new "$POST_PATH"

# UTF-8 ���ڵ� ���� ����
iconv -f UTF-8 -t UTF-8 "$POST_PATH" > "$POST_PATH.tmp" && mv "$POST_PATH.tmp" "$POST_PATH"

# �̹��� ���� ����
mkdir -p "$IMAGE_DIR"
echo "? �̹��� ���� ����: $IMAGE_DIR"

# Typora�� �� ���� ����
if command -v typora &> /dev/null
then
  typora "$POST_PATH"
else
  echo "?? Typora�� ã�� �� �����ϴ�. �������� ������ ���� �����ϼ���."
fi

# �� �ۼ� �Ϸ� ���
read -p "?? �� �ۼ� �� ���������� Enter Ű�� ���� ��� ���� �� "

# ���� ���� Ȯ��
read -r -p "? ���� �����ұ��? [y/N]: " CONFIRM
case "$CONFIRM" in
  [yY]|[yY][eE][sS])
    echo "? Hugo ���� ���� ��..."
    hugo --minify

    echo "? Git Ŀ�� & Ǫ�� ����..."
    git add .
    git commit -m "post: $TITLE"
    git push origin main

    echo "? ���� �Ϸ�! GitHub Actions���� �ڵ� ������ ���۵˴ϴ�."
    echo "? https://kuyhxl.github.io/ ���� ��� �� Ȯ���ϼ���."
    ;;
  *)
    echo "? ������ �ǳʶݴϴ�. ���߿� �����Ϸ��� �Ʒ� ��� �� �ϳ��� ����ϼ���:"
    echo "   blogpush \"post: $TITLE\"   # �Ǵ� git add/commit/push"
    ;;
esac