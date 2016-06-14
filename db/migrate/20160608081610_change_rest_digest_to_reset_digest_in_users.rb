class ChangeRestDigestToResetDigestInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :rest_digest, :reset_digest
    rename_column :users, :rest_sent_at, :reset_sent_at
  end
end
