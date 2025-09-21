# frozen_string_literal: true

require 'find'
require 'cssminify2'
require 'htmlcompressor'
require 'json/minify'
require 'terser'

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
    merged_css << "\n#{media} {#{blocks.join("")}}"
  end
  
  merged_css
end


site_dir = File.join(Dir.pwd, '_site')
extensions = %w[css html js json]

if Dir.exist?(site_dir)
  files = extensions.flat_map { |ext| Dir.glob(File.join(site_dir, '**', "*.#{ext}")) }
  files.each do |file|
    ext = File.extname(file)
    begin
      content = File.read(file)
      shouldwrite = true
      minified =
        case ext
        when '.css'
          CSSminify2.compress(content)
        when '.html'
          HtmlCompressor::Compressor.new.compress(content)
        when '.json'
          JsonMinify.minify(content)
        when '.js'
          Terser.new.compile(content).to_s
        else
          shouldwrite = false
          content
        end
      if shouldwrite
        File.write(file, minified)
        puts "Minified /#{file[(file.index("_site"))..-1]}"
      end
    rescue => e
      msg = e.message.to_s.strip
      warn "Minification failed for #{file}#{": #{msg}" unless msg.empty?}"
    end
  end
end
