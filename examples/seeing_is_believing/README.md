# sib Nu plugin commmand

## Getting started

Make sure you have a working Ruby environment, your working directory should be `examples/seeing_is_believing`.

Run `bundle`:

```shell
seeing_is_believing $ bundle
```

`path/to/nu_plugin/examples/seeing_is_believing/bin` needs to be in the `PATH` like so:

```shell
$ export PATH="path/to/nu_plugin/examples/seeing_is_believing/bin:$PATH"
```

To be able to run Nu you need the Nu binary in the `PATH` as well (or run it directly `path/to/nu`)

Confirm it picks up the plugin by using Nu's `help` command:

```shell
seeing_is_believing $ export PATH="/Users/andrasio/Code/nu_plugin/examples/seeing_is_believing/bin:$PATH"
seeing_is_believing $ nu
/Users/andrasio/Code/nu_plugin/examples/seeing_is_believing(master)> help sib
Shows Ruby code snippets with evaluated Ruby code per line in comments

Usage:
  > sib
```
Let's use `sib` to evaluate the Ruby code in `bin/arepas.rb`, but first let's take a look at the source code:

```ruby
los_tres_caballeros = [:robalino, :turner, :katz, :josh]
words = ["le gusta", "C", "likes", "Ok"]

[].tap do |rustaceans|
  los_tres_caballeros.shuffle.each do |caballero|
    word = words[rand(words.count)]
    rustaceans << "#{caballero.to_s} #{word}(arepa)"
  end
end
```

Let's open the file and pass the contents to `sib` like so:

```shell
/Users/andrasio/Code/nu_plugin/examples/seeing_is_believing(master)> open bin/arepas.rb | sib
# Evaluated Ruby Code:
los_tres_caballeros = [:robalino, :turner, :katz, :josh]  #[:robalino, :turner, :katz, :josh]
words = ["le gusta", "C", "likes", "Ok"]                  #["le gusta", "C", "likes", "Ok"]
                                                          #
[].tap do |rustaceans|                                    #[]
  los_tres_caballeros.shuffle.each do |caballero|         #[:katz, :turner, :josh, :robalino]
    word = words[rand(words.count)]                       #"Ok"
    rustaceans << "#{caballero.to_s} #{word}(arepa)"      #["katz Ok(arepa)"]
  end                                                     #[:katz, :turner, :josh, :robalino]
end                                                       #["katz Ok(arepa)", "turner C(arepa)", "josh le gusta(arepa)", "robalino C(arepa)"]
```

¡Servido!