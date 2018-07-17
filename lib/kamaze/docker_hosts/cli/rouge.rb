# frozen_string_literal: true

# Copyright (C) 2017-2018 Dimitri Arrigoni <dimitri@arrigoni.me>
# License GPLv3+: GNU GPL version 3 or later
# <http://www.gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.

require_relative '../cli'

# Rouge integration, provides ``hl`` method.
module Kamaze::DockerHosts::Cli::Rouge
  autoload 'Rouge', 'rouge'

  protected

  # Format a gvien ``source`` with ``lexer``.
  #
  # @param [String|Object] source
  # @param [Symbol] lexer
  # @return [String]
  def hl(source, lexer = :PlainText)
    Rouge::Formatters::Terminal256.new.tap do |formatter|
      lexer = Rouge::Lexers.const_get(lexer).new

      return formatter.format(lexer.lex(source.to_s))
    end
  end
end
