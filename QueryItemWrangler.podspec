Pod::Spec.new do |s|

  s.name         = "QueryItemWrangler"
  s.version      = "0.2"
  s.summary      = "A type-safe and friendly Swift API for NSURLComponents query items"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                    Easily manipulate NSURLQueryItem's in a type safe and swiftly manner
                   DESC

  s.homepage     = "https://github.com/js/QueryItemWrangler"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Johan Sørensen" => "johan@johansorensen.com" }
  s.social_media_url   = "http://twitter.com/johans"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10" # "'NSURLQueryItem' is only available on OS X 10.10 or newer"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/js/QueryItemWrangler.git", :tag => "#{s.version}" }
  s.source_files  = "Source/*.swift"
  #s.exclude_files = "Classes/Exclude"
end
