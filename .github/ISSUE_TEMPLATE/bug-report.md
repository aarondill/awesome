---
name: Bug report
about: Create a report to help us improve
title: "[BUG]"
labels: ''
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Version Info:**
 - OS: 
 - `nvim --version`: 
- Tabnine Binary:

This command will usually list all the versions and the current:
```shell
> ls -A -- "$(nvim --headless -c 'lua io.stdout:write(vim.fn.stdpath("data"))' -c qa)"/*/tabnine-nvim/binaries/
> cat -- "$(nvim --headless -c 'lua io.stdout:write(vim.fn.stdpath("data"))' -c qa)"/*/tabnine-nvim/binaries/.active
```

**Additional context**
Add any other context about the problem here.
