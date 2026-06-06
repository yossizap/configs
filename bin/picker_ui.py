import curses


def add_text(window, row, col, text, limit, attr=curses.A_NORMAL):
    height, width = window.getmaxyx()
    if row < 0 or row >= height or col < 0 or col >= width or limit <= 0:
        return
    window.addnstr(row, col, text, min(limit, width - col), attr)


def draw_panel_border(window, top, left, height, width, title, active=False):
    attr = curses.A_BOLD if active else curses.A_NORMAL
    right = left + width - 1
    bottom = top + height - 1
    add_text(window, top, left, "+" + "-" * max(0, width - 2) + "+", width, attr)
    for row in range(top + 1, bottom):
        add_text(window, row, left, "|", 1, attr)
        add_text(window, row, right, "|", 1, attr)
    add_text(window, bottom, left, "+" + "-" * max(0, width - 2) + "+", width, attr)
    add_text(window, top, left + 2, f" {title} ", max(0, width - 4), attr)
