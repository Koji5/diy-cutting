class MBank < ApplicationRecord
  has_many :m_branches, foreign_key: :bank_code, primary_key: :code
end
