# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

require 'tmpdir'
require 'webmock/rspec'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end

# Ensure a logger exists for any class under test that needs one.
require 'fileutils'
require 'java_buildpack/diagnostics/common'
require 'java_buildpack/diagnostics/logger_factory'
tmpdir = Dir.tmpdir
diagnostics_directory = File.join(tmpdir, JavaBuildpack::Diagnostics::DIAGNOSTICS_DIRECTORY)
FileUtils.rm_rf diagnostics_directory
JavaBuildpack::Diagnostics::LoggerFactory.create_logger tmpdir
