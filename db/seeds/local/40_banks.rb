# db/seeds/local/40_banks.rb

require "json"

puts "[SEED] 銀行・支店マスタをインポート中..."

banks_path    = Rails.root.join("db/data/banks.json")
branches_path = Rails.root.join("db/data/branches")

unless File.exist?(banks_path)
  puts "⚠️ banks.json が見つかりません: #{banks_path}"
  return
end

banks_data = JSON.parse(File.read(banks_path))

banks_data.each do |bank_code, bank_info|
  bank = MBank.find_or_create_by!(code: bank_code) do |b|
    b.name       = bank_info["name"]
    b.name_kana  = bank_info["kana"]
  end

  branch_file = branches_path.join("#{bank_code}.json")
  unless File.exist?(branch_file)
    puts "⚠️ branches/#{bank_code}.json が見つかりません"
    next
  end

  branch_data = JSON.parse(File.read(branch_file))

  branch_data.each do |branch_code, branch_info|
    MBranch.find_or_create_by!(bank_code: bank_code, code: branch_code) do |b|
      b.name       = branch_info["name"]
      b.name_kana  = branch_info["kana"]
    end
  end
end

puts "[SEED] 銀行・支店マスタのインポートが完了しました。"
