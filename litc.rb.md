# Litc

A utility to compile/interpret literate programs. Written in:

    ruby

## Why

CoffeeScript recently introduced support for literate programming.
This is great, but I don't understand why this needs to be a feature supported
by the language when code and markdown can just as easily be separated by an
external utility. So I hacked one together.

## The Code

The utility itself is written in a literate style, which you can see below.

Since it will be run from the command line, we will start the file off with a shebang.

    #!/usr/bin/env ruby

### Show usage (if no arguments)

The first thing `litc` does, is check if any arguments are given. If none are
then it will print some usage for the user.

    if ARGV.length == 0
      $stderr.puts 'Run literate programs.'
      $stderr.puts 'Usage: litc [-n] <file> [--] [additional arguments]'
      $stderr.puts 'If -n is passed on the command line, the resulting code will not be executed.'
      $stderr.puts 'Arguments can be passed to the resulting code after a double dash.'
      $stderr.flush
      
      exit 1
    end

### Parse arguments

If arguments are given, then `litc` needs to do a check on these arguments, at
a minimum this is simply that a file has been passed. The user can also pass
`-n` to stop the resulting code from being executed. Additional arguments
can be passed to the resulting code by placing them after a double dash.

    $run = true
    $filename = nil
    $collect_args = false
    $args = []

    ARGV.each do |arg|
      if arg == '-n'
        $run = false
      elsif arg == '--'
        $collect_args = true
      else
        if $collect_args == true
          $args << arg
        else
          $filename = arg
        end
      end
    end

    exit 1 if $filename == nil

### Require needed modules

Now that we have a valid configuration at this point, we can go ahead and
require the needed Ruby modules.

#### Redcarpet

This is used for parsing the markdown files.

#### CodeRay

This is used to perform syntax highlighting based on file extension.

    require 'redcarpet'
    require 'coderay'

### Initialise variables

Here we initialise global variables and use CodeRay to guess the language
type to be used for highlighting.

    $filename_no_ext = File.basename($filename, File.extname($filename))
    $runner = ''
    $code = ''

    $lang = CodeRay::FileType[$filename_no_ext]

### Add CodeRay support to Redcarpet

Next we need to add some support in Redcarpet for syntax highlighting code
using CodeRay. This will use the default language (guessed from the file
extension) unless a language has been explicitly specified in the markdown.

Of note, the first code block in the file always denotes the command line
used to run the resulting code.

    class HTMLWithCodeRay < Redcarpet::Render::HTML
      def block_code(code, language)
        language = $lang if language == nil
        
        if $runner.empty?
          $runner << code.chomp
        else
          $code << code
        end

        CodeRay.scan(code, language).div
      end
    end

### Markdown helper

Next up, a helper function for taking our text and transforming it with
CodeRay and also making use of extra Redcarpet syntax.

    def markdown(text)
      options = {
        :no_intra_emphasis => true,
        :tables => true,
        :fenced_code_blocks => true,
        :autolink => true,
        :strikethrough => true,
        :superscript => true
      }

      html = Redcarpet::Markdown.new(HTMLWithCodeRay, options)
      html.render(text)
    end

### Write out everything

At this stage, we have the building blocks needed to transform the input file.

First, open this file and build the markdown HTML output.

    source = File.new($filename)
    markdown_output = markdown(source.read)
    source.close

Now that we have the output, write it into a file with an `.html` extension.

    html = File.new("#{$filename_no_ext}.html", 'w')
    html.write(markdown_output)
    html.close

With the code that we have gathered from Redcarpet, write that to another file
with the original code extension (in this case `.rb`).

    code = File.new("#{$filename_no_ext}", 'w')
    code.write($code)
    code.close

### Call the code!

Finally, with the code in place, call the specified interpreter and execute the
contained code!

    if $runner && $run
      system("#{$runner} #{$filename_no_ext} #{$args.join ' '}")
    end
