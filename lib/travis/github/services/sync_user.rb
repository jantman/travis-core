Backports.require_relative_dir 'sync_user'

module Travis
  module Github
    module Services
      class SyncUser < Travis::Services::Base
        register :github_sync_user

        def run
          syncing do
            Organizations.new(user).run
            Repositories.new(user).run
          end
        end

        def user
          # TODO check that clients are only passing the id
          @user ||= current_user || User.find(params[:id])
        end

        private

          def syncing
            user.update_column(:is_syncing, true) unless user.is_syncing?
            result = yield
            user.update_column(:synced_at, Time.now)
            result
          ensure
            user.update_column(:is_syncing, false)
          end
      end
    end
  end
end