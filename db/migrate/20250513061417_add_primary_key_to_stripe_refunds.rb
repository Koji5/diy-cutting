# db/migrate/XXXXXXXXXX_add_primary_key_to_stripe_refunds.rb
class AddPrimaryKeyToStripeRefunds < ActiveRecord::Migration[8.0]
  def change
    execute 'ALTER TABLE stripe_refunds ADD PRIMARY KEY (refund_id);'
  end
end
