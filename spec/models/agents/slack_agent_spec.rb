require 'spec_helper'

describe Agents::SlackAgent do
  before(:each) do
    @valid_params = {
                      'webhook_url' => 'https://hooks.slack.com/services/random1/random2/token',
                      'channel' => '#random',
                      'username' => "{{username}}",
                      'message' => "{{message}}"
                    }

    @checker = Agents::SlackAgent.new(:name => "slacker", :options => @valid_params)
    @checker.user = users(:jane)
    @checker.save!

    @event = Event.new
    @event.agent = agents(:bob_weather_agent)
    @event.payload = { :channel => '#random', :message => 'Looks like its going to rain', username: "Huggin user"}
    @event.save!
  end

  describe "validating" do
    before do
      expect(@checker).to be_valid
    end

    it "should require a webhook_url" do
      @checker.options['webhook_url'] = nil
      expect(@checker).not_to be_valid
    end

    it "should require a channel" do
      @checker.options['channel'] = nil
      expect(@checker).not_to be_valid
    end
  end

  describe "#receive" do
    it "receive an event without errors" do
      any_instance_of(Slack::Notifier) do |obj|
        mock(obj).ping(@event.payload[:message],
                       channel: @event.payload[:channel],
                       username: @event.payload[:username]
                      )
      end

      expect { @checker.receive([@event]) }.not_to raise_error
    end
  end

  describe "#working?" do
    it "should call received_event_without_error?" do
      mock(@checker).received_event_without_error?
      @checker.working?
    end
  end
end
