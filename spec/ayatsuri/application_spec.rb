require 'spec_helper'

module Ayatsuri
	describe Application do
		let(:klass) { described_class }

		before do
			stub_const("FakeOperator", Class.new)
		end

		describe ".ayatsuri_for" do
			subject { klass.ayatsuri_for exe_path, starter_name }

			let(:exe_path) { 'C:\Program Files\app.exe' }
			let(:starter_name) { :clickonce }

			before do
				Application::Starter.stub(:create).with(exe_path, starter_name) { starter }
			end

			let(:starter) { mock 'application starter' }

			it { subject; klass.starter.should == starter }
		end

		describe ".define_operation_order" do
			subject { klass.define_operation_order FakeOperator, &order_block }

			let(:order_block) { lambda { "operation index order" } }

			before do
				Operation::Order.stub(:create).with(&order_block).and_return(operation_order)
			end

			let(:operation_order) { mock 'operation order' }

			it { subject; klass.operator_class.should == FakeOperator }
			it { subject; klass.operation_order.should == operation_order }
		end

		describe ".application_attribute_methods" do
			subject { described_class.application_attribute_methods }
			let(:methods) { [:starter, :operator_class, :operation_order] }
			it { should == methods }
		end

		let(:model) { described_class.new }

		describe "#run" do
			subject { model.run params_for_operator }

			let(:params_for_operator) { mock 'parameters for task' }

			before do
				model.stub(:starter) { starter }
				model.stub(:operator_class) { operator_class }
				model.stub(:operation_order) { operation_order }
			end

			before do
				operator_class.stub(:new).with(params_for_operator) { operator }
				Application::Process.stub(:new).with(starter, operation_order, operator) { process }
				process.should_receive(:run).ordered
				described_class.should_receive(:reset_operation_order).ordered
			end

			let(:starter) { mock 'application starter' }
			let(:operation_order) { mock 'operation order' }
			let(:operator_class) { mock 'operator class' }
			let(:operator) { mock 'operator' }
			let(:process) { mock 'application process' }

			it "call run to application start process" do
				subject
			end
		end
	end
end
