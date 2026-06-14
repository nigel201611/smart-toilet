Commit code: $ARGUMENTS

## Steps

1. Check current changes: `git status`
2. View detailed changes: `git diff`
3. Generate commit message based on changes
4. Stage and commit

## Commit Message Rules

Format: `<type>: <description>`

Rules:
- description must be in English
- description should not exceed 50 characters
- Use verb at the beginning: add, fix, update, remove, refactor
- All lowercase

### Type
- feat: new feature
- fix: bug fix
- style: style adjustments
- refactor: code refactoring
- docs: documentation
- chore: tooling/build

### Examples
- feat: add header
- fix: button color
- style: adjust spacing
- refactor: extract utils

## Commands

```bash
git add .
git commit -m "<generated message>"
```

Show commit hash when done.
