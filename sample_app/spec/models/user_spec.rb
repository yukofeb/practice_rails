require 'rails_helper'

RSpec.describe User, type: :model do
  before { @user = User.new(name: "Test User", email: "test@gmail.com",
      password: "foobar", password_confirmation: "foobar") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = "" }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = "" }
    it { should_not be_valid }
  end

  describe "when password is not present" do
    before do
      @user.password = ""
      @user.password_confirmation = ""
    end
    it { should_not be_valid }
  end

  describe "when password_confirmation is not present" do
    before { @user.password_confirmation = "" }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email is too long" do
    before { @user.email = "a" * 100 + "@gmail.com" }
    it { should_not be_valid }
  end

  describe "when email format is valid" do
    it "should be valid" do
      valid_addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      valid_addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      invalid_addresses = %w[aaa.com abc@ aaa@zzz]
      invalid_addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email is already taken" do
    before do
      dup_user = @user.dup
      dup_user.save
    end

    it { should_not be_valid }

    before do
      big_capital_user = @user.dup
      big_capital_user.email = @user.email.upcase
      big_capital_user.save
    end

    it { should_not be_valid }
  end

  describe "when password doesn't match password_confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "return valid of authoenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:invalid_password_user) { found_user.authenticate("invalid") }

      it { should_not eq invalid_password_user }
      specify { expect(invalid_password_user).to be_falsey }
    end
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end
end