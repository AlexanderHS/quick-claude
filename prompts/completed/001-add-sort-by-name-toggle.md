<objective>
Add a keyboard shortcut to toggle between sorting repositories by last commit date (current default) and sorting alphabetically by name.

The user has ~40 repositories and wants to quickly find repos by name when the date-sorted view isn't helpful.
</objective>

<context>
This is quick-claude, a bash-based interactive launcher that displays repositories in an arrow-key menu.

Current behavior:
- Repos are always sorted by last commit date (most recent at top)
- User navigates with arrow keys or number shortcuts
- 'n' key toggles two-digit mode for repos 10+

@quick-claude.sh - the main script to modify
@CLAUDE.md - project conventions
</context>

<requirements>
1. Add a keyboard shortcut to toggle sort order between:
   - **Date sort** (current default): Most recently committed repos at top
   - **Name sort**: Alphabetical A-Z

2. Use 's' as the toggle key (intuitive for "sort")

3. Update the help text on line 133 to mention the new shortcut

4. Show a visual indicator of current sort mode somewhere in the UI (e.g., in the header or help text)

5. Preserve the current date sort as the default on startup
</requirements>

<implementation>
Use readonly constants instead of magic strings for sort mode (bash enum pattern):

```bash
readonly SORT_BY_DATE=0
readonly SORT_BY_NAME=1
sort_mode=$SORT_BY_DATE
```

- Use `$SORT_BY_DATE` and `$SORT_BY_NAME` in all comparisons
- Create a function to re-sort the arrays based on current mode
- Modify the key handler to detect 's' and toggle + redraw
- Keep the existing sorting logic but make it switchable

Sorting approach for name mode:
- Sort `sorted_repos` array alphabetically (case-insensitive preferred)
- Keep `sorted_dates` array in sync with the repo ordering

Avoid:
- Don't break existing keyboard shortcuts (1-9, n, arrows, Enter, Escape)
- Don't re-read from filesystem on toggle - just re-sort the already-loaded arrays
- Don't use magic strings like "date" or "name" - always use the constants
</implementation>

<output>
Modify: `./quick-claude.sh`
</output>

<verification>
After implementation, mentally trace through:
1. Script starts → repos sorted by date (most recent first)
2. Press 's' → repos re-sort alphabetically, UI updates, indicator shows "name"
3. Press 's' again → repos re-sort by date, indicator shows "date"
4. Arrow keys and number selection still work correctly after toggle
5. Selected repo follows correctly when sort changes (cursor stays on same repo or resets to top - either is acceptable)
</verification>

<success_criteria>
- Pressing 's' toggles between date and alphabetical sorting
- Visual indicator shows current sort mode
- Help text updated to mention 's' shortcut
- All existing functionality preserved
- No flickering or display glitches on toggle
</success_criteria>
