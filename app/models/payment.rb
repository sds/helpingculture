class Payment < ActiveRecord::Base
  STATUSES = [
    STATUS_IN_PROGRESS = 'P',
    STATUS_RECEIVED = 'R',
  ]

  attr_accessible :ticket_request, :ticket_request_id, :status,
    :stripe_charge_id, :stripe_card_token

  attr_accessor :stripe_card_token

  validates_presence_of :ticket_request_id, :status

  validates_inclusion_of :status, in: STATUSES

  belongs_to :ticket_request

  def save_and_charge
    if valid?
      charge = Stripe::Charge.create(
        amount: (ticket_request.price * 100).to_i, # in cents
        currency: 'usd',
        card: stripe_card_token,
        description: "#{ticket_request.event.name} Ticket",
      )
      self.stripe_charge_id = charge.id
      self.status = STATUS_RECEIVED
      save!
    end
  rescue Stripe::StripeError => e
    errors.add :base, e.message
    false
  end

  def can_view?(user)
    ticket_request.can_view?(user)
  end

  def due_date
    (created_at + 2.weeks).to_date
  end

  def in_progress?
    status == STATUS_IN_PROGRESS
  end

  def received?
    status == STATUS_RECEIVED
  end
end
