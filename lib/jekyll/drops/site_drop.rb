# frozen_string_literal: true

module Jekyll
  module Drops
    class SiteDrop < Drop
      extend Forwardable

      mutable false

      #def_delegator  :@obj, :site_data
      def_delegators :@obj, :time, :pages, :static_files, :documents, :tags, :categories

      private def_delegator :@obj, :config, :fallback_data

      def [](key)
        if @obj.collections.key?(key) && !special_collection_key?(key)
          @obj.collections[key].docs
        else
          super(key)
        end
      end

      def key?(key)
        (@obj.collections.key?(key) && !special_collection_key?(key)) || super
      end

      def posts
        @site_posts ||= @obj.posts.docs.sort { |a, b| b <=> a }
      end

      def data
        @site_data ||= @obj.site_data
      end

      def html_pages
        @site_html_pages ||= @obj.pages.select do |page|
          page.html? || page.url.end_with?("/")
        end
      end

      def special_collection_key?(key)
        key && %w(posts data).include?(key)
      end

      def collections
        @site_collections ||= @obj.collections.values.sort_by(&:label).map(&:to_liquid)
      end

      # `{{ site.related_posts }}` is how posts can get posts related to
      # them, either through LSI if it's enabled, or through the most
      # recent posts.
      # We should remove this in 4.0 and switch to `{{ post.related_posts }}`.
      def related_posts
        return nil unless @current_document.is_a?(Jekyll::Document)
        @current_document.related_posts
      end
      attr_writer :current_document

      # return nil for `{{ site.config }}` even if --config was passed via CLI
      def config; end
    end
  end
end
