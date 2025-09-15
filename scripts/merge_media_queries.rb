# frozen_string_literal: true

require 'find'

def merge_media_queries(css)
  media_blocks = Hash.new { |h, k| h[k] = [] }
  other_css = []
  regex = /@media\s*\([^{]+\)\s*{((?:[^{}]+|{[^{}]*})*)}/m # jesus
  last_end = 0

  css.scan(regex) do |match|
    full_match = Regexp.last_match
    media = css[full_match.begin(0)...full_match.begin(1)].strip
    block = match[0].strip
    media_cond = media[/^@media\s*\([^{]+\)/]
    last_end = full_match.end(0)

    media_blocks[media_cond] << block
  end

  css_no_media = css.gsub(regex, "")
  other_css << css_no_media.strip unless css_no_media.strip.empty?

  merged_css = other_css.join("\n")
  
  media_blocks.each do |media, blocks|
    merged_css << "\n#{media} {\n#{blocks.join("\n")}\n}"
  end
  
  merged_css.gsub(/\s+/, ' ')
end


css_dir = File.join(Dir.pwd, '_site', 'assets', 'css')

if Dir.exist?(css_dir)
  Dir.glob(File.join(css_dir, '*.css')).each do |file|
    content = File.read(file)
    merged = merge_media_queries(content)
    
    File.write(file, merged)
  end
end
