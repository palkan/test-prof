# frozen_string_literal: true

require "spec_helper"

describe TestProf::RubyProf do
  # Use fresh config all for every example
  after { described_class.remove_instance_variable(:@config) }

  describe ".config" do
    subject { described_class.config }

    specify "defaults", :aggregate_failures do
      expect(subject.printer).to eq :flat
      expect(subject.mode).to eq :wall
      expect(subject.min_percent).to eq 1
      expect(subject.include_threads).to eq false
    end

    describe "#resolve_printer" do
      it "works with custom class" do
        subject.printer = TestProf
        expect(subject.resolve_printer).to eq(["custom", TestProf])
      end

      it "raises when unknown printer" do
        subject.printer = "unknown"
        expect { subject.resolve_printer }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#profile" do
    let(:ruby_prof) { double("ruby_prof") }
    let(:profile) { double("profile") }

    before do
      stub_const("RubyProf::Profile", ruby_prof)
      allow(profile).to receive(:exclude_common_methods!)
      allow(profile).to receive(:exclude_methods!)
      expect(profile).to receive(:start)
    end

    specify "with default config" do
      expect(ruby_prof).to receive(:new).with(
        merge_fibers: true,
        include_threads: [Thread.current]
      ).and_return(profile)

      expect(described_class.profile).to be_a(described_class::Report)
    end

    specify "with custom config" do
      described_class.config.include_threads = true

      expect(ruby_prof).to receive(:new).with(
        merge_fibers: true
      ).and_return(profile)

      described_class.profile
    end
  end

  describe "Report#dump" do
    let(:ruby_prof) { double("ruby_prof") }
    let(:profile) { double("profile") }
    let(:result) { double("result") }
    let(:printer_class) { double("printer_class") }
    let(:printer) { double("printer") }

    before do
      stub_const("::RubyProf::Profile", ruby_prof)
      expect(ruby_prof).to receive(:new).and_return(profile)
      expect(profile).to receive(:start)
      allow(profile).to receive(:exclude_methods!)
      expect(profile).to receive(:stop).and_return(result)
    end

    subject { described_class.profile }

    specify "with default config" do
      expect(profile).to receive(:exclude_common_methods!)

      stub_const("::RubyProf::FlatPrinter", printer_class)
      expect(printer_class).to receive(:new).with(result).and_return(printer)
      expect(printer).to receive(:print).with(anything, min_percent: 1).and_return("")

      subject.dump("stub")

      expect(File.exist?(File.join(TestProf.config.output_dir, "ruby-prof-report-flat-wall-stub.txt"))).to eq true
    end

    specify "with custom config" do
      described_class.config.printer = :call_stack
      described_class.config.exclude_common_methods = false
      described_class.config.test_prof_exclusions_enabled = false
      described_class.config.custom_exclusions = {
        TestProf => %i[log print]
      }
      described_class.config.min_percent = 2
      described_class.config.mode = :cpu

      TestProf.config.timestamps = true

      expect(profile).not_to receive(:exclude_common_methods!)
      expect(profile).to receive(:exclude_methods!).once.with(
        TestProf, :log, :print
      )

      stub_const("RubyProf::CallStackPrinter", printer_class)
      expect(printer_class).to receive(:new).with(result).and_return(printer)
      expect(printer).to receive(:print).with(anything, min_percent: 2).and_return("")
      expect(TestProf).to receive(:now).and_return(double("now", to_i: 123_454_321))

      subject.dump("stub")

      expect(File.exist?(File.join(TestProf.config.output_dir, "ruby-prof-report-call_stack-cpu-stub-123454321.html"))).to eq true
    end
  end
end
