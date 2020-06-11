# math-fun Nu plugin commmand

## Getting started

Make sure you have a working Ruby environment, your working directory should be `examples/math-fun`.

Run `bundle`:

```shell
math-fun $ bundle
```

`path/to/nu_plugin/examples/math-fun/bin` needs to be in the `PATH` like so:

```shell
$ export PATH="path/to/nu_plugin/examples/math-fun/bin:$PATH"
```

To be able to run Nu you need the Nu binary in the `PATH` as well (or run it directly `path/to/nu`)

Confirm it picks up the plugin by using Nu's `help` command:

```shell
math-fun $ export PATH="/Users/andrasio/Code/nu_plugin/examples/math-fun/bin:$PATH"
math-fun $ nu
/Users/andrasio/Code/nu_plugin/examples/math-fun(master)> help math-fun
Shows a table of values for f(x) = x + 2

Usage:
  > math-fun
```

Now run `math-fun`:

```shell
/Users/andrasio/Code/nu_plugin/examples/math-fun(master)> math-fun
━━━━┯━━━━┯━━━━
 #  │ x  │ y
────┼────┼────
  0 │  1 │  2
  1 │  2 │  4
  2 │  3 │  6
  3 │  4 │  8
  4 │  5 │ 10
  5 │  6 │ 12
  6 │  7 │ 14
  7 │  8 │ 16
  8 │  9 │ 18
  9 │ 10 │ 20
 10 │ 11 │ 22
 11 │ 12 │ 24
 12 │ 13 │ 26
 13 │ 14 │ 28
 14 │ 15 │ 30
 15 │ 16 │ 32
 16 │ 17 │ 34
 17 │ 18 │ 36
 18 │ 19 │ 38
 19 │ 20 │ 40
━━━━┷━━━━┷━━━━
```

¡Servido!