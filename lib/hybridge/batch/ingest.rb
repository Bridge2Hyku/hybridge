module Hybridge
  module Batch
    class Ingest

      def initialize(file, current_user)
        @file = file
        @current_user = current_user
        load!
      end

      def load!
        # TODO: Send error if missing staged?

        processing!
        @works = []
        @files = {}

        @csv = CSV.parse(File.read(@file), headers: true, encoding: 'utf-8').map(&:to_hash)
        @csv.each do |row|
          type = row.first.last
          if type.nil?
            next
          elsif(type.include? "Work")
            row.delete("Filename")
            @works << row
            @files[@works.length] = []
          elsif(type.include? "File")
            row.delete("Object Type")
            @files[@works.length] << row
          end
        end

        @works.each_with_index do |work, index|
          Entry.new(work, @files[index+1], @current_user, File.dirname(@file))
        end
        processed!
      end

      def processing!
        new_file = Pathname(@file).sub_ext '' + ".processing"
        File.rename(@file, new_file)
        @file = new_file
      end

      def staged?
        File.file?(Pathname(@file).sub_ext '' + ".staged")
      end

      def processed!
        new_file = Pathname(@file).sub_ext '' + ".processed"
        File.rename(@file, new_file)
        @file = new_file
      end

    end
  end
end