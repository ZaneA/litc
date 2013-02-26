if ARGV.length == 0
  $stderr.puts 'Run literate programs.'
  $stderr.puts 'Usage: litc [-n] <file> [--] [additional arguments]'
  $stderr.puts 'If -n is passed on the command line, the resulting code will not be executed.'
  $stderr.puts 'Arguments can be passed to the resulting code after a double dash.'
  $stderr.flush

  exit 1
end
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
require 'redcarpet'
require 'coderay'
$filename_no_ext = File.basename($filename, File.extname($filename))
$runner = ''
$code = ''

$lang = CodeRay::FileType[$filename_no_ext]
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
source = File.new($filename)
markdown_output = markdown(source.read)
source.close
html = File.new("#{$filename_no_ext}.html", 'w')
html.write(markdown_output)
html.close
code = File.new("#{$filename_no_ext}", 'w')
code.write($code)
code.close
if $runner && $run
  system("#{$runner} #{$filename_no_ext} #{$args.join ' '}")
end
