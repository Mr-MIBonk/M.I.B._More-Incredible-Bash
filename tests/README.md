# M.I.B. Test Suite

Test suite for validating bug fixes in the M.I.B. (More Incredible Bash) project.

## Test Files

### `test_lock_files.sh`
Comprehensive test suite for lock file management fixes in critical scripts.

**Tests Covered:**
- ✅ Lock file immediate creation (race condition prevention)
- ✅ Race condition prevention (multiple instances)
- ✅ Normal exit cleanup
- ✅ SIGTERM signal cleanup
- ✅ SIGINT signal cleanup (Ctrl+C)
- ✅ Syntax validation of modified files
- ⚠️  Manual flash validation test instructions

## Running Tests

### Quick Start
```bash
# Run all tests
./tests/test_lock_files.sh

# See help
./tests/test_lock_files.sh --help
```

### Expected Output
```
==========================================
M.I.B. Lock File Management Tests
==========================================
Workspace: /Users/versusha/Documents/MIB2/M.I.B._More-Incredible-Bash

==========================================
TEST: Syntax check on modified files
==========================================
Checking esd/scripts/svm.sh... OK
Checking apps/svm... OK
Checking apps/flash... OK
Checking apps/backup... OK
✅ PASS: Syntax validation of modified files

[... more tests ...]

==========================================
Test Results
==========================================
Passed: 6
Failed: 0
==========================================

✅ All automated tests passed!

Next steps:
1. Run manual flash validation test
2. Test on actual MIB hardware if possible
3. Create pull request
```

## Test Requirements

### System Requirements
- Bash 4.0 or higher
- Standard Unix tools (ps, pgrep, pkill, kill, sleep)
- Write access to `/tmp` and `/net/rcc/dev/shmem`

### Modified Files Being Tested
- `esd/scripts/svm.sh`
- `apps/svm`
- `apps/flash`
- `apps/backup`

## Manual Tests

### Flash Validation Test
The flash validation bug fix requires manual testing on actual hardware:

1. **Setup:**
   ```bash
   # Create corrupted flash file
   cp valid.ifs /tmp/corrupted.ifs
   dd if=/dev/zero of=/tmp/corrupted.ifs bs=1024 count=1 conv=notrunc
   ```

2. **Run:**
   ```bash
   # Modify apps/flash to point to corrupted file
   ./apps/flash -p
   ```

3. **Verify:**
   - Flash validation FAILED message appears
   - Script exits with code 1: `echo $?` 
   - Reboot does NOT proceed
   - Lock file cleaned up: `ls /net/rcc/dev/shmem/flash.mib`

4. **Expected Results:**
   - Exit code: `1` (error)
   - Before fix: `0` (success - DANGEROUS!)
   - Unit should NOT reboot with corrupted flash

## Test Coverage

### What's Tested Automatically
✅ Lock file creation timing  
✅ Race condition prevention  
✅ Normal exit cleanup  
✅ Signal handling (SIGTERM, SIGINT)  
✅ Syntax validation  

### What Requires Manual Testing
⚠️ Flash validation on actual hardware  
⚠️ Real-world race condition stress testing  
⚠️ Power loss during operations  
⚠️ Testing on actual MIB units  

## Troubleshooting

### Test Fails: "Lock file NOT created"
**Cause:** `/net/rcc/dev/shmem` doesn't exist or isn't writable  
**Fix:** Update `TMP` variable in test script to use `/tmp` instead

### Test Fails: "SYNTAX ERROR"
**Cause:** Modified files have shell syntax errors  
**Fix:** Review the specific file mentioned and fix syntax issues

### Test Fails: "Multiple instances running"
**Cause:** Race condition not properly fixed or cleanup issue  
**Fix:** Review lock file creation timing in the failing script

## CI/CD Integration

To run these tests automatically in a CI/CD pipeline:

```yaml
# .github/workflows/test.yml
name: M.I.B. Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Tests
        run: |
          chmod +x tests/test_lock_files.sh
          ./tests/test_lock_files.sh
```

## Contributing

When adding new tests:
1. Follow existing test naming: `test_<feature>_<scenario>()`
2. Use `print_test_header()` and `print_result()` for consistency
3. Clean up any resources in test cleanup
4. Update this README with new test descriptions

## Bug References

These tests validate fixes for:
- 🚨 **Bug #1-3:** Race conditions in lock file management (CRITICAL)
- 🚨 **Bug #62:** Flash validation exits with wrong code (CRITICAL)
- 🔴 **Bug #46-60:** Missing lock file cleanup (HIGH)
- 🔴 **Bug #61:** Inadequate trap handlers (HIGH)

See the main bug report for full details.

## License

Same license as M.I.B. - GNU General Public License v2.0
