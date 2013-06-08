require 'spec_helper'

describe TicketRequest do
  it 'has a valid factory' do
    TicketRequest.make.should be_valid
  end

  describe 'validations' do
    subject { ticket_request }

    describe '#user' do
      let(:ticket_request) { TicketRequest.make user: user }

      context 'when not present' do
        let(:user) { nil }
        it { should_not be_valid }
      end

      context 'when user exists' do
        let(:user) { User.make! }

        it { should be_valid }
      end

      context 'when user does not exist' do
        let(:user) { User.make! }

        before do
          user.delete
        end

        it { should_not be_valid }
      end

      context 'when the user has other ticket requests' do
        let(:event) { Event.make! }
        let(:user) { User.make! }
        let(:ticket_request) { TicketRequest.make event: event, user: user }

        context 'and they already have a request for this event' do
          before do
            TicketRequest.make! event: event, user: user
          end

          it { should_not be_valid }
        end

        context 'and they have created requests only for other events' do
          before do
            TicketRequest.make user: user
          end

          it { should be_valid }
        end
      end
    end

    describe '#event' do
      let(:ticket_request) { TicketRequest.make event: event }

      context 'when not present' do
        let(:event) { nil }
        it { should_not be_valid }
      end

      context 'when event does not exist' do
        let(:event) { Event.make! }

        before do
          event.delete
        end

        it { should_not be_valid }
      end

      context 'when event exists' do
        let(:event) { Event.make! }

        it { should be_valid }
      end
    end

    describe '#address' do
      let(:ticket_request) { TicketRequest.make address: address }

      context 'when not present' do
        let(:address) { nil }
        it { should_not be_valid }
      end

      context 'when present' do
        let(:address) { '123 Fake Street' }
        it { should be_valid }
      end
    end

    describe '#adults' do
      let(:ticket_request) { TicketRequest.make adults: adults }

      context 'when not present' do
        let(:adults) { nil }
        it { should_not be_valid }
      end

      context 'when not a number' do
        let(:adults) { 'not a number' }
        it { should_not be_valid }
      end

      context 'when a number' do
        let(:adults) { 2 }
        it { should be_valid }
      end
    end

    describe '#kids' do
      let(:ticket_request) { TicketRequest.make kids: kids }

      context 'when not present' do
        let(:kids) { nil }
        it { should be_valid }
      end

      context 'when not a number' do
        let(:kids) { 'not a number' }
        it { should_not be_valid }
      end

      context 'when a number' do
        let(:kids) { 2 }
        it { should be_valid }
      end
    end

    describe '#cabins' do
      let(:ticket_request) { TicketRequest.make cabins: cabins }

      context 'when not present' do
        let(:cabins) { nil }
        it { should be_valid }
      end

      context 'when not a number' do
        let(:cabins) { 'not a number' }
        it { should_not be_valid }
      end

      context 'when a number' do
        let(:cabins) { 2 }
        it { should be_valid }
      end
    end

    describe '#volunteer_shifts' do
      let(:ticket_request) { TicketRequest.make volunteer_shifts: shifts }

      context 'when not present' do
        let(:shifts) { nil }
        it { should be_valid }
      end

      context 'when not a number' do
        let(:shifts) { 'not a number' }
        it { should_not be_valid }
      end

      context 'when a number' do
        let(:shifts) { 2 }
        it { should be_valid }
      end
    end

    describe '#notes' do
      let(:ticket_request) { TicketRequest.make notes: notes }

      context 'when not present' do
        let(:notes) { nil }
        it { should be_valid }
      end

      context 'when empty' do
        let(:notes) { '' }

        it { should be_valid }

        it 'replaces the empty string with nil' do
          ticket_request.valid?
          ticket_request.notes.should be_nil
        end
      end

      context 'when longer than 500 characters' do
        let(:notes) { Sham.string(501) }
        it { should_not be_valid }
      end
    end
  end

  describe '#can_view?' do
    let(:requester) { User.make! }
    subject { TicketRequest.make(user: requester).can_view?(user) }

    context 'when the user is a site admin' do
      let(:user) { User.make! :site_admin }
      it { should be_true }
    end

    context 'when the user is the ticket request creator' do
      let(:user) { requester }
      it { should be_true }
    end

    context 'when the user is anybody else' do
      let(:user) { User.make! }
      it { should be_false }
    end
  end

  describe '#pending?' do
    context 'when the ticket request is pending' do
      subject { TicketRequest.make(:pending).pending? }
      it { should be_true }
    end
  end

  describe '#approved?' do
    context 'when the ticket request is approved' do
      subject { TicketRequest.make(:approved).approved? }
      it { should be_true }
    end
  end

  describe '#approve' do
    subject { TicketRequest.make(:pending, special_price: price) }

    before do
      subject.approve
    end

    context 'when the ticket request has a price of zero dollars' do
      let(:price) { 0 }
      it { should be_completed }
    end

    context 'when the ticket request has a price greater than zero dollars' do
      let(:price) { 10 }
      it { should be_approved }
    end
  end

  describe '#declined?' do
    context 'when the ticket request is declined' do
      subject { TicketRequest.make(:declined).declined? }
      it { should be_true }
    end
  end

  describe '#price' do
    let(:adult_price) { 10 }
    let(:adults) { 2 }
    let(:kid_price) { nil }
    let(:kids) { nil }
    let(:cabin_price) { nil }
    let(:cabins) { nil }
    let(:special_price) { nil }
    let(:event) do
      Event.make!(
        adult_ticket_price: adult_price,
        kid_ticket_price: kid_price,
        cabin_price: cabin_price,
      )
    end
    let(:ticket_request) do
      TicketRequest.make(
        event: event,
        adults: adults,
        kids: kids,
        cabins: cabins,
        special_price: special_price,
      )
    end
    subject { ticket_request.price  }

    context 'when kid ticket price is not set on the event' do
      it { should == adult_price * adults }
    end

    context 'when the ticket request includes kids' do
      let(:kids) { 2 }
      let(:kid_price) { 10 }
      it { should == adult_price * adults + kid_price * kids }
    end

    context 'when the ticket request does not include kids' do
      let(:kids) { nil }
      it { should == adult_price * adults }
    end

    context 'when the ticket request includes cabins' do
      let(:cabins) { 2 }
      let(:cabin_price) { 100 }
      it { should == adult_price * adults + cabin_price * cabins }
    end

    context 'when the ticket request does not include cabins' do
      let(:cabins) { nil }
      it { should == adult_price * adults }
    end

    context 'when a special price is set' do
      let(:special_price) { 99.99 }
      it { should == special_price }
    end

    context 'when custom price rules are defined' do
      let(:kid_price) { 10 }
      let(:trigger_value) { 3 }
      let(:custom_price) { 5 }

      before do
        PriceRule::KidsEqualTo.create! event: event,
                                       trigger_value: trigger_value,
                                       price: custom_price
      end

      context 'and the rule does not apply' do
        let(:kids) { trigger_value - 1 }
        it { should == (adult_price * adults) + (kid_price * kids) }
      end

      context 'and the rule applies' do
        let(:kids) { trigger_value }
        it { should == (adult_price * adults) + 5 }
      end
    end
  end

  describe '#total_tickets' do
    it 'is the sum of the number of adults and children' do
      TicketRequest.make(adults: 3, kids: 2).total_tickets == 5
    end
  end
end
