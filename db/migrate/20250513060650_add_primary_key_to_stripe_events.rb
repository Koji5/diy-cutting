# db/migrate/XXXXXXXXXX_add_primary_key_to_stripe_events.rb
class AddPrimaryKeyToStripeEvents < ActiveRecord::Migration[8.0]
  def change
    execute 'ALTER TABLE stripe_events ADD PRIMARY KEY (event_id);'
  end
end
