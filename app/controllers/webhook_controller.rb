class WebhookController < ApplicationController

  def index
    @project = Project.find_by(identifier: params[:project_id])
    @webhook = Webhook.find_or_initialize_by(project_id: @project.id)
  end

  def create
    flash[:notice] = l(:notice_successful_update)
    entity = Webhook.find_or_initialize_by(project_id: params[:project_id])
    entity.url = params[:url]
    entity.save!

    redirect_to request.referer
  end
end