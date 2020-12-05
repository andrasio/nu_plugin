# len-ruby Nu plugin commmand

## Getting started

Make sure you have a working Ruby environment, your working directory should be `examples/len-ruby`.

Run `bundle`:

```shell
len-ruby $ bundle
```

`path/to/nu_plugin/examples/len-ruby/bin` needs to be in the `PATH` like so:

```shell
    $ export PATH="path/to/nu_plugin/examples/len-ruby/bin:$PATH"
```

To be able to run Nu you need the Nu binary in the `PATH` as well (or run it directly `path/to/nu`)

Confirm it picks up the plugin by using Nu's `help` command:

```shell
len-ruby $ export PATH="/Users/andrasio/Code/nu_plugin/examples/len-ruby/bin:$PATH"
len-ruby $ nu
/Users/andrasio/Code/nu_plugin/examples/len-ruby(master)> help len-ruby
Gets the length of a value

Usage:
  > len-ruby
```

Now try to get the file names in the current working directory and get the length with `len-ruby`:

```shell
/Users/andrasio/Code/nu_plugin/examples/len-ruby(master)> ls | get name | len-ruby
━━━┯━━━━━━━━━━━
 # │  <value>
───┼───────────
 0 │         3
 1 │         9
 2 │         7
 3 │        12
━━━┷━━━━━━━━━━━
```

¡Servido!