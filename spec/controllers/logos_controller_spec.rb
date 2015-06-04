require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe LogosController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Logo. As you add validations to Logo, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  login_user
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LogosController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all logos as @logos" do
      logo = Logo.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:logos)).to eq([logo])
    end
  end

  describe "GET #show" do
    it "assigns the requested logo as @logo" do
      logo = FactoryGirl.create(:logo, owner: @account.user)
      get :show, {:id => logo.to_param}
      expect(assigns(:logo)).to eq(logo)
    end
  end

  describe "GET #new" do
    it "assigns a new logo as @logo" do
      get :new, {}, valid_session
      expect(assigns(:logo)).to be_a_new(Logo)
    end
  end

  describe "GET #edit" do
    it "assigns the requested logo as @logo" do
      logo = Logo.create! valid_attributes
      get :edit, {:id => logo.to_param}, valid_session
      expect(assigns(:logo)).to eq(logo)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Logo" do
        expect {
          post :create, {:logo => valid_attributes}, valid_session
        }.to change(Logo, :count).by(1)
      end

      it "assigns a newly created logo as @logo" do
        post :create, {:logo => valid_attributes}, valid_session
        expect(assigns(:logo)).to be_a(Logo)
        expect(assigns(:logo)).to be_persisted
      end

      it "redirects to the created logo" do
        post :create, {:logo => valid_attributes}, valid_session
        expect(response).to redirect_to(Logo.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved logo as @logo" do
        post :create, {:logo => invalid_attributes}, valid_session
        expect(assigns(:logo)).to be_a_new(Logo)
      end

      it "re-renders the 'new' template" do
        post :create, {:logo => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested logo" do
        logo = Logo.create! valid_attributes
        put :update, {:id => logo.to_param, :logo => new_attributes}, valid_session
        logo.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested logo as @logo" do
        logo = Logo.create! valid_attributes
        put :update, {:id => logo.to_param, :logo => valid_attributes}, valid_session
        expect(assigns(:logo)).to eq(logo)
      end

      it "redirects to the logo" do
        logo = Logo.create! valid_attributes
        put :update, {:id => logo.to_param, :logo => valid_attributes}, valid_session
        expect(response).to redirect_to(logo)
      end
    end

    context "with invalid params" do
      it "assigns the logo as @logo" do
        logo = Logo.create! valid_attributes
        put :update, {:id => logo.to_param, :logo => invalid_attributes}, valid_session
        expect(assigns(:logo)).to eq(logo)
      end

      it "re-renders the 'edit' template" do
        logo = Logo.create! valid_attributes
        put :update, {:id => logo.to_param, :logo => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested logo" do
      logo = Logo.create! valid_attributes
      expect {
        delete :destroy, {:id => logo.to_param}, valid_session
      }.to change(Logo, :count).by(-1)
    end

    it "redirects to the logos list" do
      logo = Logo.create! valid_attributes
      delete :destroy, {:id => logo.to_param}, valid_session
      expect(response).to redirect_to(logos_url)
    end
  end

end
