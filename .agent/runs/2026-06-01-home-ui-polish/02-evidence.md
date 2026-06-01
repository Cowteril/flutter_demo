# Evidence

## Screenshot Findings

- The filter row has unreadable unselected chips because chip background and text both appear light.
- The full list starts immediately after the featured row; a heading/count would make the page easier to scan.

## Code Findings

- `_FilterBar` used `selectedColor` and `backgroundColor`, which can still be overridden by Material chip state/theme behavior.
- `DramaHomePage` already computes `filtered`, so a list count can be rendered without extra data work.
