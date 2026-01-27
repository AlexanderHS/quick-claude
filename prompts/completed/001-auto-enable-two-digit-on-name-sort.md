<objective>
Modify quick-claude.sh so that pressing 's' to sort by name automatically enables two-digit mode (same as pressing 'n').

This makes it easier to quickly jump to repos by number when viewing an alphabetically sorted list, since name-sorted lists benefit most from numbered navigation.
</objective>

<context>
File to modify: `./quick-claude.sh`

Current behavior:
- 's' key toggles between date sort and name sort
- 'n' key separately toggles two-digit mode (shows 01-99 instead of 1-9)
- These are independent operations

Desired behavior:
- When 's' switches TO name sort: automatically enable two-digit mode (set `two_digit_mode=1`)
- When 's' switches TO date sort: no change to two-digit mode (leave it as-is)
- The 'n' key should still work independently to toggle two-digit mode on/off
</context>

<implementation>
Locate the 's' key handler (around line 227-239) and add a single line to set `two_digit_mode=1` when switching to name sort:

```bash
elif [[ $key == 's' ]]; then
    # Toggle sort mode
    if [[ $sort_mode -eq $SORT_BY_DATE ]]; then
        sort_mode=$SORT_BY_NAME
        two_digit_mode=1  # <-- ADD THIS LINE
    else
        sort_mode=$SORT_BY_DATE
    fi
    # ... rest unchanged
```

This is a one-line addition. Do not modify any other behavior.
</implementation>

<verification>
After making the change:
1. Source the script and verify 's' when switching to name sort shows two-digit numbers (01, 02, etc.)
2. Verify 's' back to date sort preserves whatever two-digit mode state exists
3. Verify 'n' still toggles two-digit mode independently
</verification>

<success_criteria>
- Single line added: `two_digit_mode=1` inside the name-sort branch
- No other changes to the file
- Existing 'n' key functionality unchanged
</success_criteria>
