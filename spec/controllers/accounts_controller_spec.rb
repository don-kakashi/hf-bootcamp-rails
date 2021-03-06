require 'spec_helper'

describe AccountsController do

  let(:valid_attributes) {
    FactoryBot.attributes_for :account
  }

  let(:invalid_attributes) {
    { password: "12345678" }
  }

  let(:valid_invited_user) {
    { email: FFaker::Internet.email }
  }

  let(:invalid_invited_user) {
    { email: FFaker::Name.name }
  }

  let(:admin_account) {
    FactoryBot.create :account, :admin
  }

  describe "POST #signup" do
    context "with valid params" do
      it "creates a new Account" do
        expect {
          post :signup, params: {account: valid_attributes}
        }.to change(Account, :count).by(1)
      end
    end

    context "with invalid params" do
      it "does not create a new Account" do
        expect {
          post :signup, params: {account: invalid_attributes}
        }.to change(Account, :count).by(0)
      end
    end
  end

  describe "POST #invite" do
    context "with valid params" do
      it "creates a new Account for the invited user" do
        request.headers.merge!(auth_headers(admin_account.id))
        expect {
          post :invite,
               params: { account: valid_invited_user }
        }.to change(Account, :count).by(1)
      end
    end

    context "with invalid params" do
      it "does not create a new Account" do
        expect {
          post :invite,
               params: { account: invalid_invited_user }
        }.to change(Account, :count).by(0)
      end
    end
  end
end
