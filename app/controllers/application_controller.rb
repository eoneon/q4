class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def str_to_class(assoc)
    assoc.to_s.singularize.classify.constantize
  end

  # def target_params
  #   set=[]
  #   assoc_params.map {|k| h={k => request.params[:product_item][k]}}.each do |h|
  #     hsh={h.keys.first => h[h.keys.first].delete_if {|k,v| v.blank?}}
  #     set << hsh unless hsh[h.keys.first].empty?
  #   end
  #   set
  # end
end
