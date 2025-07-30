class MBranch < ApplicationRecord
  belongs_to :m_bank, foreign_key: :bank_code, primary_key: :code
end
