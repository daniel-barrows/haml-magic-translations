# -*- coding: UTF-8 -*-

require 'spec_helper'
require 'haml/magic_translations/tasks'
require 'gettext/tools/xgettext'

module Haml::MagicTranslations::Tasks
  describe UpdatePoFiles do
    before do
      ::Rake.application.clear
    end

    def run
      ::Rake.application.tasks[0].invoke
    end

    context 'with text_domain is not set' do
      let(:task) { UpdatePoFiles.new }
      before do
        task.files = [ 'test' ]
        task.app_version = 'test 1.0'
        # silence abort message
        STDERR.stub(:write)
      end
      it 'should abort' do
        expect { run }.to raise_error(SystemExit)
      end
    end

    context 'with files is not set' do
      let(:task) { UpdatePoFiles.new }
      before do
        task.text_domain = 'test'
        task.app_version = 'test 1.0'
        # silence abort message
        STDERR.stub(:write)
      end
      it 'should abort' do
        expect { run }.to raise_error(SystemExit)
      end
    end

    context 'with app_version is not set' do
      let(:task) { UpdatePoFiles.new }
      before do
        task.text_domain = 'test'
        task.files = [ 'test' ]
        # silence abort message
        STDERR.stub(:write)
      end
      it 'should abort' do
        expect { run }.to raise_error(SystemExit)
      end
    end

    context 'with text_domain, files and app_version set' do
      let (:task) { UpdatePoFiles.new }
      before(:each) do
        task.text_domain = 'test'
        task.files = [ 'test' ]
        task.app_version = 'test 1.0'
      end
      it 'should call update_pofiles' do
        expect(GetText).to receive(:update_pofiles).with(
          task.text_domain, task.files, task.app_version, {})
        run
      end
      it 'should add a parser for ".haml" files to XGetText' do
        allow(GetText).to receive(:update_pofiles)
        expect(GetText::Tools::XGetText).to receive(:add_parser) do |haml_parser|
          expect(haml_parser).to respond_to(:parse)
          expect(haml_parser).to be_a_target('example.haml')
        end
        run
      end
      context 'with lang set' do
        it 'should pass lang in options' do
          task.lang = 'pl'
          allow(GetText).to receive(:update_pofiles).with(
            task.text_domain, task.files, task.app_version,
            hash_including(:lang => task.lang))
          run
        end
      end
      context 'with po_root set' do
        it 'should pass po_root in options' do
          task.po_root = 'test/po'
          expect(GetText).to receive(:update_pofiles).with(
            task.text_domain, task.files, task.app_version,
            hash_including(:po_root => task.po_root))
          run
        end
      end
      context 'with verbose set' do
        it 'should pass verbose in options' do
          task.verbose = true
          expect(GetText).to receive(:update_pofiles).with(
            task.text_domain, task.files, task.app_version,
            hash_including(:verbose => task.verbose))
          run
        end
      end
    end
  end
end
