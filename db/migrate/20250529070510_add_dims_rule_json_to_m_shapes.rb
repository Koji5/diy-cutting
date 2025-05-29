class AddDimsRuleJsonToMShapes < ActiveRecord::Migration[8.0]
  def change
    add_column :m_shapes, :dims_rule_json, :jsonb, default: {}, null: false
  end
end
