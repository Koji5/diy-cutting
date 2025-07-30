class Api::BanksController < ApplicationController
  def search
    q = params[:q].to_s.strip

    if q.present?
      banks = MBank.where("name_kana LIKE ? OR name LIKE ?", "#{q}%", "#{q}%").limit(20)
    else
      banks = MBank.none
    end

    render json: banks.select(:code, :name, :name_kana)
  end
end
