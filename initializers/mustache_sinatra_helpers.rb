module MustacheSinatraHelpers
  def mustache_helpers(*helpers, &block)
    if self.respond_to?(:mustache) && mustache[:namespace].const_defined?(:Views)
      staches = mustache[:namespace]::Views.constants.inject([]) do |staches, const_name|
        if mustache[:namespace]::Views.const_get(const_name).ancestors.include?(Mustache)
          staches << mustache[:namespace]::Views.const_get(const_name)
        end
        staches
      end
      
      staches.each do |stache|
        stache.class_eval(&block)  if block_given?
        stache.send(:include, *helpers) if helpers.any?
      end
    end
  end
end

Sinatra::Base.extend MustacheSinatraHelpers
