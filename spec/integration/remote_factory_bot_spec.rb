require 'remote_factory_bot'
require 'spec_helper'

describe RemoteFactoryBot do

  before { RemoteFactoryBot.remotes_config.reset }

  describe 'configuration' do
    it 'should be configured with correct defaults' do
      expect(RemoteFactoryBot.config.home).to eq({ :host      => nil,
                                                    :port      => nil,
                                                    :end_point => '/remote_factory_bot/home'})
      expect(RemoteFactoryBot.config.return_response_as).to eq(:as_hash)
      expect(RemoteFactoryBot.config.return_with_root).to eq true
      expect(RemoteFactoryBot.config.return_as_active_resource).to eq false
      expect(RemoteFactoryBot.config.https).to eq false
    end

    it 'should be able to configure with a block' do
      RemoteFactoryBot.configure do |config|
        config.home = { host: 'tifton' }
      end
      expect(RemoteFactoryBot.config.home[:host]).to eq('tifton')
    end

    it 'should be able to configure .home' do
      RemoteFactoryBot.config.home[:host] = 'fun_guy'
      RemoteFactoryBot.config.home[:port] = 3333
      RemoteFactoryBot.config.home[:end_point] = '/down_home'
      expect(RemoteFactoryBot.config.home[:host]).to eq('fun_guy')
      expect(RemoteFactoryBot.config.home[:port]).to eq(3333)
      expect(RemoteFactoryBot.config.home[:end_point]).to eq('/down_home')
    end

    it 'should be able to configure .return_response_as' do
      expect(RemoteFactoryBot.config.return_response_as).to eq(:as_hash)
    end

    it 'should be able to configure .return_with_root' do
      RemoteFactoryBot.config.return_with_root = false
      expect(RemoteFactoryBot.config.return_with_root).to eq false
    end

    it 'should be able to configure .return_as_active_resource' do
      RemoteFactoryBot.config.return_as_active_resource = true
      expect(RemoteFactoryBot.config.return_as_active_resource).to eq true
    end

    it 'should be able to configure https' do
      RemoteFactoryBot.config.https = true
      expect(RemoteFactoryBot.config.https).to eq true
    end

    context 'when configuring multiple remotes' do

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

      it 'should return configuration for remote "travis"' do
        expect(RemoteFactoryBot.config(:travis).home).to eq({:host      => 'localhost',
                                                              :port      => 3000,
                                                              :end_point => '/remote_factory_bot/travis/home'})
        expect(RemoteFactoryBot.config(:travis).return_with_root).to eq(true)
        expect(RemoteFactoryBot.config(:travis).return_response_as).to eq(:as_hash)
      end

      it 'should return configuration for remote "casey"' do
        expect(RemoteFactoryBot.config(:casey).home).to eq({:host      => 'over_the_rainbow',
                                                             :port      => 6000,
                                                             :end_point => '/remote_factory_bot/casey/home'})
      end
    end
  end

  describe 'errors' do
    it 'should raise RemoteFactoryBotConfigError if .config.home[:host] is nil' do
      RemoteFactoryBot.config.home[:host] = nil
      expect { RemoteFactoryBot.create(:site) }.to raise_error(RemoteFactoryBot::RemoteFactoryBotConfigError)
    end

    it 'should raise RemoteFactoryBotConfigError if .config.home[:end_point] is nil' do
      RemoteFactoryBot.config.home[:end_point] = nil
      expect { RemoteFactoryBot.create(:site) }.to raise_error(RemoteFactoryBot::RemoteFactoryBotConfigError)
    end
  end

  describe 'creating a remote factory' do

    before do
      allow(RestClient).to receive(:post).and_return('{"user": {"id": "1", "first_name": "Sam", "last_name": "Iam"}}')
      allow(RestClient).to receive(:get).and_return('["user", "user_admin"]')
    end

    describe '.factories' do
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

        context 'for remote "travis"' do
          it 'should return all factories available' do
            expect(RemoteFactoryBot.with_remote(:travis).factories).to match_array(['user', 'user_admin'])
          end

          it 'should be configured to send HTTP request to remote "travis"' do
            remote_factory_bot = RemoteFactoryBot.with_remote(:travis)

            expect(remote_factory_bot).to receive(:factories) do
              expect(
                remote_factory_bot.remotes_config.current_remote
              ).to eq(:travis)
              expect(
                remote_factory_bot.config(:travis).home_url
              ).to eq('http://localhost:3000/remote_factory_bot/travis/home')
            end
            remote_factory_bot.factories
          end
        end

        context 'for remote "casey"' do
          it 'should return all factories available' do
            expect(RemoteFactoryBot.with_remote(:casey).factories).to match_array(['user', 'user_admin'])
          end

          it 'should be configured to send HTTP request to remote "casey"' do
            remote_factory_bot = RemoteFactoryBot.with_remote(:casey)

            expect(remote_factory_bot).to receive(:factories) do
              expect(
                remote_factory_bot.remotes_config.current_remote
              ).to eq(:casey)
              expect(
                remote_factory_bot.config(:casey).home_url
              ).to eq('http://over_the_rainbow:6000/remote_factory_bot/casey/home')
            end
            remote_factory_bot.factories
          end
        end
      end

      context 'when configured with remote "default"' do

        before do
          configure_remote_factory_bot(host: 'not_configured_with_name',
                                        port: 9000)
        end

        it 'should return all factories available' do
          expect(RemoteFactoryBot.factories).to match_array(['user', 'user_admin'])
        end

        it 'should be configured to send HTTP request to remote "default"' do
          remote_factory_bot = RemoteFactoryBot

          expect(remote_factory_bot).to receive(:factories) do
            expect(
              remote_factory_bot.remotes_config.current_remote
            ).to eq(:default)
            expect(
              remote_factory_bot.config.home_url
            ).to eq('http://not_configured_with_name:9000/remote_factory_bot/home')
          end
          remote_factory_bot.factories
        end
      end
    end

    describe '.create' do
      context 'when configured with multiple remotes' do
        before do
          configure_remote_factory_bot(remote_name: :travis,
                                        host: 'localhost',
                                        port: 3000,
                                        end_point: '/remote_factory_bot/travis/home',
                                        return_with_root: false)
          configure_remote_factory_bot(remote_name: :casey,
                                        host: 'over_the_rainbow',
                                        port: 6000,
                                        end_point: '/remote_factory_bot/casey/home',
                                        return_response_as: :dot_notation,
                                        return_with_root: false)

        end

        it 'should be able to create a factory with "travis" remote' do
          user = RemoteFactoryBot.with_remote(:travis).create(:user)
          expect(user['first_name']).to eq('Sam')
        end

        it 'should be able to create a factory with "casey" remote' do
          user = RemoteFactoryBot.with_remote(:casey).create(:user)
          expect(user.first_name).to eq('Sam')
        end
      end

      describe 'default .home' do

        before { RemoteFactoryBot.config.home[:host] = 'localhost' }

        it 'should be able to create a factory' do
          user = RemoteFactoryBot.create(:site)
          expect(user).to have_key('user')
        end

        it 'should not return root hash key when .return_with_root is false' do
          RemoteFactoryBot.config.return_with_root = false
          user = RemoteFactoryBot.create(:user)
          expect(user).to_not have_key('user')
        end

        it 'should not return an object that responds to dot notation' do
          RemoteFactoryBot.config.return_response_as = :dot_notation
          user = RemoteFactoryBot.create(:user)
          expect(user.first_name).to_not eq('Sam')
        end

        it 'should send a post request to home' do
          expect(RestClient).to receive(:post)
          RemoteFactoryBot.create(:user, :first_name => 'Sam', :last_name => 'Iam')
        end
      end

      it 'should not return root hash key and should return an object that responds to dot notation' do
        configure_remote_factory_bot(host: 'localhost',
                                      port: 3000,
                                      return_response_as: :dot_notation,
                                      return_with_root: false)
        user = RemoteFactoryBot.create(:user)
        expect(user.first_name).to eq('Sam')
      end

      describe 'when configured to return active_resource object' do

        class ActiveResource
          def self.find(id); end;
        end

        class User < ActiveResource; end

        before do
          RemoteFactoryBot.configure do |config|
            config.home = { :host => 'localhost' }
            config.return_as_active_resource = true
          end
        end

        it 'should return an active resource object' do
          expect(ActiveResource).to receive(:find).with(1)
          RemoteFactoryBot.create(:user).resource(User)
        end
      end
    end
  end
end
