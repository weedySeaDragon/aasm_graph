module AASM
  module Graph

    # TODO option to just generate the dot file
    # TODO allow file type (jpg | png) to be specified
    # TODO graphviz options (ex: orientation, etc.) -- just pass thru to dot ?
    # TODO  ex:  options[:orientation] = ENV['ORIENTATION'] if ENV['ORIENTATION']


    class CLI

      DEFAULT_OUTPUT_PATH = File.absolute_path(File.join(__dir__, '..', '..', '..',))
      SUCCESS = 0


      def initialize(options)
        @class_names = Array(options[:class_names])
        @class_files = Array(options[:class_files])
        @output_path = options[:output_path] || DEFAULT_OUTPUT_PATH
      end


      def run

        if required_class_files?(@class_files)
          @class_names.each do |name|

            # TODO needs to handle namespace class names
            begin
              klass = Object.const_get(name)
              edges = ""

              if (initial = klass.aasm.initial_state)
                edges << "initial [shape=point];\n"
                edges << "initial -> #{initial};\n"
              end

              klass.aasm.events.each do |event|
                event.transitions.each do |transition|
                  edges << "#{transition.from} -> #{transition.to} [ label = \"#{event.name}\" ];\n"
                end
              end

              # TODO do this based on options (default = yes, do it.  But maybe we just product the dot file)
              `echo  "#{dot_notation(edges)}" | dot -Tjpg -o #{file_path(name)}` unless edges.empty?

            rescue NameError => e
              puts "Uh oh! Could not handle a class! #{e.message}"
              raise e
            end
          end

        end

        SUCCESS
      end


      private

      def required_class_files?(files)
        result = true
        files.each do |f|
          begin
            require(File.absolute_path(f))
          rescue LoadError => e
            puts "Uh oh. Had a problem with a class file: #{e.message} "
            raise e
          end

        end
        result

      end


      def file_path(name)
        File.join(@output_path, "#{name.downcase}.jpg")
      rescue => e
        puts "Dagnabbit.  Couldn't create the output file: #{e.message}"
        raise e
      end


      def dot_notation(edges)
        <<-DOT
digraph cronjob {
  rankdir=LR; /* This should be configurable */
  node [shape = circle];
  #{edges}
}
        DOT
      end
    end
  end
end
