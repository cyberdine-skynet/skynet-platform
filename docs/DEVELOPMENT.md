# Development Setup

This document explains how to set up your development environment for the Skynet Platform.

## Pre-commit Hooks

The Skynet Platform uses pre-commit hooks to ensure code quality and consistency. These hooks run automatically
before each commit to catch issues early.

### Installation

1. **Install pre-commit** (if not already installed):

   ```bash
   pip install pre-commit
   # or
   brew install pre-commit
   ```

2. **Install the hooks** in your local repository:

   ```bash
   cd skynet-platform
   pre-commit install
   ```

3. **Install commit message hook** (optional):

   ```bash
   pre-commit install --hook-type commit-msg
   ```

### Available Hooks

Our pre-commit configuration includes the following hooks:

#### Code Quality

- **trailing-whitespace**: Removes trailing whitespace
- **end-of-file-fixer**: Ensures files end with a newline
- **check-yaml**: Validates YAML syntax (allows Kubernetes custom tags)
- **check-added-large-files**: Prevents large files from being committed
- **check-merge-conflict**: Detects merge conflict markers
- **check-case-conflict**: Prevents case conflicts on case-insensitive filesystems

#### YAML Linting

- **yamllint**: Comprehensive YAML linting with custom configuration
- Configuration file: `.yamllint.yml`
- Allows up to 120 character lines
- Supports Kubernetes YAML patterns

#### Markdown Linting

- **markdownlint**: Markdown style and syntax checking
- Configuration file: `.markdownlint.yml`
- Automatically fixes many issues
- Supports documentation-friendly rules

#### Docker

- **hadolint**: Dockerfile linting and best practices
- Ignores certain rules appropriate for our use case
- Ensures secure and efficient Docker images

#### Security

- **detect-secrets**: Scans for potential secrets in code
- Configuration file: `.secrets.baseline`
- Prevents accidental credential commits

#### Shell Scripts

- **shellcheck**: Shell script linting and best practices
- Catches common shell scripting errors
- Improves script reliability

### Running Hooks

#### Automatic (Recommended)

Hooks run automatically on every commit. If a hook fails, the commit is blocked until issues are fixed.

#### Manual Execution

```bash
# Run all hooks on staged files
pre-commit run

# Run all hooks on all files
pre-commit run --all-files

# Run specific hook on all files
pre-commit run yamllint --all-files

# Run specific hook on specific files
pre-commit run markdownlint --files README.md
```

### Configuration Files

#### `.yamllint.yml`

```yaml
extends: default
rules:
  line-length:
    max: 120
    level: warning
  truthy:
    allowed-values: ['true', 'false', 'yes', 'no', 'on', 'off']
    check-keys: false
```

#### `.markdownlint.yml`

```yaml
default: true
MD013:  # Line length
  line_length: 120
MD033: false  # Allow inline HTML
MD041: false  # First line doesn't need to be heading
```

#### `.secrets.baseline`

Generated baseline file for detect-secrets. Update when adding legitimate "secrets" like example configurations.

### Bypassing Hooks (Not Recommended)

In rare cases where you need to bypass hooks:

```bash
# Skip all hooks (emergency use only)
git commit --no-verify -m "emergency fix"

# Skip specific hook
SKIP=yamllint git commit -m "skip yamllint for this commit"
```

### Updating Hooks

Keep hooks up to date with:

```bash
pre-commit autoupdate
```

This updates hook versions in `.pre-commit-config.yaml`.

### Troubleshooting

#### Hook Installation Issues

```bash
# Clear pre-commit cache
pre-commit clean

# Reinstall hooks
pre-commit install --install-hooks
```

#### YAML Validation Errors

- Check indentation (2 spaces)
- Verify custom tags are allowed in config
- Test with: `yamllint <file>`

#### Markdown Issues

- Check line length (max 120 characters)
- Verify heading structure
- Test with: `markdownlint <file>`

#### Docker Issues

- Ensure Dockerfile follows best practices
- Check hadolint rules: `hadolint Dockerfile`

#### Secret Detection Issues

```bash
# Update baseline after reviewing flagged items
detect-secrets scan --baseline .secrets.baseline
```

### IDE Integration

#### VS Code

Install extensions for better integration:

- **YAML**: Red Hat YAML extension
- **Markdown**: markdownlint extension
- **Docker**: Docker extension
- **Shell**: shellcheck extension

#### Configuration

VS Code settings for consistent formatting:

```json
{
  "yaml.format.enable": true,
  "yaml.format.singleQuote": false,
  "markdown.lint.enabled": true,
  "[yaml]": {
    "editor.defaultFormatter": "redhat.vscode-yaml"
  },
  "[markdown]": {
    "editor.defaultFormatter": "DavidAnson.vscode-markdownlint"
  }
}
```

### Best Practices

1. **Run hooks frequently**: Don't wait until commit time
2. **Fix issues promptly**: Address hook failures immediately
3. **Keep configs updated**: Regular `pre-commit autoupdate`
4. **Document exceptions**: If bypassing hooks, document why
5. **Review baseline files**: Regularly review `.secrets.baseline`

### Git Workflow with Pre-commit

```bash
# Standard workflow
git add .
git commit -m "feat: add new feature"  # Hooks run automatically

# If hooks fail
# Fix the issues reported
git add .
git commit -m "feat: add new feature"  # Try again

# Check what would run
pre-commit run --all-files
```

### Commit Message Format

We follow conventional commits:

```
type(scope): description

feat(api): add new endpoint
fix(auth): resolve login issue
docs(readme): update installation steps
style(css): fix formatting
refactor(db): optimize queries
test(unit): add user service tests
chore(deps): update dependencies
```

### Getting Help

- **Pre-commit docs**: <https://pre-commit.com/>
- **Hook issues**: Check individual tool documentation
- **Platform team**: #skynet-platform Slack channel
- **Repository issues**: Create GitHub issue

Remember: Pre-commit hooks are there to help maintain code quality and catch issues early. Embrace them as part of
the development workflow!
