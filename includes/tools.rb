def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

def prompt_with_default(var, default)
  set(var) do
  Capistrano::CLI.ui.ask "#{var} [#{default}] : "
  end
  set var, default if eval("#{var.to_s}.empty?")
end

def console_pretty_print(msg)
    if logger.level == Capistrano::Logger::IMPORTANT
        pretty_errors

        msg = msg.slice(0, 57)
        msg << '.' * (60 - msg.size)
        print msg
    else
        puts msg.green
    end
end

def pretty_errors
    if !$pretty_errors_defined
        $pretty_errors_defined = true

        class << $stderr
            @@firstLine = true
            alias _write write

            def write(s)
                if @@firstLine
                    _write('✘'.red << "\n")
                    @@firstLine = false
                end

                _write(s.red)
                $error = true
            end
        end
    end
end

def console_puts_ok
    if logger.level == Capistrano::Logger::IMPORTANT && !$error
        puts '✔'.green
    end

    $error = false
end
