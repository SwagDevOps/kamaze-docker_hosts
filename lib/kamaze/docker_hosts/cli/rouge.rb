# frozen_string_literal: true

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
