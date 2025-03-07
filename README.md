# BatchParserJava

A Java program that generates Windows batch files based on an input text file. When executed, these batch files recreate the original text files.

This task is more challenging than it seems due to the need to escape special characters in batch scripts. Combined with variable expansion, this makes batch scripting quite tricky.

When trying to understand and solve this two years ago, I found myself deep in the Windows command-line rabbit hole, half of which was so fucked up, i cant even remember it.


<details>
<summary>Want a taste of the madness?</summary>

Check out this Stack Overflow thread on batch character escaping:

> [Batch Character Escaping](https://stackoverflow.com/questions/6828751/batch-character-escaping)

```



As dbhenham points out in this comment, a (MUCH) more detailed answer can be found in portions of this answer (originally by another user jeb and significantly edited and updated by dbhenham since) on a related but much more general question:

    parsing - How does the Windows Command Interpreter (CMD.EXE) parse scripts? - Stack Overflow

Note that, per dbhenham, this answer is:

    incorrect, misleading, and incomplete

I think this answer is still good enough, for almost all cases, but a careful reading of the above answer might be warranted depending on one's exact character escaping needs and the limitations of this answer.

The remaining has been adapted with permission of the author from the page Batch files - Escape Characters on Rob van der Woude's Scripting Pages site.
TLDR

Windows (and DOS) batch file character escaping is complicated:

        Much like the universe, if anyone ever does fully come to understand Batch then the language will instantly be replaced by an infinitely weirder and more complex version of itself. This has obviously happened at least once before ;)

Percent Sign %

% can be escaped as %% – "May not always be required [to be escaped] in doublequoted strings, just try"
Generally, Use a Caret ^

These characters "may not always be required [to be escaped] in doublequoted strings, but it won't hurt":

    ^
    &
    <
    >
    |

Example: echo a ^> b to print a > b on screen

' is "required [to be escaped] only in the FOR /F "subject" (i.e. between the parenthesis), unless backq is used"

` is "required [to be escaped] only in the FOR /F "subject" (i.e. between the parenthesis), if backq is used"

These characters are "required [to be escaped] only in the FOR /F "subject" (i.e. between the parenthesis), even in doublequoted strings":

    ,
    ;
    =
    (
    )

Double Escape Exclamation Points when Using Delayed Variable Expansion

! must be escaped ^^! when delayed variable expansion is active.
Double Double-Quotes in find Search Patterns

" → ""
Use a Backslash in findstr Regex Patterns

    \
    [
    ]
    "
    .
    *
    ?

Also

Rob commented further on this question (via email correspondence with myself):

    As for the answer, I'm afraid the chaos is even worse than the original poster realizes: requirements for escaping parentheses also depend on the string being inside a code block or not!

    I guess an automated tool could just insert a caret before every character, then doubling all percent signs - and it would still fail if the string is doublequoted!

Further, individual programs are responsible for parsing their command line arguments so some of the escaping required for, e.g. for sed or ssed, may be due to the specific programs called in the batch scripts.
```

</details>

## Compilation & Execution

```bash
#compile all class files, conveniently no sibling or child packages to worry about
javac -d bin -sourcepath src src/de/grnx/parser/*.java

# Run the main class
java -cp bin de.grnx.parser.Main
```