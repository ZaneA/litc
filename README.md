Litc
===

A utility to compile/interpret literate programs.

See `litc_bootstrap.rb` for a runnable utility; run it against `litc.rb.md` to generate a new utility from the canonical source (a literate program itself).

I'm not terribly good at the literate style yet, but I like it, and this was a fun little utility to hack together. It should work for most if not all languages (that I can think of at least). Also, global variables.

Usage
---

1. Write your literate program in markdown, save it as source.ext.md
2. Make sure that the first code block in your is simply the command line used to run the source. i.e. `ruby` or `gcc -o myprogram`. The source filename will be appended.
3. Run `litc ./source.ext.md` and see the output.
4. Open `source.ext.html` in your browser :)

From the source:

    Run literate programs.
    Usage: litc [-n] <file> [--] [additional arguments]
    If -n is passed on the command line, the resulting code will not be executed.
    Arguments can be passed to the resulting code after a double dash.
