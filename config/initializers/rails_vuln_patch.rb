# https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ
raise "Not found" unless ActionDispatch::ParamsParser::DEFAULT_PARSERS.has_key?(Mime::XML)
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
raise "Didn't work" if ActionDispatch::ParamsParser::DEFAULT_PARSERS.has_key?(Mime::XML)
