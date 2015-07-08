module Doorkeeper
  module ApplicationMixin
    extend ActiveSupport::Concern

    include OAuth::Helpers
    include Models::Scopes
    alias_attribute :scopes, :valid_scopes
    include ActiveModel::MassAssignmentSecurity if defined?(::ProtectedAttributes)

    included do
      has_many :access_grants, dependent: :destroy, class_name: 'Doorkeeper::AccessGrant'
      has_many :access_tokens, dependent: :destroy, class_name: 'Doorkeeper::AccessToken'

      validates :name, :secret, :uid, presence: true
      validates :uid, uniqueness: true
      validates :redirect_uri, redirect_uri: true
      validates :valid_scopes, presence: true, if: Proc.new { |p| p.respond_to?(:valid_scopes) && scope_required? }

      before_validation :generate_uid, :generate_secret, on: :create

      if respond_to?(:attr_accessible)
        attr_accessible :name, :redirect_uri, :valid_scopes, :scope_required
      end
    end

    module ClassMethods
      def by_uid_and_secret(uid, secret)
        where(uid: uid.to_s, secret: secret.to_s).limit(1).to_a.first
      end

      def by_uid(uid)
        where(uid: uid.to_s).limit(1).to_a.first
      end
    end

    alias_method :original_scopes, :scopes
    def scopes
      if has_scopes?
        original_scopes
      else
        fail NameError, "Missing column: `applications.scopes`.", <<-MSG.squish
If you are using ActiveRecord run `rails generate doorkeeper:application_scopes
&& rake db:migrate` to add it.
        MSG
      end
    end

    private

    def has_scopes?
      Doorkeeper.configuration.orm != :active_record ||
        Application.new.attributes.include?("scopes")
    end

    def generate_uid
      self.uid ||= UniqueToken.generate
    end

    def generate_secret
      self.secret ||= UniqueToken.generate
    end
  end
end
