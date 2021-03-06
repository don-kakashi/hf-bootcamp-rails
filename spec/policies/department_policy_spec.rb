require 'spec_helper'

RSpec.describe DepartmentPolicy do

  let(:department) {
    FactoryBot.create :department
  }

  subject { DepartmentPolicy.new(account, department) }

  context "for a user" do
    let(:account) {
      FactoryBot.create :account
    }

    it { should_not permit :create }
    it { should_not permit :update }
    it { should_not permit :destroy }
  end

  context "for an admin" do
    let(:account) {
      FactoryBot.create :account, :admin
    }

    it { should permit :create }
    it { should permit :update }
    it { should permit :destroy }
  end
end
