# optimizirati
# - sve u jedan cache dict
# - proci kroz sva polja koja imaju _id polje i posebno is skesirati
# - optimizirati za surrent usera i current pregled

class ActionView::Base
  def xcache(rec, name=:default, &block)
    key = "o/#{rec.class.name.downcase}-#{rec.id}"
    data_key = "#{key}:#{name}"

    updated = rec[:updated_at].to_i || 1

    unless @NO_CACHE
      if from_cache = Rails.cache.read(data_key)
        if from_cache[0] == updated
          concat(from_cache[1])
          return
        end
      end
    end

    index = "#{key}:INDEX"
    index_value = Rails.cache.read index
    index_value ||= []

    index_value.push(name) unless index_value.include?(name)

    Rails.cache.write index, index_value

    data = capture(&block)
    Rails.cache.write data_key, [updated, data]

    concat(data)
  end
end

class ActiveRecord::Base
  after_save :xcache

  def xcache
    key = "o/#{self.class.name.downcase}-#{id}"
    ocache = Rails.cache.read("#{key}:INDEX")
    return unless ocache
    for el in ocache
      Rails.cache.delete "#{key}:#{el}"
    end
  end
end

class ActionController::Base
  private
    def set_no_cache_variable
      @NO_CACHE = request.headers['HTTP_CACHE_CONTROL'] == 'no-cache' ? true : false
    end

    # return if cache_hit_on(object1, object2)
    def xcache(*obj)
      return false unless request.get?
      return false unless flash.keys.blank?
      return false if @NO_CACHE

      etag_list = []

      max_time = (Time.now - 1.year).utc

      obj.each do |el|
        if el.respond_to? :before_create # is model
          if el[:updated_at]
            etag_list.push(el[:updated_at].to_i)
          else
            etag_list.push(%{#{el.class.name}:#{el.id}})
          end
        elsif el.kind_of? ActiveSupport::TimeWithZone
          etag_list << el.to_i
        elsif el.class.name == 'NilClass'
          nil
        else
          raise "UNKNOWN OBJECT [#{el.class.name}] for etag"
        end
      end

      fresh_when(:etag=>etag_list.join('-'), :public=> current_user ? false : true)
    end
end
