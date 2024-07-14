---

title: A Search for Bash Scripting Alternatives
post_date: 2017-07-04 09:23:44

---


# A Search for BASH Scripting Alternatives

**TOC**
 1. Introduction
 2. Not Meeting Criterias
 3. Shells and Shell Languages
 4. Scheme Languages
 5. Scripting Languages
 6. Finalists
 7. Conclusion
 8. Appendix

<br>
<br>

## 1. Introduction

**Bash scripting is** http://mywiki.wooledge.org/BashWeaknesses

IT IS NO secret that bash scripting has its pitfalls and oddities. Subtle mistakes are easy to make given its many quirks and arcane syntax rules. So this documents seek to investigate if a language can be found which embodies the "Bash - the good parts" only.

The idea for this document originated at my place of work. Our products are linux based, and in the development department all local workstations are Ubuntu installations, so bash scripting is a part of the heritage that automatically comes from using a linux system. Most co-workers will use bash for a quick means to and end to automate some build steps or tweaking testing facilities. A minor group use bash for configuring and tweaking an embedded linux platform. Bash scripts *can* be simple, but most often scripts grow in size and complexity over time and bugs will sneak in. Other times a script is rushed and the implementer is fooled by the, at first sight, simplicity of bash and falls into its many pitfalls and bugs appear in even small scripts.

It is my experience that most bash scripts have bugs or are of low quality. Writing correct and safe bash scripts is hard. Having personally written a rather large umbrella build system in bash for one of our more advanced products, it became clear to me that an alternative to bash needs to be embraced.


## Criterias

*   The language, libraries and syntax should be sane, clean and unambiguous. No gotchas.
*   Multi arch. Must support Linux on i368, x64, armv7 and armv5te.
*   Terse. Not much cruft and boilerplate to get things done
*   Should be interpreted (intermediate compiling allowed) and require no cycle of compile + copy to target. It should be possible to modify a script on target and run it.
*   Dependencies. Scripts should be self contained, or have easily identifiable dependencies (libraries, modules).
*   REPL. Interactive shell is not required - but a bonus if available.
*   System calls. It should allow calling external tools (like make, grep etc.). This might be with a sane DSL or using a call mechanism that allows capturing output from bash syntaxed executions. Direct calls to operating system (or low level libraries) is not a requirement.
*   Scoping. No dynamic scoping. This eliminates interesting candidates like picolisp and newLISP, but dynamic scope in bash is cause for many confusing errors, so lexical scoped languages only.
*   Must be production ready, i.e. mature and preferably more that one maintainer.
*   Must have a license that is permissive of commercial usage and embedding.

A secondary objective is to find an embeddable scripting language. If the language could work as both a native scripting language and an embeddable scripting language, it would be preferable. It must embed into a C/C++ ecosystem.


This post is available in two places

- On the monzool.net [blog](https://monzool.net/blog/2017/07/04/a-search-for-bash-scripting-alternatives/), for a pretty viewing.

- On [github](https://github.com/monzool/A-Search-for-BASH-Scripting-Alternatives) where the source code is also available. This post is the *Take1* part of this series (direct preview link here: [preview](https://github.com/monzool/A-Search-for-BASH-Scripting-Alternatives/blob/master/Take1/Take1.md))


## 2. Not Meeting Criterias

### Perl

This contender actually has a lot of proven history, and surely would do the task at hand. But the Perl stack is rather large. There are smaller options like microperl<sup>[1]</sup> and miniperl, tinyperl<sup>[2]</sup>, but generally it seems that the recommendation is to look elsewhere than Perl, if targeting a small embedded platform<sup>[3]</sup>. There is also the more subjective argument, that perl is a bit dated and "unsexy" language with complex syntax.

What speaks in perls favor, is that its inherently very suited for scripting, and have a long pedigree as a more versatile alternative for bash.

Various techniques known from bash is supported, e.g.: HEREDOC
```perl
#!/usr/bin/perl
$a = 10;
$var = <<"EOF";
Multiline text string
in a HEREDOC section.
Value of a=$a
EOF
print "$var\n";
```

File handling is also very similar to the shell. To rename a file:
```perl
#!/usr/bin/perl
rename ("/usr/test/file1.txt", "/usr/test/file2.txt" );
```

However perl also have some of the annoying features of bash, e.g. like with passing lists to subroutines:
```perl
#!/usr/bin/perl
sub PrintList{
   my @list = @_;
   print "Given list is @list\n";
}
$a = 10;
@b = (1, 2, 3, 4);

PrintList($a, @b);

# => Given list is 10 1 2 3 4
```


Links:

*  \[1] [microperl](http://www.foo.be/docs/tpj/issues/vol5_3/tpj0503-0003.html)
*  \[2] [tinyperl](http://tinyperl.sourceforge.net)
*  [3] http://stackoverflow.com/questions/2461260/is-there-some-tiny-perl-that-i-can-use-in-embedded-system-where-the-size-would-m


### python

Python is an easy learned language and is very versatile. Good shell script libraries and abstractions exists for python<sup>[1,2,3,4]</sup>. The best might be xonsh<sup>[5]</sup> which provides a pythonic interactive shell, as wells as easy access to system programs like `grep` and `find` etc.

Given its "batteries included" profile, Python is quite heavy in the install size, and thus not fitting well on an embedded system. Only a few alternatives exists for reduced size python implementations. An old (unmaintained, batteries not included) distribution tinypy<sup>[6]</sup> and eGenix PyRun<sup>[7]</sup> which packs a python distribution down to about 11 MiB.


Links:

*  \[1] [plumbum](http://plumbum.readthedocs.io/en/latest)
*  \[2] [sarge](http://sarge.readthedocs.io/en/latest)
*  \[3] [sh.py](http://amoffat.github.com/sh)
*  \[4] [sultan](https://sultan.readthedocs.io/en/latest)
*  \[5] [xonsh](http://xon.sh)
*  [6] http://www.tinypy.org/
*  [7] http://www.egenix.com/products/python/PyRun



### TCL

This script language is in the kind of Perl being very versatile, having lots of libraries but also suffer from large install size and also having a syntax feels a bit outdated and unfriendly. TCL has two functions for calling system commands: `open` and `exec` which provides for system calls <sup>[1]</sup>. It is not a seamless port from bash as the commands have their own special syntax:

```tcl
exec ls {*}[glob *.tcl]
```
First impressions of TCL's pipelining handling is that it is rather cumbersome<sup>[2]</sup>

The TCL language is very flexible in its dynamic nature and do enable it to extend itself in a lisp like way. Opinions of TCL is many and contradicting<sup>3</sup>

Jim<sup>[4]</sup> is a smaller edition of TCL, so the size impact of a TCL installation could be reduced if using that.
A few other languages target the TCL vm. One such is Little<sup>[5]</sup> which have a nicer abstraction upon the `exec` call.

Links:

*  \[1] [`open`, `exec`](https://www.tcl.tk/man/tcl8.5/tutorial/Tcl26.html)
*  \[2] [TCL pipelining](http://wiki.tcl.tk/2196)
*   [3] https://news.ycombinator.com/item?id=9098617
*  \[4] [Jim](http://jim.tcl.tk/index.html/doc/www/www/index.html)
*  \[5] [Little](http://www.little-lang.org)

### cash

Requires the node.js stack and is not suited for the targeted embedded platform.

Links:

*   [cash](https://github.com/dthree/cash)


### Ammonite

Sits on top of the JVM as is thus not applicate for the targeted embedded platform. Also, the syntax seems clumsy and verbose.

Links:

*   [Ammonite](http://www.lihaoyi.com/Ammonite/)


### Elixir

Elixir uses escript to build an binary with Elixir merged in. Then that binary requires the Erlang vm engine to execute. Have not looked into the size of minimal Erlang installation, as the language itself do not fit the intended purpose.

Links:

*   [https://www.reddit.com/r/elixir/comments/2owfcu/is_elixir_the_right_choice_for_a_script/cmrr3au](https://www.reddit.com/r/elixir/comments/2owfcu/is_elixir_the_right_choice_for_a_script/cmrr3au)


### shcaml

shcaml reminds a lot of scsh. It provides a wide range of user functions, system call wrappers and bash like functionality

>Unix shells provide easy access to Unix functionality such as pipes, signals, file descriptor manipulation, and the file system. Shcaml hopes to excel at these same tasks.

With its _UsrBin_<sup>[1]</sup> module, often used function like `ls`, `ps` etc. are available.

The _Fitting_<sup>[2]</sup> module emulates common shell behaviors. E.g: redirecting to `/dev/null` can be done

```ocaml
run (command "echo hello" />/ [ stdout />* `Null ]);;
```

Links:

*   [shcaml](http://users.eecs.northwestern.edu/~jesse/code/shcaml/)
*   [schaml GitHub](https://github.com/tov/shcaml)
*   \[1] [UsrBin](http://www.ccs.neu.edu/home/tov/code/shcaml/doc/UsrBin.html)
*   \[2] [Fitting](http://users.eecs.northwestern.edu/~jesse/code/shcaml/doc/Fitting.html)


### Julia

Julia has pretty good interop with shell commands built in<sup>[1]</sup>. But unfortunately its not that a light weight installation.

Links:

*   \[1] [Julia commands](http://blog.leahhanson.us/post/julia/julia-commands.html)


### Wren

Wren is a very attractive language with great syntax and excellent C/C++ interop. It is written in C and is very portable. Wren can be used both standalone or embedded.

Unfortunately I could not find any evidence of it being able to do system calls. The _system_ module<sup>[1]</sup> in its core library seems limited to mainly screen printing.

The documentation is also very incomplete. For example the chapter on how to use it embedded in C:

>Calling a C function from Wren #
>TODO
>
>Calling a Wren method from C #
>TODO
>
>Storing a reference to a Wren object in C #
>TODO
>
>Storing C data in a Wren object #
>TODO 

Links:

*   [Wren](http://wren.io)
*   \[1] [Wren System module](http://wren.io/core/system.html)


### Dart

Good support for stdout, stderr, stdin and environment<sup>[1]</sup> The `Process.run`<sup>[2]</sup> provides convenient access to system tools.

```dart
Process.run('grep', ['-i', 'main', 'test.dart']).then((result) {
  stdout.write(result.stdout);
  stderr.write(result.stderr);
});
```

Dart also has a solution for handling pipes. Albeit this is not as seamless compared to how bash does it, but it seems to work well.

```dart
import 'dart:io';

main() async {
  var output = new File('output.txt').openWrite();
  Process process = await Process.start('ls', ['-l']);
  process.stdout.pipe(output);
  process.stderr.drain();
  print('exit code: ${await process.exitCode}');
}
```

Dart looks very appealing and have a wide range of good libraries as well. I could not find clear specs on how much space the vm can be shrinked down to, but as the downloadable dart engine is 11 MB is not likely that it can be shrinked enough. The deal-breaker is however a passage, stating that the targeted cpu only have experimental support:

>has experimental support ARMv5TE <sup>[4]</sup>

Links:

*   \[1] [cmdline](https://www.dartlang.org/tutorials/dart-vm/cmdline)
*   \[2] [Process.run](https://api.dartlang.org/be/143338/dart-io/Process/run.html)
*   \[3] [dart::io](https://www.dartlang.org/articles/dart-vm/io)
*   \[4] [Building-Dart-SDK-for-ARM-processors](https://github.com/dart-lang/sdk/wiki/Building-Dart-SDK-for-ARM-processors)


### duktape

JavaScript is among the hottest languages right now. Several embeddable JavaScript engines exists, but what appears to be the most used in embedded scenarios, is the `duktape` engine.

It opens up to an alternative strategy of using one of the many JavaScript transpilers to do scripting in an entirely different language - although the level of indirection would probably be to high ;-)

Although the scripting facilities and embedding in C/C++ works well, there is no solid support of standalone system-near scripting.

License: MIT

Links:

*   [duktape](https://github.com/svaarala/duktape)


## 3. Shells and Shell Languages

Shell languages are languages that either extend an existing shell (like bash), or implements their own shell and provide an alternative shell scripting language. Common is that this concept does not provide embedding into C/C++.


### modernish

modernish is a library written in POSIX compatible shell script, that augments the shell scripting languages with sane and better functions for most functionality.

Links:

* [modernish](https://github.com/modernish/modernish)

### powscript

powscript is a language that transpiles to bash. This makes it very portable - in theory. Unfortunately it targets bash-4 only
>written/generated for bash >= 4.x, 'zero'-dependency solution

A lot of features have been added to bash-4, and the busybox shell (ash) does not support many of the new features and syntax additions.

Apart from the non-portable issue for this particular purpose, its a very appealing concept and it boasts some nice features also<sup>[1]</sup>:

Links:

*   [powscript](https://github.com/coderofsalvation/powscript)
*   \[1] [features](https://github.com/coderofsalvation/powscript#features)


### NGS

NGS is a bash replacement. The project seems primarily focused towards AWS (Amazon) usage by providing interaction on object level. Also focus is on doing scripting in a custom GUI called small-poc<sup>1</sup>

Links:

* [NGS](https://github.com/ilyash/ngs)
* [NGS blog](https://ilya-sher.org/category/ngs/)
* [1] http://www.youtube.com/watch?v=T5Bpu4thVNo


### oh

Oh is a bash replacement that describes its scripting language as:
> a heavily modified dialect of the Scheme programming language, complete with first-class continuations and proper tail recursion.

The documentation<sup>1</sup> is in the better end of "home brewed" shells, but is still pretty sparse.

Oh is written in go and have automated tests for a wide range of architectures.
Compared to bash the features are limited in some areas, improved in others<sup>2</sup>


I cross compiled oh as follows
```shell
env CC=/usr/local/arm-2007q3/bin/arm-none-linux-gnueabi-gcc CGO_ENABLED=1 GOARM=5 GOARCH=arm go build -v github.com/michaelmacinnis/oh
```

The compiled binary is about 2.8 MB. A bit much perhaps, but acceptable.
Unfortunately when executing oh on the destination target, it would endlessly fail with some futex error:
```shell
» strace oh
...
futex(0x2cab4c, FUTEX_WAIT, 0, NULL)    = -1 EAGAIN (Resource temporarily unavailable)
```

Links:

* [oh](https://github.com/michaelmacinnis/oh)
* [1] https://github.com/michaelmacinnis/oh/blob/master/doc/manual.md
* [2] https://htmlpreview.github.io/?https://raw.githubusercontent.com/michaelmacinnis/oh/master/doc/comparison.html

### elvish

elvis is a bash replacement with some very interesting ideas about scripting. It have, for example, some very nice concepts like named arguments
```bash
~> fn square [x]{
     * $x $x
   }
~> square 4
▶ 16
```

The project appears to be very young and implementation seems (for now) to be mainly focusing on the interactive shell part.
Documentation is quite sparse. Some information can be found on the atom-feed<sup>1</sup> some on the github<sup>2</sup> site and other on the main webpage<sup>3</sup>

It is hard to get a real indication of the maturity of the project. Documentation is sparse, no test suite seems to exist but the main committer appears reasonable active in the last 4-5 years.

I cross compiled elvish as follows
```shell
env CC=/usr/local/arm-2007q3/bin/arm-none-linux-gnueabi-gcc CGO_ENABLED=1 GOARM=5 GOARCH=arm go build -v github.com/elves/elvish
```
The stripped binary weights in at a hefty 4.6 MB.


Being a read-only filesystem, I had to relocated `$HOME` to a writable directory
```shell
arm-target» env HOME=/var/ elvish
```
Elvish starts just fine, and seems functional. For the cross-compiled edition, only exception is user input which writes every input key at the same line column. This makes it pretty unusable for a shell replacement, but should still allow to be used for scripting purposes.


Links:

* [elvish](https://github.com/elves/elvish)
* [1] https://elvish.io/feed.atom
* [2] https://elvish.io/learn/quick-intro.html
* [3] https://github.com/elves/elvish


### oilshell

An interesting project of a total bash replacement with implementation decisions discussed in detailed blog posts by the author. The level of meticulously documentation, testing and benchmarking done by the author is quite impressive.
Not production ready and not sure if the, build with python technology, disqualifies it for small embedded platforms anyway.

The author of oil maintains an excellent list of shells and shell scripting languages<sup>1</sup>

Links:

* [oilshell](https://github.com/oilshell/oil)
* \[1] https://github.com/oilshell/oil/wiki/ExternalResources


### murex

murex is a rather young project (first github commit in April 2017).

>Murex is a cross-platform shell like Bash but with greater emphasis on writing safe shell scripts and powerful one-liners while maintaining readability.

What murex really gets right is the terseness and expressiveness with few artifacts. Its very much the power of bash, just better and safer.

As with the other go-lang based shells, the readline functionality is not working in the cross-compiled edition.


* [murex](https://github.com/lmorg/murex)
* [murex syntax](https://github.com/lmorg/murex/blob/master/GUIDE.syntax.md)


## 4. Scheme Languages

A dedicated section is about Schemes. This is because scheme in general fits perfectly regarding the criterias given for the bash replacement. But at the same time, there are many many variants of scheme, all with their own pros and cons.


### Chibi

chibi is the unofficial reference R7RS implementation of scheme. It also have attractive features like a ffi generator and a good package manager (snow). Its small in size and handles both scripts and embedding into C/C++ well.

chibi also supports calling subprocesses:

```scheme
> (import (chibi) (chibi process))
> (system "ls" "/usr/")
bin  games  include  lib  local  sbin  share  src
```

The documentation is quite spares, or practically non-existing. This is from the process documentation page:

>(execute cmd args)
(execute-returned cmd)
(system cmd . args)
(system? cmd)

This might (?) be enough for a seasoned schemer, but for the intended target of scheme n00bs, this is not good enough.

As an example, I still have to figure out what the difference between `execute` and `system` is. Not to mention, figure out how to run the command

```scheme
> (execute "/usr/bin/whoami" '())
A NULL argv[0] was passed through an exec system call.
[1]    21444 abort (core dumped)  LD_LIBRARY_PATH=./lib ./bin/chibi-scheme
```

chibi is accompanied with very few examples and unit-tests. Along with the lack of documentation it is not giving a particular good first impressions about the project. Never the less, it does seem to be a very widespread used and praised scheme.


### chez

chez was a commercial closed-source scheme until Cisco open-sourced it. Its a R6RS scheme with the optional capability of generating compiled output. The documentation is excellent<sup>1</sup>


```scheme
./chez » ./bin/petite
Petite Chez Scheme Version 9.4
Copyright 1984-2016 Cisco Systems, Inc.

> (system "ls")
bin  lib  share
0
```

Installation size:

```bash
./chez » du -chs bin lib/csv9.4/i3le
316K    bin
2.1M    lib/csv9.4/i3le
2.4M    total
```

A first glance cross-compiling seems a bit "home grown" and being dependent on having target specific description files<sup>2</sup>. It is unclear if the one existing arm target could be used.

chez can run as an interpreter, but that eliminates some functionality like foreign calls and others<sup>3</sup>.

Links:

*  [1] http://cisco.github.io/ChezScheme/csug9.4/csug.html, http://www.scheme.com/tspl4/ 
*  [2] https://github.com/cisco/ChezScheme/issues/7, https://github.com/cisco/ChezScheme/issues/13
*  \[3] [Building and Distributing Applications](http://cisco.github.io/ChezScheme/csug9.4/use.html#./use:h8)


### gauche

I've been looking into this version of Scheme before. It is very actively maintained and have a substantial amount of useful libraries. It boasts upstart times matching that of bash, which makes it an interesting alternative - especially in cases where rapid script execution is key.

There is no scsh equivalent for gauche, but instead gauche have a subprocess library<sup>[1]</sup> that makes process calls somewhat easier. An example of a subprocess call with pipes <sup>[2]</sup>:

```scheme
(run-process-pipeline '((ls -l) (grep "\\.[ch]$") (wc)) :wait #t)
```

From comments in a gauche commit<sup>[3]</sup>, it looks like a scsh alike interface is on the wish list

```diff
+;; We might adopt scsh-like process forms eventually, but finding an
+;; optimal DSL takes time.  Meanwhile, this intermediate-level API
+;; would cover typical use case...
+(define (run-process-pipeline commands
```

Such a DSL would be a great asset, because there are gotchas with some scheme vs shell syntax collisions. One such is mentioned in the subprocess documentation

>Note that -i is read as an imaginary number, so be careful to pass -i as a command-line argument; you should use a string, or write |-i| to make it a symbol.

```scheme
(run-process '(ls "-i"))
```

The above is an example of what scsh eliminates.

Looking at the Ubuntu packaging of gauche, its size bloats a bit
```bash
» du -shc /usr/bin/gosh /usr/bin/gauche-cesconv /usr/share/gauche-0.9 /usr/lib/gauche-0.9
24K     /usr/bin/gosh
4.0K    /usr/bin/gauche-cesconv
2.3M    /usr/share/gauche-0.9
5.3M    /usr/lib/gauche-0.9
7.5M    total
```
A total of 7.7 MB seems quite too much. It is unclear to me if some or more of the share files and libraries can be excluded from a final target installation

Besides... an often reoccurring issue with Gauche is that it won't compile. This time around:

```shell
» ./configure --enable-multibyte=utf-8 --enable-tls=none --with-dbm=no --prefix=/usr

make[1]: Entering directory '/home/skv/public/src/Gauche-0.9.5/lib'
if test -f /usr/share/slib/require.scm && test i686-pc-linux-gnu = i686-pc-linux-gnu ; then \
  /usr/bin/gosh -ftest -uslib -E"require 'new-catalog" -Eexit;\
fi
gosh: "error": Compile Error: failed to link ../src/srfi-13.so dynamically: ../src/srfi-13.so: undefined symbol: Scm_MakeExtendedPair
"../lib/slib.scm":8:(define-module slib (use srfi-0) (us ...
```

Links:

*   \[1] [gauche subprocess](http://practical-scheme.net/gauche/man/gauche-refe/High-Level-Process-Interface.html#index-gauche_002eprocess)
*   \[2] [run-process-pipeline](https://sourceforge.net/p/gauche/mailman/message/35184181/)
*   [3] https://github.com/shirok/Gauche/commit/8128d67cacb59ffd04c6bf051ec8de8488c4454d



## 5. Scripting Languages


### squirrel

Squirrel reminds a lot of Lua. It is tailored for embedding into C/C++ programs, but can be used as a standalone scripting language as well.

>squirrel's syntax is similar to C/C++/Java etc... but the language has a very dynamic nature like Python/Lua etc...

Much effort have been put into shrinking the installation size

> both compiler and virtual machine fit together in about 7k lines of C++ code and add only around 100kb-150kb the executable size

The system<sup>[1]</sup> library provides limited functionality like `date`, `getenv` and functions to delete and rename files. Otherwise a `system` function is the only access to system calls. The I/O<sup>[2]</sup> library provides basic file streaming operations.

* http://squirrel-lang.org
* \[1] [system library](]http://squirrel-lang.org/squirreldoc/stdlib/stdsystemlib.html)
* \[2] [I/O library](http://squirrel-lang.org/squirreldoc/stdlib/stdiolib.html)



### mruby

mruby is a lightweight implementation of the Ruby language. It supports a multitude of execution models<sup>[1]</sup>. It can run as a script, be embedded in C/C++ or, if to not distribute the source code, it can be compiled to a bytecode format.


A lot of extension libraries<sup>[2]</sup> exists for mruby. In context of this document, one of the more amusing is an extension that allows mruby to execute Lua<sup>[3]</sup>.

Like Lua, mruby only provides the core of a script language. It appears that many expected features, like e.g. convenient file and directory handling, environment manipulation and errno, are provided by community libraries.


While mruby promises ruby compatibility, a blog post from 2014<sup>4</sup> complains about the heartaches of porting ruby code to mruby.

An example from the blog:

```ruby
$ ruby -e "p File.join ['a', 'b', 'c']"
"a/b/c
```

vs.

```ruby
$ mruby -e "p File.join ['a', 'b', 'c']"
["a", "b", "c"]
```

<br>
The target installation process is a bit unconventional - but actually is quite useful for a static embedded environment. During build of mruby all desired extensions and libraries are set in the build configuration, and the ending build will include only what was enabled. An answer on the [arduino forum](https://forum.arduino.cc) formulates its like this:

>Main advantage of mruby over ruby is size, which can be crucial on embedded systems. The sole mruby executable weights 2.2Mb and it is completely self contained, including most of the standard library, plus commodities like RegExp, IO, Socket, File, and the Yun module. The mruby-gems, rather than being loaded and parsed runtime, are precompiled into byte code at build time, and directly statically linked into the executable. Once you have a cross-build system is rather easy to build a custom mruby interpreter with a custom set of gems. Furthermore, mruby-gems can easily mix methods implemented in C or mruby in the same class/module.

Further there is a comment on the C interface:
>Finally, mruby C APIs are much more easy than C interfaces for ruby, and I'd say even marginally easier than python and lua interfaces. Which makes really easy to build C executables that embed an mruby interpreter, or to build C extensions to the standard mruby interpreter.

mruby have its own gem variant *mgem*<sup>[5]</sup>. Currently its a tool that is based on a manually maintained list of available mruby gems.

To install mgem:
```bash
gem install mgem
```

A main reason for even looking a mruby, is the reputation of the scripster<sup>[6]</sup> library that runs on ruby. It is an excellent abstraction to make shell commands seem as first class citizens in the ruby language.
mruby does not inherently support `require`. This means a lot of scripts wont run out of the box (including scripster). An mgem plugin 'mgem-require' however exist to provide this functionality. To use this, it is required that the support is compiled in into mruby<sup>[7]</sup>.

The build system of mruby is a NIH'ed non-standard system. Its simple for a default standard build, but gets a bit confusing when it comes to the cross-compiling. The library edition of mruby cross-compiles simply to a static library. But if wanting it as a shared library you are out of luck<sup>8</sup>. Following the cross-compile guide does not output a cross-compiled instance of the mruby interpreter. Adding the binaries specifically for generation in `build_config.rb` takes care of that though:

```ruby
conf.gem "#{root}/mrbgems/mruby-bin-mruby"
conf.gem "#{root}/mrbgems/mruby-bin-mirb"
```

See appendix `A` for my example of a cross-compile configuration

License: `MIT`

Links:

*   [mruby](https://github.com/mruby/mruby)
*   [1] http://mruby.org/docs/articles/executing-ruby-code-with-mruby.html
*   \[2] [mruby libraries](http://mruby.org/libraries)
*   [3] https://github.com/dyama/mruby-lua
*   [4] http://gromnitsky.blogspot.dk/2014/09/porting-code-to-mruby.html
*   [5] https://github.com/bovi/mgem
*   \[6] [ruby-scripting](http://radek.io/2015/07/13/ruby-scripting)
*   [7] https://github.com/mattn/mruby-require#install-by-mrbgems, http://stackoverflow.com/a/30794049
*   [8] https://github.com/mruby/mruby/issues/1666


### scsh

scsh is written in Scheme48 which originates back in 1986, but is still actively updated. Scheme48 is written in PreScheme which is a statically-typed dialect of Scheme.
By own emission, scsh is not suitable for an interactive shell, as many features for this is not implemented yet. However scsh is a very complete and well thought abstraction over the requirements and needs used in scripting and calling system commands.

> Scsh spans a wide range of application, from “script” applications usually handled with perl or sh, to more standard systems applications usually written in C

scsh have very extensive system support, e.g. functions for networking, string manipulations, regex, file manipulations and many more exists. Also more specialized features as creating fifos and file locks are supported. scsh provides its own abstraction over system calls and have parted from traditional error handling, and instead opted for an exception based error mechanism.

>System call error exceptions contain the Unix errno code reported by the system call. Unlike C, the errno value is a part of the exception packet, it is not accessed through a global variable.

It is clear that the creators of scsh have great knowledge of how the underlaying OS works and operates, and have gone lengths to chose sane default behaviors. Examples are the mentioned decision, to consistently use exceptions to allow free use of return values. Another example is the handling of _EINTR_ for which the wanted solution you almost always want, is the exact default chosen:

>System calls never return error/intr - they automatically retry.<

A nice feature of scsh is the optional feature of compiling the scripts to either byte-codes (heap image) or native binaries.

>Scsh programs can be pre-compiled to byte-codes and dumped as raw, binary heap images. Writing heap images strips out unused portions of the scsh runtime (such as the compiler, the debugger, and other complex subsystems), reducing memory demands and saving loading and compilation times. The heap image format allows for an initial `#!/usr/local/lib/scsh/scshvm` trigger on the first line of the image, making heap images directly executable as another kind of shell script.
>Finally, scsh's static linker system allows dumped heap images to be com- piled to a raw Unix a.out(5) format, which can be linked into the text section of the vm binary. This produces a true Unix executable binary file.

All the above sounds very promising. The prevailing comments from people using scsh in real life is however, that it has some annoying problems when used as a script language<sup>1</sup>. Its module inclusion is not really trailered for being called as a shebang script. Error messages are missing location of origin and debugging is quite cumbersome. Generally debugging scsh scripts is though of as a major PITA.


Links
*  https://scsh.net
*  https://github.com/scheme/scsh
*  [1] http://www.lysium.de/blog/archives/215-Why-I-dont-use-scsh-as-a-scripting-language-anymore.html
*  [Scripting with Scheme Shell by Rudolf Olah](https://www.linux.com/news/scripting-scheme-shell)


### luash

Lua is in it self a great scripting language. It can be used standalone but also have a vast pedigree of being embedded into c/c++ code where performance is a priority.

Lua in it self can call system programs using `os.execute`, or if output is needed, `io.popen`

```lua
local ps = assert(io.popen("/bin/ps ax | grep '/sbin/init'"), 'r')
local val = ps:read("*a")
print(val)
```

The above does the job, but its not that clean and soon you'll find yourself writing wrappers to make many successive system calls more nicer looking. This is one of the things that luash provides.

In the next example luash takes advantage of a syntactic feature in Lua where, if the argument of a function is a string or a table constructor, the parens can be omitted. This makes for a nice clean syntax when calls are simple:

```lua
-- $ ls /bin | grep $filter | wc -l
ls '/bin' : grep filter : wc '-l'
```

In other situations, the syntax is not that clean

```lua
local words = 'foo\nbar\nfoo\nbaz\n'

-- $(echo ${words} | sort | uniq)
local u = uniq(sort({__input = words}))
print(u)
```

Due to some conflicts between Lua and bash some commands need to be wrapped in a command call.

```lua
local chrome = sh.command('google-chrome')   -- because '-' is an operator
```

The `sh.command` functionality does however allow for some interesting composites.

```lua
local gittag = sh.command('git', 'tag')   -- gittag(...) is same as git('tag', ...)
gittag('-l')   -- list all git tags
```

A shortcoming of Lua is a weak/lacking standard library<sup>[1]</sup>. LuaRocks, LuaDist and others now provide downloading managing of various libraries, but this does not transcend very well into small embedded platforms and cross compiling. A general problem of Lua is the fragmentation between LuaJit, Lua-5.1, Lua-5.2 and Lua-5.3. Incompatibilities between those versions cause a lot of packages to only work on some of those. Also a prevailing problem in the Lua ecosystem is dormant unmaintained packages. The fragmentation and relatively small package repository is considered a major problem within the community.

See appendix `B` for my example of a cross-compile configuration
As with elvish, the repl line reader is completely borked and unusable. Not sure why this is...


<br>
The flexibility in the few rules in lua makes it somewhat akin to javascript, and makes it interesting as a transpiler target.

MoonScript<sup>[2]</sup> is an object oriented language that is inspired by coffeescript.
> It can be loaded directly from a Lua script without an intermediate compile step. It even knows how to tell you where errors occurred in the original file when they happen.

MoonScript development have somewhat stalled, but the author of the language is running his own company build on MoonScript technology<sup>[3]</sup>.

Urn<sup>[4]</sup> brings the world of lisp to the lua vm. It is a relative new project, but seems in good progress.

The multi-transpiling language Haxe also have a backend that generates Lua code<sup>[5]</sup>.


License: `MIT`
Lua license: `MIT`

Links:

*   [luash](https://github.com/zserge/luash)
*   [example.lua](https://github.com/zserge/luash/blob/master/example.lua)
*   http://notebook.kulchenko.com/programming/lua-good-different-bad-and-ugly-parts
*   [1] https://www.tutorialspoint.com/lua/lua_standard_libraries.htm
*   \[2] [MoonScript](http://moonscript.org)
*   [3] https://news.ycombinator.com/item?id=14441758
*   \[4] [Urn](https://squiddev.github.io/urn/)
*   [5] https://haxe.org/blog/hello-lua


## 6. Finalists

### `scsh`
from a technical point of view, scsh is by far the solution that appear most complete and best suited. It is dedicated for shell scripts and does it well. Its library and functions give a huge range of of supported functionality. The obvious downside, is that the scheme language is not well known within the focus group, and will most likely discourage many people from using it. Also the PITA situation of debugging scripts is a major drawback.
Using scsh would spawn the logic step of using a scheme based embedded language for mixing with C/C++ also. Scheme48 (upon which scsh is based) or chibi would be the best choices.
The language of scheme is very interesting academically, but during the writings of this document is it clear that "googling" for actual scheme snippets, help/hints and various library wrappers return very sparse and low quality results. Contrary to this is mruby and especially lua where snippets, hints and wrappers are abundantly available.


### `luash`
luash is very attractive in being a Lua library. Lua is pretty easy to learn and use, and would be more easy to adopt that e.g. the scheme based scsh
Lua is praised for being a simple language but with great flexibility. It is certainly possible to build large programs in Lua, but it is also clear from digesting the comments on the world-wide-web, that the simplicity is also the acillies heel of the language, in forcing "do it yourself" solutions and patterns on everything. Its small and efficient, easy to learn - but a tad cumbersome and restricted. Bringing package dependencies into the mix, complicates the usage considerably.


### `mruby`
The question of "why not python", will be inevitable as that is the main scripting language used within the focus group. Python is much utilized in test scripts, automation and build systems, but fact is that Ruby has just as much to offer and provides same levels of flexible, exciting and productive scripting. The mruby community is really active and structured, and are in good progress of cloning the well known Ruby tools into the embedded mruby equivalent. Besides, no python derivative equivalent of mruby exits. Of the languages examined, mruby is superior to most in simplicity, expressiveness and capability.


## 7. Conclusion

TL;DR: Winner is: lua (and mruby)

A true native scripting spirited project like elvish, oh and the like would have been preferred. From trying out various languages it is clear to me that bash scripting is a special kind of domain, and most scripting languages does not transcend especially well into that domain. Unfortunately the state of the tested alternatives are not worthy of production quality.

A split decision for an alternative bash scripting language is the conclusion for the  this document. Of the available contenders, lua and mruby would do equally great. For general purpose simple scripting lua have a slight advantage given the luash library.

Regarding the secondary objective of finding an embedded scripting language, both mruby and lua will be excellent choices. The choice would mostly be about the extend that the scripting language is to be used. If the embedded scripting is to be a larger part of the model or logic, use the better language mruby. If embedding a scripting language is only for minor scripting facilities, go for the small and leaner language lua.





## 8. Appendix

### Appendix A - Cross Compiling mruby


```ruby
# Define cross build settings
if ENV['MRUBY_CROSS_TCA'] == "ffxav"
  MRuby::CrossBuild.new('ffxav') do |conf|

    toolchain :gcc

    tool_path = ENV['FFXAV_SDK_HOME']
    cgcc = "#{tool_path}/bin/arm-none-linux-gnueabi-gcc"
    car = "#{tool_path}/bin/arm-none-linux-gnueabi-ar"


    # C compiler settings
    conf.cc do |cc|
      cc.command = ENV['CC'] || cgcc
      puts("CC => #{cc.command}")
      cc.flags = ENV['CFLAGS'] || '-mtune=arm9tdmi -march=armv5te -O2 -std=gnu99 -pipe -fPIC -DPIC -DLINUX -DFFXAV'
      cc.include_paths = ["#{root}/include", 
                          "#{tool_path}/arm-none-linux-gnueabi/libc/usr/include",
                          "#{tool_path}/arm-none-linux-gnueabi/include/c++/4.2.1"]
    end

    # Linker settings
    conf.linker do |linker|
      linker.command = ENV['LD'] || cgcc
      linker.library_paths = ["#{tool_path}/arm-none-linux-gnueabi/libc/lib",
                              "#{tool_path}/arm-none-linux-gnueabi/lib"]
    end

    # Archiver settings
    conf.archiver do |archiver|
      archiver.command = ENV['AR'] || car
      archiver.archive_options = 'rs %{outfile} %{objs}'
    end

    # Enable compiling of binaries
    conf.gem "#{root}/mrbgems/mruby-bin-mruby"
    conf.gem "#{root}/mrbgems/mruby-bin-mirb"


    conf.gembox 'default'
  end
end
```

Adding the above section to `build_config.rb` will allow compiling with the command:
```shell
FFXAV_SDK_HOME=/usr/local/arm-2007q3 MRUBY_CROSS_TCA=ffxav minirake
```


### Appendix B - Cross Compiling lua


```shell
export FFXAV_SDK_HOME=/usr/local/arm-2007q3
```

### ncurses

```shell
TARGETMACH=arm-none-linux-gnuabi BUILDMACH=i686-pc-linux-gnu \
CC=${FFXAV_SDK_HOME}/bin/arm-none-linux-gnueabi-gcc \
CFLAGS='-mtune=arm9tdmi -march=armv5te' \
LD=${FFXAV_SDK_HOME}/bin/arm-none-linux-gnueabi-ld \
LDFLAGS='-mtune=arm9tdmi -march=armv5te' \
AS=${FFXAV_SDK_HOME}/bin/arm-none-linux-gnueabi-as \
CXX=${FFXAV_SDK_HOME}/bin/arm-none-linux-gnueabi-g++ \
./configure --prefix=/var/usr/local --without-ada --without-debug \
  --without-pkg-config --host=arm-none-linux-gnuabi
```

### readline

```shell
CC=${FFXAV_SDK_HOME}/bin/arm-none-linux-gnueabi-gcc \
CFLAGS='-mtune=arm9tdmi -march=armv5te -I${WORK_PATH}/ncurses-6.0/install_dir/var/usr/local/include' \
LDFLAGS='-mtune=arm9tdmi -march=armv5te -L${WORK_PATH}/ncurses-6.0/install_dir/var/usr/local/lib' \
./configure --prefix=/var/usr/local --host=arm-none-linux-gnuabi
```

### Lua

```shell
diff -Naur lua-5.3.4.orig/Makefile lua-5.3.4/Makefile
```

```diff
--- lua-5.3.4.orig/Makefile     2016-12-20 17:26:08.000000000 +0100
+++ lua-5.3.4/Makefile  2017-06-09 12:49:50.863809153 +0200
@@ -4,13 +4,13 @@
 # == CHANGE THE SETTINGS BELOW TO SUIT YOUR ENVIRONMENT =======================
 
 # Your platform. See PLATS for possible values.
-PLAT= none
+PLAT= linux
 
 # Where to install. The installation starts in the src and doc directories,
 # so take care if INSTALL_TOP is not an absolute path. See the local target.
 # You may want to make INSTALL_LMOD and INSTALL_CMOD consistent with
 # LUA_ROOT, LUA_LDIR, and LUA_CDIR in luaconf.h.
-INSTALL_TOP= /usr/local
+INSTALL_TOP= $(WORK_PATH)/lua/lua-5.3.4/var/usr/local
 INSTALL_BIN= $(INSTALL_TOP)/bin
 INSTALL_INC= $(INSTALL_TOP)/include
 INSTALL_LIB= $(INSTALL_TOP)/lib
```


```shell
diff -Naur lua-5.3.4.orig/src/Makefile lua-5.3.4/src/Makefile                           ```

```diff
--- lua-5.3.4.orig/src/Makefile 2015-05-27 13:10:11.000000000 +0200
+++ lua-5.3.4/src/Makefile      2017-06-09 13:34:27.000000000 +0200
@@ -4,22 +4,22 @@
 # == CHANGE THE SETTINGS BELOW TO SUIT YOUR ENVIRONMENT =======================
 
 # Your platform. See PLATS for possible values.
-PLAT= none
+PLAT= linux
 
-CC= gcc -std=gnu99
-CFLAGS= -O2 -Wall -Wextra -DLUA_COMPAT_5_2 $(SYSCFLAGS) $(MYCFLAGS)
-LDFLAGS= $(SYSLDFLAGS) $(MYLDFLAGS)
-LIBS= -lm $(SYSLIBS) $(MYLIBS)
+CC= $(FFXAV_SDK_HOME)/bin/arm-none-linux-gnueabi-gcc -std=gnu99 
+CFLAGS= -O2 -Wall -Wextra -DLUA_COMPAT_5_2 $(SYSCFLAGS) $(MYCFLAGS) -mtune=arm9tdmi -march=armv5te -I$(WORK_PATH)/readline-7.0/install_dir/var/usr/local/include -I$(WORK_PATH)/ncurses-6.0/install_dir/var/usr/local/include
+LDFLAGS= $(SYSLDFLAGS) $(MYLDFLAGS) -mtune=arm9tdmi -march=armv5te -L$(WORK_PATH)/readline-7.0/install_dir/var/usr/local/lib -L$(WORK_PATH)/ncurses-6.0/install_dir/var/usr/local/lib
+LIBS= -lm $(SYSLIBS) $(MYLIBS) -lncurses
 
-AR= ar rcu
-RANLIB= ranlib
+AR= $(FFXAV_SDK_HOME)/bin/arm-none-linux-gnueabi-ar rcu
+RANLIB= $(FFXAV_SDK_HOME)/bin/arm-none-linux-gnueabi-ranlib
 RM= rm -f
```
