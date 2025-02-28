# frozen_string_literal: true

class EnablePolymorphicResourceOwner < ActiveRecord::Migration[6.1]
  def change
    add_column :oauth_access_tokens, :resource_owner_type, :string
    add_column :oauth_access_grants, :resource_owner_type, :string
    change_column_null :oauth_access_grants, :resource_owner_type, false

    add_index :oauth_access_tokens,
      %i[resource_owner_id resource_owner_type],
      name: "polymorphic_owner_oauth_access_tokens"

    add_index :oauth_access_grants,
      %i[resource_owner_id resource_owner_type],
      name: "polymorphic_owner_oauth_access_grants"
  end
end
