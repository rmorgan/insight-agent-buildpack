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

require 'spec_helper'
require 'java_buildpack/jre/memory/memory_size'

module JavaBuildpack::Jre

  describe 'Numeric memory size additions' do

    ONE_MEG = MemorySize.new('1M')
    HALF_A_MEG = MemorySize.new('512K')

    it 'should accept a memory size in bytes, kilobytes, megabytes, or gigabytes' do
      expect(MemorySize.new('1024B')).to eq(MemorySize.new('1k'))
      expect(MemorySize.new('1024b')).to eq(MemorySize.new('1k'))
      expect(MemorySize.new('1M')).to eq(MemorySize.new('1024k'))
      expect(MemorySize.new('1m')).to eq(MemorySize.new('1024k'))
      expect(MemorySize.new('1G')).to eq(MemorySize.new('1048576k'))
      expect(MemorySize.new('1g')).to eq(MemorySize.new('1048576k'))
    end

    it 'should fail if nil is passed to  the constructor' do
      expect { MemorySize.new(nil) }.to raise_error(/Invalid/)
    end

    it 'should fail if a memory size does not have a unit' do
      expect { MemorySize.new('1') }.to raise_error(/Invalid/)
    end

    it 'should fail if a memory size has an invalid unit' do
      expect { MemorySize.new('1A') }.to raise_error(/Invalid/)
    end

    it 'should fail if a memory size is not an number' do
      expect { MemorySize.new('xm') }.to raise_error(/Invalid/)
    end

    it 'should fail if a memory size is not an integer' do
      expect { MemorySize.new('1.1m') }.to raise_error(/Invalid/)
    end

    it 'should fail if a memory size has embedded whitespace' do
      expect { MemorySize.new('1 1m') }.to raise_error(/Invalid/)
    end

    it 'should accept a negative value' do
      expect(MemorySize.new('-1M')).to eq(MemorySize.new('-1024k'))
    end

    it 'should compare values correctly' do
      expect(ONE_MEG).to be < MemorySize.new('1025K')
      expect(MemorySize.new('1025K')).to be > ONE_MEG
    end

    it 'should fail when a memory size is compared to a numeric' do
      expect { MemorySize.new('1B') < 2 }.to raise_error(/Cannot\ compare/)
    end

    it 'should multiply values correctly' do
      expect(ONE_MEG * 2).to eq(MemorySize.new('2M'))
    end

    it 'should fail when a memory size is multiplied by a memory size' do
      expect { ONE_MEG * ONE_MEG }.to raise_error(/Cannot\ multiply/)
    end

    it 'should subtract memory values correctly' do
      expect(ONE_MEG - HALF_A_MEG).to eq(HALF_A_MEG)
    end

    it 'should fail when a numeric is subtracted from a memory size' do
      expect { ONE_MEG - 1 }.to raise_error(/Cannot\ subtract/)
    end

    it 'should add memory values correctly' do
      expect(HALF_A_MEG + HALF_A_MEG).to eq(ONE_MEG)
    end

    it 'should fail when a numeric is added to a memory size' do
      expect { ONE_MEG + 1 }.to raise_error(/Cannot\ add/)
    end

    it 'should divide a memory size by a numeric correctly' do
      expect(ONE_MEG / 2).to eq(HALF_A_MEG)
    end

    it 'should divide a memory size by a numeric using floating point' do
      expect(MemorySize.new('3B') / 2).to eq(MemorySize.new('2B'))
    end

    it 'should divide a memory size by another memory size correctly' do
      expect(ONE_MEG / HALF_A_MEG).to eq(2)
    end

    it 'should divide a memory size by another memory size using floating point' do
      expect(HALF_A_MEG / ONE_MEG).to eq(0.5)
    end

    it 'should fail when a memory size is divided by an incorrect type' do
      expect { MemorySize.new('1B') / '' }.to raise_error(/Cannot\ divide/)
    end

    it 'should provide a zero memory size' do
      expect(MemorySize::ZERO).to eq(JavaBuildpack::Jre::MemorySize.new('0B'))
    end

  end

end
