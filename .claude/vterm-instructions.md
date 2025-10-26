## vterm cursor behavior

Normally, emacs shows a window has focus by making the cursor a solid
rectangle, while an out-of-focus window has a rectangle with a border
only. Furthermore, the cursor is set to the color specified in
e.g. .Xresources or .Xdefaults, or as set in the emacs init files. All this
applies to a regular vterm window also.

However, when I open up claude-code, the cursor is always a solid rectangle,
whether the window is in focus or not, and the cursor color is same as that of
the text. This removes a critical visual clue about whether I am in the
claude-code window or not.

Please see if this can be fixed.

