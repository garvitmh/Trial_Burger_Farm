# GIT WORKFLOW

## Branching Strategy
- **`main`**: Production/demo-safe code only.
- **`staging`**: Integration testing environment.
- **`dev`**: Main development branch where features are consolidated.
- **`feature/*`**: All active development begins here. 

## Rules
- **All work begins in feature branches** branched from `dev`.
- Pull Requests must merge into `dev`.
- Commits must use Conventional Commits format.
- DO NOT push code automatically.
- DO NOT expose tokens.
- DO NOT store secrets in files.

## Conventional Commits
All commit messages should follow this specification:
- `feat:` A new feature
- `fix:` A bug fix
- `refactor:` A code change that neither fixes a bug nor adds a feature
- `chore:` Changes to the build process or auxiliary tools/libraries
- `docs:` Documentation only changes
- `style:` Changes that do not affect the meaning of the code (white-space, formatting)
- `test:` Adding missing tests or correcting existing tests
