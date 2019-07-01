require 'remote_factory_bot'
require 'spec_helper'

describe RemoteFactoryBot do
  describe '#create' do

    let(:http) { double('RemoteFactoryBot::Http') }
    let(:factory_attributes) { { :first_name => 'Sam' } }

    context 'when remote configuration does not specify a remote name' do

      before do
        configure_remote_factory_bot(host: 'localhost',
                                      port: 3000)
      end

      it "should send a post request to remote" do
        config     = RemoteFactoryBot.config
        expect(http).to receive(:post).with(config, {:factory => :user, :attributes => factory_attributes})
        RemoteFactoryBot::RemoteFactoryBot.new(config).create(:user, factory_attributes, http)
      end
    end

    context 'when multiple remotes are configured' do
      before do
        configure_remote_factory_bot(remote_name: :travis,
                                      host: 'localhost',
                                      port: 3000,
                                      end_point: '/remote_factory_bot/travis/home')
        configure_remote_factory_bot(remote_name: :casey,
                                      host: 'over_the_rainbow',
                                      port: 6000,
                                      end_point: '/remote_factory_bot/casey/home')
      end

      it "should be configured to send HTTP requests to 'travis' remote" do
        remote_config_travis = RemoteFactoryBot.config(:travis)
        remote_factory_bot  = RemoteFactoryBot::RemoteFactoryBot.new(remote_config_travis)

        expect(remote_factory_bot).to receive(:create).with(:user, factory_attributes, http) do |_, _, _|
          expect(
            remote_factory_bot.config.home_url
          ).to eq('http://localhost:3000/remote_factory_bot/travis/home')
        end

        remote_factory_bot.create(:user, factory_attributes, http)
      end

      it "should be configured to send HTTP requests to 'casey' remote" do
        remote_config_casey = RemoteFactoryBot.config(:casey)
        remote_factory_bot = RemoteFactoryBot::RemoteFactoryBot.new(remote_config_casey)

        expect(remote_factory_bot).to receive(:create).with(:user, factory_attributes, http) do |_, _, _|
          expect(
            remote_factory_bot.config.home_url
          ).to eq('http://over_the_rainbow:6000/remote_factory_bot/casey/home')
        end

        remote_factory_bot.create(:user, factory_attributes, http)
      end
    end
  end

  xit 'should be able to configure with a block' do
    # TODO: Remove
    pending
  end

  describe '.reset' do
    context 'when multiple remotes are configured' do

      before do
        configure_remote_factory_bot(remote_name: :travis,
                                      host: 'localhost',
                                      port: 3000,
                                      end_point: '/remote_factory_bot/travis/home')
        configure_remote_factory_bot(remote_name: :casey,
                                      host: 'over_the_rainbow',
                                      port: 6000,
                                      end_point: '/remote_factory_bot/casey/home')

      end

      it 'should be able to reset the configuration' do
        RemoteFactoryBot.remotes_config.reset
        expect(RemoteFactoryBot.remotes_config.to_hash.keys).to eq([:default])
      end
    end

    context 'when only one remote configuration and does not specify a remote name' do
      before do
        configure_remote_factory_bot(host: 'not_configured_with_name',
                                      port: 9000)
      end

      it 'should be able to reset the configuration' do
        RemoteFactoryBot.remotes_config.reset
        expect(RemoteFactoryBot.remotes_config.to_hash.keys).to eq([:default])
      end
    end
  end

  describe '.factories' do
    context 'when multiple remotes are configured' do

      let(:http) { double('RemoteFactoryBot::Http') }

      before do
        configure_remote_factory_bot(remote_name: :travis,
                                      host: 'localhost',
                                      port: 3000,
                                      end_point: '/remote_factory_bot/travis/home')
        configure_remote_factory_bot(remote_name: :casey,
                                      host: 'over_the_rainbow',
                                      port: 6000,
                                      end_point: '/remote_factory_bot/casey/home')
      end

      it "should be configured to send HTTP requests to 'travis' remote" do
        remote_config_travis = RemoteFactoryBot.config(:travis)
        remote_factory_bot  = RemoteFactoryBot::RemoteFactoryBot.new(remote_config_travis)

        expect(remote_factory_bot).to receive(:factories).with({}, http) do |_, _|
          expect(
            remote_factory_bot.config.home_url
          ).to eq('http://localhost:3000/remote_factory_bot/travis/home')
        end

        remote_factory_bot.factories({}, http)
      end

      it "should be configured to send HTTP requests to 'casey' remote" do
        remote_config_casey = RemoteFactoryBot.config(:casey)
        remote_factory_bot = RemoteFactoryBot::RemoteFactoryBot.new(remote_config_casey)

        expect(remote_factory_bot).to receive(:factories).with({}, http) do |_, _|
          expect(
            remote_factory_bot.config.home_url
          ).to eq('http://over_the_rainbow:6000/remote_factory_bot/casey/home')
        end

        remote_factory_bot.factories({}, http)
      end
    end
  end

  describe '.create' do
    describe 'when not returning active resource object' do
      pending
    end

    describe 'when returning active resource object' do
      pending
    end
  end
end
