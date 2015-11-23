# A logger for CRake.
class CRake::Logger
  enum Level
    # Logging Levels {{{

    # Low-level information for developers.
    DEBUG

    # Information about task running.
    INFO

    # A warning (default level.)
    WARN

    # An error.
    ERROR

    # }}}
  end

  # Constructor {{{

  # Creates a new logger.
  def initialize(@io)
    @level = Level::WARN
    @color = true
  end

  # }}}
  # Properties {{{

  # Returns its level.
  getter level

  # Set its level.
  setter level

  # Returns its flag which means whether it use colored output.
  def color?
    @color
  end

  # Set its flag which means wharher it use colored output.
  def color?=(flag)
    @color = flag
  end

  # }}}
  # Logging (main) {{{

  # :nodoc:
  COLOR_MAP = {
    Level::DEBUG  => "40;39",
    Level::INFO   => "40;32",
    Level::WARN   => "47;1;33",
    Level::ERROR  => "47;1;31",
  }

  # Logs a message at the level.
  #
  # If `level` is less than its level,
  # it dose not log.
  def log(level, message)
    return if level < @level
    @io << "\e[#{COLOR_MAP[level]}m" if @color
    @io << " #{level.to_s.ljust(5)} "
    @io << "\e[49m" if @color
    @io << " (#{Time.now}) ~~> #{message}"
    @io << "\e[0m"
    @io.puts
    @io.flush
  end

  # }}}
  # Logging (some levels) {{{

  {% for level in Level.constants %}
    # Logs a message at the {{ level }} level.
    def {{ level.id.downcase }}(message)
      log Level::{{ level }}, message
    end
  {% end %}

  # }}}
end
# vim:fdm=marker:
