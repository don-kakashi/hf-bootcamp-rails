require 'spec_helper'

describe "Objectives", type: :request do

  let(:valid_attributes) {
    FactoryBot.attributes_for :objective
  }

  let(:valid_attributes_child) {
    FactoryBot.attributes_for :objective, :child
  }

  let(:account) {
    FactoryBot.create :account
  }

  let(:department) {
    FactoryBot.create :department
  }

  let(:objectives) {
    FactoryBot.create_list(:objective, 10)
  }

  let(:objectives_tree) {
    FactoryBot.create :objective, :tree
  }

  let(:invalid_attributes) {
    FactoryBot.attributes_for(:objective).except(:name)
  }

  describe "GET /objectives" do
    context "with no search criteria specified" do
      before(:each) do
        get department_objectives_path(department.id, objectives[0].id),
          headers: auth_headers(account.id)
      end

      it "should return list of existing objectives" do
        objective_response = json_response[:data]
        expect(objective_response.size).to eql objectives.size
      end

      it { expect(response).to have_http_status(:ok) }
    end

    context "with name criteria specified" do
      before(:each) do
        get department_objectives_path(department.id, objectives[0].id),
          params: {name: objectives[0].name},
          headers: auth_headers(account.id)
      end

      it "should return list of objectives related to the specified name" do
        objective_response = json_response[:data]
        expect(objective_response[0][:attributes][:name]).to eql objectives[0].name
        expect(objective_response.size).to eql 1
      end

      it { expect(response).to have_http_status(:ok) }
    end

    context "with description criteria specified" do
      before(:each) do
        get department_objectives_path(department.id, objectives[0].id),
          params: {description: objectives[0].description},
          headers: auth_headers(account.id)
      end

      it "should return list of objectives related to the specified description" do
        objective_response = json_response[:data]
        expect(objective_response[0][:attributes][:description]).to eql objectives[0].description
        expect(objective_response.size).to eql objectives.size
      end

      it { expect(response).to have_http_status(:ok) }
    end
  end

  describe "GET /departments/:department_id/objectives/:id/tree" do
    before(:each) do
      get tree_department_objective_path(department.to_param, objectives_tree.to_param),
        headers: auth_headers(account.to_param)
    end

    it "should return tree of organizations" do
      organization_response = json_response
      expect(organization_response.first[:children].count).to eql objectives_tree.children.count
      expect(organization_response.first[:children].first[:children].count).to eql objectives_tree.children.first.children.count
    end

    it { expect(response).to have_http_status(:ok) }
  end


  describe "POST objectives/:id/objectives" do
    context "with valid params" do
      before(:each) do
        post department_objectives_path(department.id),
          headers: auth_headers(account.id),
          params: { objective: valid_attributes }
      end

      it "should return the objective" do
        objective_response = json_response[:data][:attributes]
        expect(objective_response[:name]).to eql valid_attributes[:name]
      end

      it { expect(response).to have_http_status(:created) }
    end

    context "with child valid params" do
      before(:each) do
        post department_objectives_path(department.id),
          headers: auth_headers(account.id),
          params: { objective: valid_attributes_child }
      end

      it "should return the objective" do
        objective_response = json_response[:data][:attributes]
        expect(objective_response[:name]).to eql valid_attributes_child[:name]
      end

      it { expect(response).to have_http_status(:created) }
    end

    context "with unauth user" do
      before(:each) do
        post department_objectives_path(department.id),
          params: { objective: valid_attributes }
      end

      it { expect(response).to have_http_status(:unauthorized) }
    end

    context "with missing attribute name" do
      before(:each) do
        post department_objectives_path(department.id),
          headers: auth_headers(account.id),
          params: { objective: invalid_attributes }
      end

      it "renders the json errors on why the Objective could not be created, due to missing name" do
        expect(json_response[:name]).to include "can't be blank"
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
    end
  end
end
