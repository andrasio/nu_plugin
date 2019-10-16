# sum-ruby Nu plugin commmand

## Getting started

Make sure you have a working Ruby environment, your working directory should be `examples/sum-ruby`.

Run `bundle`:

```shell
sum-ruby $ bundle
```

`path/to/nu-plugin/examples/sum-ruby/bin` needs to be in the `PATH` like so:

```shell
$ export PATH="path/to/nu-plugin/examples/sum-ruby/bin:$PATH"
```

To be able to run Nu you need the Nu binary in the `PATH` as well (or run it directly `path/to/nu`)

Confirm it picks up the plugin by using Nu's `help` command:

```shell
sum-ruby $ export PATH="/Users/andrasio/Code/nu-plugin/examples/sum-ruby/bin:$PATH"
sum-ruby $ nu
/Users/andrasio/Code/nu-plugin/examples/sum-ruby(master)> help sum-ruby
Sums a column of values

Usage:
  > sum-ruby
```

Now try to get the file sizes in the current working directy and the sum with `sum-ruby`:

```shell
/Users/andrasio/Code/nu-plugin/examples/sum-ruby(master)> ls | get size | sum-ruby
━━━━━━━━━━━
  <value>
───────────
      1558
━━━━━━━━━━━
```

¡Servido!