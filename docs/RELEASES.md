# Release Process

## Creating a New Release

### 1. Update Version

Edit `src/frontend/pubspec.yaml`:
```yaml
version: X.Y.Z+BUILD
```

Follow semantic versioning:
- `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- Example: `1.0.0+1`

### 2. Create Feature Branch
```bash
git checkout -b release/vX.Y.Z
```

### 3. Update Changelog

Add changes to `CHANGELOG.md`

### 4. Create Pull Request

Merge to `main` branch

### 5. Create Git Tag
```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z: Description"
git push origin vX.Y.Z
```

### 6. Create GitHub Release

Go to GitHub → Releases → Create new release

---

## Version History

### v1.0.0 (2025-01-XX)
- Initial release with authentication
- User profiles with avatars
- Notes feature