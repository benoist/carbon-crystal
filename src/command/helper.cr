module Carbon
  class Command
    module Helper
      WHICH_GIT_COMMAND = "which git >/dev/null"

      def self.fetch_author
        return "[your-name-here]" unless system(WHICH_GIT_COMMAND)
        `git config --get user.name`.strip
      end

      def self.fetch_email
        return "[your-email-here]" unless system(WHICH_GIT_COMMAND)
        `git config --get user.email`.strip
      end

      def self.fetch_github_name
        default = "[your-github-name]"
        return default unless system(WHICH_GIT_COMMAND)
        github_user = `git config --get github.user`.strip
        github_user.empty? ? default : github_user
      end

      def self.fetch_required_parameter(opts, args, name)
        if args.empty?
          puts "#{name} is missing"
          puts opts
          exit 1
        end
        args.shift
      end
    end
  end
end
