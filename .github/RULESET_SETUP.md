# GitHub Rulesets 설정 가이드

## 🔐 GitHub Rulesets vs Branch Protection Rules

GitHub는 2023년부터 **Rulesets**라는 새로운 브랜치 보호 시스템을 도입했으며, 2025년 현재 안정화된 기능입니다. 기존의 Branch Protection Rules와 함께 사용할 수 있으며, 더 강력하고 유연한 기능을 제공합니다.

### 📊 Rulesets의 장점

1. **다중 규칙 적용**: 여러 ruleset이 동시에 적용 가능
2. **상태 관리**: Active/Disabled/Evaluate 모드 지원
3. **투명성**: 읽기 권한만 있어도 규칙 확인 가능
4. **고급 규칙**: 커밋 메타데이터, 파일 경로 제한 등

## 🚀 Flutter Live Logger용 Ruleset 설정

### 1️⃣ Main Branch Ruleset 생성

**경로**: Repository → Settings → Rules → Rulesets → New branch ruleset

#### 기본 설정

- **Ruleset name**: `Main Branch Protection`
- **Enforcement status**: `Active`
- **Target branches**: `main`

#### Branch Protections

```yaml
✅ Require a pull request before merging
  ├── Required approvals: 1
  ├── Dismiss stale PR approvals when new commits are pushed
  ├── Require review from Code Owners
  └── Require approval of the most recent reviewable push

✅ Require status checks to pass before merging
  ├── Require branches to be up to date before merging
  └── Required status checks:
      - PR Validation / 🔍 PR Validation
      - PR Validation / 📏 PR Size Check
      - PR Validation / 🔗 Dependency Check

✅ Require conversation resolution before merging

✅ Require signed commits

✅ Require linear history

❌ Lock branch (Allow development)
```

#### Bypass Permissions

- **Repository administrators**: For emergency fixes only
- **GitHub Apps**: Dependabot (for dependency updates)

### 2️⃣ Development Branch Ruleset

**Ruleset name**: `Development Branch Protection`
**Target branches**: `develop`, `feature/*`, `fix/*`

#### Relaxed Rules for Development

```yaml
✅ Require a pull request before merging
  └── Required approvals: 1 (코드 소유자 리뷰 선택)

✅ Require status checks to pass before merging
  └── Required status checks:
      - PR Validation / 🔍 PR Validation

✅ Require conversation resolution before merging

❌ Require signed commits (개발 편의성)
❌ Require linear history (유연한 개발)
```

### 3️⃣ Release Branch Ruleset

**Ruleset name**: `Release Branch Protection`
**Target branches**: `release/*`, `hotfix/*`

#### 엄격한 릴리스 규칙

```yaml
✅ Require a pull request before merging
  ├── Required approvals: 2 (더 엄격한 리뷰)
  ├── Dismiss stale PR approvals when new commits are pushed
  ├── Require review from Code Owners
  └── Require approval of the most recent reviewable push

✅ Require status checks to pass before merging
  ├── Require branches to be up to date before merging
  └── All PR validation checks

✅ Require conversation resolution before merging
✅ Require signed commits
✅ Require linear history

🔒 Restrict pushes that create matching branches
```

## 🛠️ 설정 단계별 가이드

### Step 1: Repository Settings 접근

1. GitHub repository → **Settings** 탭
2. 좌측 사이드바 → **Code and automation** → **Rules**
3. **Rulesets** 클릭

### Step 2: Main Branch Ruleset 생성

1. **New branch ruleset** 클릭
2. **Ruleset name**: `Main Branch Protection`
3. **Enforcement status**: `Active` 선택
4. **Target branches** → **Add a target** → `main` 입력

### Step 3: Branch Protections 설정

```yaml
Branch protections:
  ✅ Require a pull request before merging
    - Required number of approvals: 1
    - ✅ Dismiss stale pull request approvals when new commits are pushed
    - ✅ Require review from Code Owners
    - ✅ Require approval of the most recent reviewable push

  ✅ Require status checks to pass before merging
    - ✅ Require branches to be up to date before merging
    - Status checks to require:
      * PR Validation / 🔍 PR Validation
      * PR Validation / 📏 PR Size Check
      * PR Validation / 🔗 Dependency Check

  ✅ Require conversation resolution before merging
  ✅ Require signed commits
  ✅ Require linear history
```

### Step 4: Bypass Permissions 설정

1. **Bypass list** → **Add bypass**
2. Repository administrators 추가
3. **For pull requests only** 설정 (직접 푸시 방지)

### Step 5: 커밋 메타데이터 제한 (선택사항)

```yaml
Restrictions:
  ✅ Restrict commit metadata
    - Commit message must match: ^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}
    - Requirement: Must match a given regex pattern
    
  ✅ Restrict branch names
    - Branch name must match: ^(main|develop|feature/.+|fix/.+|release/.+|hotfix/.+)$
    - Requirement: Must match a given regex pattern
```

## 📋 권장 Ruleset 구성

### 🔥 Production Level (main)

- ✅ PR 필수 (리뷰 1명)
- ✅ 코드 소유자 리뷰
- ✅ 모든 CI 통과
- ✅ 서명된 커밋
- ✅ 선형 히스토리
- ✅ 대화 해결

### 🚧 Development Level (feature/*, develop)

- ✅ PR 필수 (리뷰 1명)
- ✅ 기본 CI 통과
- ❌ 서명된 커밋 (선택)
- ❌ 선형 히스토리 (유연성)

### 🚀 Release Level (release/*, hotfix/*)

- ✅ PR 필수 (리뷰 2명)
- ✅ 코드 소유자 리뷰
- ✅ 모든 CI 통과
- ✅ 서명된 커밋
- ✅ 선형 히스토리
- ✅ 브랜치 생성 제한

## 🔍 Ruleset 상태 모니터링

### Active Mode

- 규칙이 즉시 적용됨
- 위반 시 작업 차단

### Evaluate Mode (테스트용)

- 규칙을 적용하지 않음
- "Rule Insights"에서 위반 사항 확인 가능
- 새 규칙 테스트에 유용

### Disabled Mode

- 규칙이 비활성화됨
- 임시로 규칙 해제 시 사용

## 🔧 CLI로 Ruleset 관리 (선택사항)

GitHub CLI를 사용한 자동화:

```bash
# Ruleset 목록 확인
gh api repos/curogom/flutter_live_logger/rulesets

# Ruleset 상세 정보
gh api repos/curogom/flutter_live_logger/rulesets/RULESET_ID

# Ruleset 생성 (JSON 파일 필요)
gh api repos/curogom/flutter_live_logger/rulesets \
  --method POST \
  --input ruleset.json
```

## 🚨 주의사항

1. **기존 Branch Protection Rules와 병행 사용 가능**
   - Rulesets와 기존 규칙이 함께 적용됨
   - 더 엄격한 규칙이 우선 적용

2. **Bypass 권한 신중 관리**
   - 최소한의 사용자에게만 부여
   - "For pull requests only" 권장

3. **단계적 적용**
   - 먼저 "Evaluate" 모드로 테스트
   - 문제없으면 "Active"로 전환

## 📈 모범 사례

### 💡 권장 워크플로우

1. **Feature Branch** → PR → **Develop**
2. **Develop** → PR → **Main** (릴리스 준비)
3. **Hotfix** → PR → **Main** (긴급 수정)

### 🎯 규칙 적용 우선순위

1. **보안**: 서명된 커밋, 리뷰 필수
2. **품질**: CI 통과, 코드 리뷰
3. **일관성**: 커밋 메시지, 브랜치 명명
4. **안정성**: 선형 히스토리, 대화 해결

---

**설정 완료 후 확인사항**:

- [ ] Main branch ruleset 활성화
- [ ] PR template 작동 확인  
- [ ] CI/CD 워크플로우 통과 확인
- [ ] 코드 소유자 자동 할당 확인
- [ ] Bypass 권한 최소화 확인

이제 전문적인 오픈소스 프로젝트의 브랜치 보호 체계가 완성되었습니다! 🎉
