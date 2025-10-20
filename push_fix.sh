#!/usr/bin/env bash
set -euo pipefail
REPO_URL="https://github.com/alexandralungoci25-collab/qa-final-project-java.git"

# Detect remote default branch (master/main) if it exists
detect_branch() {
  if git ls-remote --heads origin master >/dev/null 2>&1 &&              git ls-remote --heads origin master | grep -q "refs/heads/master"; then
    echo "master"
  elif git ls-remote --heads origin main >/dev/null 2>&1 &&                git ls-remote --heads origin main | grep -q "refs/heads/main"; then
    echo "main"
  else
    # No remote branch yet -> use main by convention
    echo "main"
  fi
}

# Ensure repo initialized
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || git init

# Ensure origin is set to the correct URL
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

TARGET_BRANCH="$(detect_branch)"
echo "Using target branch: $TARGET_BRANCH"

# Rename current branch to target
git branch -M "$TARGET_BRANCH"

# Fetch and rebase if remote branch exists
if git ls-remote --heads origin "$TARGET_BRANCH" | grep -q "refs/heads/$TARGET_BRANCH"; then
  echo "Remote branch exists; attempting rebase..."
  git fetch origin
  set +e
  git pull --rebase origin "$TARGET_BRANCH"
  STATUS=$?
  set -e
  if [ $STATUS -ne 0 ]; then
    cat <<'EOF'
------------------------------------------------------------
Rebase a întâmpinat conflicte. Rezolvă conflictele raportate,
apoi rulează:
    git add .
    git rebase --continue
    git push -u origin ${TARGET_BRANCH}
------------------------------------------------------------
EOF
    exit 1
  fi
fi

# Push with upstream
git push -u origin "$TARGET_BRANCH"
echo "✅ Push complet pe ramura $TARGET_BRANCH"
