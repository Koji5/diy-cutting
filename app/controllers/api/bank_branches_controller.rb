class Api::BankBranchesController < ApplicationController
  def search_bank
    q = params[:q].to_s.strip
    q = q.gsub(/銀行\z/, "")
    keyword = q.tr("ぁ-ん", "ァ-ン")

    banks = if q.present?
      MBank.where("name_kana LIKE ? OR name LIKE ?", "#{keyword}%", "#{q}%")
           .select(:code, :name)
           .limit(20)
    else
      MBank.none
    end

    render json: banks
  end

  def show_bank
    bank = MBank.find_by!(code: params[:code])
    render json: { code: bank.code, name: bank.name }
  end

  def search_branch
    q = params[:q].to_s.strip
    q = q.gsub(/支店\z/, "")
    keyword = q.tr("ぁ-ん", "ァ-ン")
    bank_code = params[:code]

    branches = if q.present?
      MBranch.where(bank_code: bank_code)
             .where("name_kana LIKE ? OR name LIKE ?", "#{keyword}%", "#{q}%")
             .select(:code, :name)
             .limit(20)
    else
      MBranch.none
    end

    render json: branches
  end

  def branch_list
    branches = MBranch.where(bank_code: params[:code])
                      .select(:code, :name)
                      .order(:code)
    render json: branches
  end
end
