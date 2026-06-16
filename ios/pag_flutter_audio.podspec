Pod::Spec.new do |s|
  s.name             = 'pag_flutter_audio'
  s.version          = '0.1.0'
  s.summary          = 'Flutter plugin for PAG files with audio support.'
  s.description      = <<-DESC
A Flutter plugin for playing PAG files with audio support. Wraps libpag with audio playback capabilities.
                       DESC
  s.homepage         = 'https://github.com/yourusername/pag_flutter_audio'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your@email.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'pag'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
