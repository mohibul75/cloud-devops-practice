# Trunk-Based Development Strategy

This document outlines my streamlined branching strategy focused on rapid development and direct integration.

## Overview

I employ a simplified trunk-based development model with `main` as my primary branch, emphasizing quick feature delivery and immediate integration.

```
main ─────────●─────────●─────────●─────────●─────── (stable)
              │         │         │         │
feature-1     └─●─●─●──┘         │         │
                                 │         │
feature-2                        └─●─●─●───┘
                                          │
hotfix                                    └─●─┘
```

## Branch Types

### Main Branch (`main`)
- Single source of truth for production code
- Always stable and deployable
- All feature and hotfix branches merge directly into `main`
- Protected branch requiring pull request approvals

### Feature Branches (`feature/*`)
- Created from: `main`
- Merged into: `main`
- Naming convention: `feature/brief-description`
- Short-lived branches (typically 1-3 days)
- Deleted after merging

### Hotfix Branches (`fix/*`)
- Created from: `main`
- Merged into: `main`
- Naming convention: `fix/issue-description`
- Used for urgent production fixes
- Extremely short-lived (usually same-day fixes)
- Deleted after merging

## Workflow

1. **Feature Development**
   ```bash
   # Create feature branch
   git checkout main
   git pull
   git checkout -b feature/new-feature
   
   # Make changes and commit
   git add .
   git commit -m "feat: add new feature"
   
   # Push and create PR
   git push origin feature/new-feature
   ```

2. **Hotfix Process**
   ```bash
   # Create hotfix branch
   git checkout main
   git pull
   git checkout -b hotfix/critical-fix
   
   # Fix and commit
   git add .
   git commit -m "fix: resolve critical issue"
   
   # Push and create PR
   git push origin hotfix/critical-fix
   ```

## Merging Guidelines

1. **Pull Request Requirements**
   - Clean, focused commits
   - Passing CI/CD pipeline
   - Code review approval by AI
   - Up-to-date with `main`

2. **Commit Message Format**
   ```
   type(scope): subject
   
   body (optional)
   ```
   Types:
   - feat: New feature
   - fix: Bug fix
   - docs: Documentation changes
   - style: Formatting changes
   - refactor: Code restructuring
   - test: Adding tests
   - chore: Maintenance tasks

## Benefits

- **Simplicity**: Single stable branch reduces complexity
- **Speed**: Direct merging enables faster delivery
- **Quality**: All changes reviewed before reaching main
- **Clarity**: Short-lived branches prevent merge conflicts
- **Flexibility**: Quick response to issues via hotfix branches

## Pull Request Process

### PR Template
```markdown
## Description
[Brief description of changes]

## Type of Change
- [ ] Feature (new functionality)
- [ ] Fix (bug fix)
- [ ] Docs (documentation only)
- [ ] Refactor (code improvement)
- [ ] Test (adding tests)
- [ ] Chore (maintenance)

## Testing Done
[Describe testing performed]

## Related Issues
Closes #[issue-number]
```

### Review Requirements
1. **Code Quality**
   - Passes automated CI checks
   - Follows project coding standards
   - Contains appropriate tests
   - Documentation updated

2. **AI Review Process**
   - Uses CodeRabbit AI for automated review
   - All critical AI suggestions addressed
   - Security recommendations implemented
   - Performance improvements considered

## AI-Driven Development

I use [CodeRabbit AI](https://www.coderabbit.ai/) for automated code reviews in this project. This ensures consistent code quality and helps maintain best practices even in a self-maintained project.

### AI Review Features
- Automated code quality checks
- Security vulnerability scanning
- Performance optimization tips
- Style consistency enforcement
- Documentation completeness verification

### Review Workflow
1. Create PR following template
2. Wait for CodeRabbit AI analysis
3. Address critical AI suggestions
4. Merge if all checks pass

This AI-driven approach helps maintain high code quality while keeping the development process streamlined and efficient.