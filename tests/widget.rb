#!/usr/bin/env ruby
# Run the real QML and WidgetButton delegates, with bar commands captured.
require 'fileutils'
require 'open3'
require 'tmpdir'

repo = File.expand_path('..', __dir__)
shell = File.join(ENV.fetch('OMARCHY_PATH', '/usr/share/omarchy'), 'shell')
abort 'Run this test in an Omarchy/Hyprland session' unless ENV['HYPRLAND_INSTANCE_SIGNATURE'] && File.directory?(shell)
cache = File.join(Dir.home, '.cache', 'omarchy-global-workspaces-tests')
FileUtils.mkdir_p(cache)

Dir.mktmpdir('widget-', cache) do |stage|
  %w[Commons Ui].each { |name| File.symlink(File.join(shell, name), File.join(stage, name)) }
  FileUtils.cp(ARGV.first || File.join(repo, 'Workspaces.qml'), File.join(stage, 'Workspaces.qml'))
  FileUtils.cp(File.join(repo, 'WorkspacesModel.js'), stage)
  FileUtils.cp(File.join(__dir__, 'widget.qml'), File.join(stage, 'shell.qml'))
  output, status = Open3.capture2e(
    { 'QT_QPA_PLATFORM' => 'offscreen', 'QT_QPA_PLATFORMTHEME' => 'basic', 'QT_STYLE_OVERRIDE' => 'Fusion' },
    'timeout', '15s', 'quickshell', '-p', stage, '--no-color'
  )
  unless status.success? && output.include?('WIDGET_TEST_PASS') && !output.match?(/WIDGET_TEST_FAIL|TypeError|ReferenceError|Error loading configuration/)
    warn output
    abort 'Widget interaction test failed'
  end
  puts 'Widget interaction test passed: number clicks, focused layout click, scroll, high IDs and vertical layout'
end
Dir.rmdir(cache) if Dir.empty?(cache)
