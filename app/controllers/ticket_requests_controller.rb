class TicketRequestsController < ApplicationController
  before_filter :authenticate_user!,
    only: [:index, :show, :edit, :update, :approve, :decline]
  before_filter :require_site_admin,
    only: [:index, :edit, :update, :approve, :decline]

  def index
    @ticket_requests = TicketRequest.all.sort_by(&:created_at).reverse
  end

  def show
    @ticket_request = TicketRequest.find(params[:id])
  end

  def new
    @ticket_request = TicketRequest.new
  end

  def edit
    @ticket_request = TicketRequest.find(params[:id])
  end

  def create
    @ticket_request = TicketRequest.new(params[:ticket_request])

    if @ticket_request.save
      flash[:notice] = 'Your ticket request was successfully recorded.'
      redirect_to @ticket_request
    else
      render action: 'new'
    end
  end

  def update
    @ticket_request = TicketRequest.find(params[:id])

    if @ticket_request.update_attributes(params[:ticket_request])
      flash[:notice] = 'Ticket request was successfully updated.'
      redirect_to @ticket_request
    else
      render action: 'edit'
    end
  end

  def approve
    @ticket_request = TicketRequest.find(params[:id])

    if @ticket_request.update_attributes(status: TicketRequest::STATUS_APPROVED)
      TicketRequestMailer.request_approved(@ticket_request).deliver

      flash[:notice] = "#{@ticket_request.name}'s request was approved"
      redirect_to ticket_requests_path
    else
      flash[:error] = "Unable to approve #{@ticket_request.name}'s request"
      redirect_to ticket_requests_path
    end
  end

  def decline
    @ticket_request = TicketRequest.find(params[:id])

    if @ticket_request.update_attributes(status: TicketRequest::STATUS_DECLINED)
      flash[:notice] = "#{@ticket_request.name}'s request was declined"
      redirect_to ticket_requests_path
    else
      flash[:error] = "Unable to decline #{@ticket_request.name}'s request"
      redirect_to ticket_requests_path
    end
  end
end
