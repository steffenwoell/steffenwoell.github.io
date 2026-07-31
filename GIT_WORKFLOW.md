# Git Workflow (VS Code)

## Branches

### main
Stable production branch.

- Live website / stable app
- Never develop directly on this branch

### testing
Daily development.

Everything new happens here first.

### feature/*
Optional branch for larger experiments.

Examples:

- feature/logo
- feature/redesign
- feature/blog

---

# Daily Workflow

## 1. Switch to testing

Bottom left in VS Code:

```
main
```

↓

Click

↓

```
testing
```

---

## 2. Develop

Edit files as usual.

Preview locally:

```bash
bundle exec jekyll serve
```

(or simply run the app for Swift projects)

---

## 3. Review changes

Open

```
Source Control
```

Look through the changed files.

---

## 4. Stage

Usually:

```
Stage All Changes
```

or click

```
+
```

next to individual files.

---

## 5. Commit

Write a meaningful message.

Examples:

```
Add new homepage layout

Fix menu animation

Improve dark mode

Update logo
```

Commit.

---

## 6. Push

Click

```
Sync Changes
```

or

```
Push
```

---

# Publish

After testing everything locally:

Switch to

```
main
```

↓

Source Control

↓

...

↓

Branch

↓

Merge Branch...

↓

Select

```
testing
```

↓

Push

GitHub Pages now publishes the new version.

---

# Afterwards

Immediately switch back to

```
testing
```

Continue development there.

---

# Publish Branch

When VS Code asks

```
Publish Branch
```

choose

```
origin
```

This uploads the branch to GitHub.

It does NOT affect the live website.

---

# Undo

## Undo last commit (keep changes)

Terminal:

```bash
git reset --soft HEAD~1
```

## Discard all local changes

```
...
```

↓

```
Discard All Changes
```

or

```bash
git restore .
```

---

# New Feature

Switch to

```
testing
```

↓

Bottom left

↓

Create New Branch

Example:

```
feature/new-logo
```

Work normally.

When finished:

Switch to

```
testing
```

↓

Merge

```
feature/new-logo
```

↓

Delete feature branch.

---

# Rules

✅ Work on `testing`

✅ Commit often

✅ Push regularly

✅ Keep `main` stable

❌ Never edit directly on `main`

---

# Workflow

```
main
        ▲
        │
     Merge
        │
testing
        ▲
        │
 Commit
        │
 Develop
```