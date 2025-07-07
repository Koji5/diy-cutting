class CartPart < ApplicationRecord
  belongs_to :cart
  belongs_to :part
end
