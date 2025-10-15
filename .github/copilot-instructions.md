# Copilot Instructions for ImageMagick Build

## Version Management Guidelines

### When updating the `imagemagick-version` file with a new version:

1. **Check for override scripts**: Remember that additional `debs/after-checkout-*.sh` override files may need to be created or updated for the new version.
   - These files follow the pattern: `after-checkout-ubuntu{version}-{imagemagick-version}.sh`
   - Ensure compatibility with different Ubuntu versions (18.04, 20.04, 24.04, etc.)

2. **Reset release version**: The `release-version` file needs to be reset to `1` when updating to a new ImageMagick version.

3. **Increment release version**: If the ImageMagick version remains the same, the `release-version` file needs to be increased (incremented by 1).

## File Dependencies

- `imagemagick-version`: Contains the ImageMagick version number
- `release-version`: Contains the release number for the current ImageMagick version
- `debs/after-checkout-*.sh`: Version-specific override scripts for different Ubuntu versions

## Workflow Summary

1. Update `imagemagick-version` with new version
2. If new version: Reset `release-version` to `1`
3. If same version: Increment `release-version`
4. Check/create/update corresponding `debs/after-checkout-*.sh` files as needed