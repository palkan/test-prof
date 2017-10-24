# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../../../../lib", __FILE__)
require_relative "../../../support/ar_models"
require_relative "../../../support/transactional_context"
require "test_prof/recipes/rspec/before_all"

describe "User", :transactional do
  context "with before_all" do
    before_all do
      @user = TestProf::FactoryBot.create(:user)
    end

    let(:user) { User.find(@user.id) }

    it "validates name" do
      user.name = ''
      expect(user).not_to be_valid
    end

    it "clones" do
      cloned = user.clone
      cloned.save!
      expect(cloned.reload.name).to include("(cloned)")
    end
  end

  context "without before_all" do
    specify "no users" do
      expect(User.count).to eq 0
    end
  end

  context "inner before_all" do
    before_all do
      @user2 = TestProf::FactoryBot.create(:user)
    end

    specify { expect(User.find(@user2.id)).to be_a(User) }

    specify { expect(User.count).to eq 1 }
  end

  context "multiple before_all" do
    before_all do
      @user2 = TestProf::FactoryBot.create(:user)
    end

    before_all do
      @user3 = TestProf::FactoryBot.create(:user)
    end

    specify { expect(User.find(@user2.id)).to be_a(User) }

    specify { expect(User.find(@user3.id)).to be_a(User) }

    specify { expect(User.count).to eq 2 }
  end
end
