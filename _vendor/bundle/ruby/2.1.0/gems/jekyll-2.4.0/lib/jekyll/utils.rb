module Jekyll
  module Utils
    extend self

    # Merges a master hash with another hash, recursively.
    #
    # master_hash - the "parent" hash whose values will be overridden
    # other_hash  - the other hash whose values will be persisted after the merge
    #
    # This code was lovingly stolen from some random gem:
    # http://gemjack.com/gems/tartan-0.1.1/classes/Hash.html
    #
    # Thanks to whoever made it.
    def deep_merge_hashes(master_hash, other_hash)
      target = master_hash.dup

      other_hash.keys.each do |key|
        if other_hash[key].is_a? Hash and target[key].is_a? Hash
          target[key] = Utils.deep_merge_hashes(target[key], other_hash[key])
          next
        end

        target[key] = other_hash[key]
      end

      target
    end

    # Read array from the supplied hash favouring the singular key
    # and then the plural key, and handling any nil entries.
    #
    # hash - the hash to read from
    # singular_key - the singular key
    # plural_key - the plural key
    #
    # Returns an array
    def pluralized_array_from_hash(hash, singular_key, plural_key)
      [].tap do |array|
        array << (value_from_singular_key(hash, singular_key) || value_from_plural_key(hash, plural_key))
      end.flatten.compact
    end

    def value_from_singular_key(hash, key)
      hash[key] if (hash.key?(key) || (hash.default_proc && hash[key]))
    end

    def value_from_plural_key(hash, key)
      if hash.key?(key) || (hash.default_proc && hash[key])
        val = hash[key]
        case val
        when String
          val.split
        when Array
          val.compact
        end
      end
    end

    def transform_keys(hash)
      result = {}
      hash.each_key do |key|
        result[yield(key)] = hash[key]
      end
      result
    end

    # Apply #to_sym to all keys in the hash
    #
    # hash - the hash to which to apply this transformation
    #
    # Returns a new hash with symbolized keys
    def symbolize_hash_keys(hash)
      transform_keys(hash) { |key| key.to_sym rescue key }
    end

    # Apply #to_s to all keys in the Hash
    #
    # hash - the hash to which to apply this transformation
    #
    # Returns a new hash with stringified keys
    def stringify_hash_keys(hash)
      transform_keys(hash) { |key| key.to_s rescue key }
    end

    # Parse a date/time and throw an error if invalid
    #
    # input - the date/time to parse
    # msg - (optional) the error message to show the user
    #
    # Returns the parsed date if successful, throws a FatalException
    # if not
    def parse_date(input, msg = "Input could not be parsed.")
      Time.parse(input)
    rescue ArgumentError
      raise Errors::FatalException.new("Invalid date '#{input}': " + msg)
    end

    # Determines whether a given file has
    #
    # Returns true if the YAML front matter is present.
    def has_yaml_header?(file)
      !!(File.open(file, 'rb') { |f| f.read(5) } =~ /\A---\r?\n/)
    end

    # Slugify a filename or title.
    #
    # name - the filename or title to slugify
    #
    # Returns the given filename or title in lowercase, with every
    # sequence of spaces and non-alphanumeric characters replaced with a
    # hyphen.
    def slugify(string)
      unless string.nil?
        # Replace each non-alphanumeric character sequence with a hyphen
        slug = string.gsub(/[^a-z0-9]+/i, '-')
        # Remove leading/trailing hyphen
        slug.gsub!(/^\-|\-$/i, '')
        slug.downcase
      end
    end

  end
end
